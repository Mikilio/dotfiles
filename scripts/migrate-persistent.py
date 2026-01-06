#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p "python3.withPackages (ps: [])"

import json
import subprocess
import os
import stat
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Set
from dataclasses import dataclass

# ANSI colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

# Paths to check for unmanaged files (relative to /persistent, without leading slash)
# Only these directories will be scanned
CHECK_PATHS = [
    "var",
    "root",
]

@dataclass
class PathInfo:
    subvolume: str
    path: str
    user: str
    group: str
    mode: str
    is_dir: bool

def get_nix_config() -> dict:
    """Fetch the NixOS configuration as JSON."""
    print(f"{Colors.BLUE}Fetching NixOS configuration...{Colors.NC}")
    try:
        result = subprocess.run(
            ["nix", "eval", ".#nixosConfigurations.elitebook.config.environment.persistence", "--json"],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"{Colors.RED}Error running nix eval: {e.stderr}{Colors.NC}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"{Colors.RED}Error parsing JSON: {e}{Colors.NC}")
        sys.exit(1)

def parse_config(config: dict) -> List[PathInfo]:
    """Parse the configuration and extract all paths with their properties."""
    paths = []
    
    for subvolume, persistence_config in config.items():
        # Parse directories
        for dir_entry in persistence_config.get("directories", []):
            paths.append(PathInfo(
                subvolume=subvolume,
                path=dir_entry["dirPath"],
                user=dir_entry.get("user", "root"),
                group=dir_entry.get("group", "root"),
                mode=dir_entry.get("mode", "0755"),
                is_dir=True
            ))
        
        # Parse files
        for file_entry in persistence_config.get("files", []):
            paths.append(PathInfo(
                subvolume=subvolume,
                path=file_entry["filePath"],
                user=file_entry.get("parentDirectory", {}).get("user", "root"),
                group=file_entry.get("parentDirectory", {}).get("group", "root"),
                mode=file_entry.get("parentDirectory", {}).get("mode", "0755"),
                is_dir=False
            ))
    
    return paths

def get_current_permissions(path: Path) -> Tuple[str, str, str] | None:
    """Get current user, group, and mode of a path."""
    if not path.exists():
        return None
    
    try:
        st = path.stat()
        user = path.owner()
        group = path.group()
        mode = oct(stat.S_IMODE(st.st_mode))[2:]  # Remove '0o' prefix
        return (user, group, mode)
    except (OSError, KeyError) as e:
        print(f"{Colors.RED}Error getting permissions for {path}: {e}{Colors.NC}")
        return None

def check_permissions(paths: List[PathInfo]) -> List[Dict]:
    """Check if permissions match between config and actual files.
    
    Only checks directories, not files.
    """
    print(f"{Colors.BLUE}Checking directory permissions...{Colors.NC}")
    mismatches = []
    
    # Filter to only directories
    directories = [p for p in paths if p.is_dir]
    
    for path_info in directories:
        persistent_path = Path("/persistent") / path_info.path.lstrip("/")
        current_perms = get_current_permissions(persistent_path)
        
        if current_perms is None:
            mismatches.append({
                "path": path_info.path,
                "issue": "does not exist",
                "persistent_path": str(persistent_path),
                "subvolume": path_info.subvolume
            })
            continue
        
        current_user, current_group, current_mode = current_perms
        expected_mode = path_info.mode.lstrip("0")
        current_mode = current_mode.lstrip("0")
        
        if (current_user != path_info.user or 
            current_group != path_info.group or 
            current_mode != expected_mode):
            mismatches.append({
                "path": path_info.path,
                "issue": "permission mismatch",
                "persistent_path": str(persistent_path),
                "current": f"{current_user}:{current_group} {current_mode}",
                "expected": f"{path_info.user}:{path_info.group} {expected_mode}",
                "subvolume": path_info.subvolume
            })
    
    return mismatches

def is_path_managed(relative_str: str, managed_dirs: Set[str], managed_files: Set[str]) -> bool:
    """
    Check if a path is managed by the configuration.
    
    A path is managed if:
    1. It's exactly a managed file, OR
    2. It's under a managed directory (and not overridden by a more specific rule)
    
    When checking parent directories, we look for the most specific (deepest) match.
    """
    # Exact file match
    if relative_str in managed_files:
        return True
    
    # Check if under any managed directory
    # We need to find the deepest managed directory that contains this path
    path_parts = Path(relative_str).parts
    
    # Walk from the full path down to root, checking each level
    for i in range(len(path_parts), 0, -1):
        parent = str(Path(*path_parts[:i]))
        if parent in managed_dirs:
            return True
    
    return False

def find_unmanaged_files(paths: List[PathInfo]) -> Tuple[List[str], int]:
    """Find files in /persistent that won't be copied anywhere.
    
    Only checks directories specified in CHECK_PATHS.
    
    Returns:
        Tuple of (list of unmanaged files, count of ignored symlinks)
    """
    print(f"{Colors.BLUE}Checking for unmanaged files...{Colors.NC}")
    print(f"{Colors.YELLOW}Checking paths: {', '.join(CHECK_PATHS)}{Colors.NC}")
    print(f"{Colors.YELLOW}Ignoring all symlinks{Colors.NC}")
    
    # Build sets of all managed paths from ALL subvolumes
    # A path is managed if it's in ANY subvolume
    managed_dirs = set()
    managed_files = set()
    
    for path_info in paths:
        path_str = path_info.path.lstrip("/")
        if path_info.is_dir:
            managed_dirs.add(path_str)
        else:
            managed_files.add(path_str)
    
    print(f"{Colors.BLUE}Total managed directories (across all subvolumes): {len(managed_dirs)}{Colors.NC}")
    print(f"{Colors.BLUE}Total managed files (across all subvolumes): {len(managed_files)}{Colors.NC}")

    # Find all files under specified paths in /persistent
    unmanaged = []
    symlink_count = 0
    persistent_root = Path("/persistent")
    
    if not persistent_root.exists():
        print(f"{Colors.YELLOW}Warning: /persistent does not exist{Colors.NC}")
        return [], 0
    
    for check_path in CHECK_PATHS:
        check_dir = persistent_root / check_path
        
        if not check_dir.exists():
            print(f"{Colors.YELLOW}Warning: {check_dir} does not exist, skipping{Colors.NC}")
            continue
        
        print(f"{Colors.BLUE}Scanning {check_dir}...{Colors.NC}")
        
        for item in check_dir.rglob("*"):
            # Skip symlinks
            if item.is_symlink():
                symlink_count += 1
                continue
            
            # Get relative path from /persistent
            try:
                relative_path = item.relative_to(persistent_root)
                relative_str = str(relative_path)
            except ValueError:
                continue
            
            # Check if this path is managed
            if not is_path_managed(relative_str, managed_dirs, managed_files):
                unmanaged.append(str(item))
    
    return unmanaged, symlink_count

def display_results(mismatches: List[Dict], unmanaged: List[str], symlink_count: int, paths: List[PathInfo]):
    """Display the results of permission checks and missing files."""
    print(f"\n{Colors.YELLOW}=== Permission Check Results ==={Colors.NC}")
    if mismatches:
        print(f"{Colors.RED}Found {len(mismatches)} issues:{Colors.NC}\n")
        for mismatch in mismatches:
            print(f"Path: {mismatch['path']}")
            print(f"  Issue: {mismatch['issue']}")
            print(f"  Location: {mismatch['persistent_path']}")
            if 'current' in mismatch:
                print(f"  Current:  {mismatch['current']}")
                print(f"  Expected: {mismatch['expected']}")
            print(f"  Target subvolume: {mismatch['subvolume']}")
            print()
        
        # Save to file
        with open("permission_issues.txt", "w") as f:
            for mismatch in mismatches:
                f.write(f"Path: {mismatch['path']}\n")
                f.write(f"  Issue: {mismatch['issue']}\n")
                f.write(f"  Location: {mismatch['persistent_path']}\n")
                if 'current' in mismatch:
                    f.write(f"  Current:  {mismatch['current']}\n")
                    f.write(f"  Expected: {mismatch['expected']}\n")
                f.write(f"  Target subvolume: {mismatch['subvolume']}\n\n")
        print(f"Details saved to: permission_issues.txt")
    else:
        print(f"{Colors.GREEN}All directory permissions match!{Colors.NC}")
    
    print(f"\n{Colors.YELLOW}=== Unmanaged Files Check ==={Colors.NC}")
    if symlink_count > 0:
        print(f"{Colors.BLUE}Ignored {symlink_count} symlinks{Colors.NC}")
    
    # Always save unmanaged files to file
    with open("unmanaged_files.txt", "w") as f:
        f.write(f"# Files in /persistent (under {', '.join(CHECK_PATHS)}) not covered by config\n")
        f.write(f"# Total: {len(unmanaged)} files/directories\n")
        f.write(f"# Symlinks ignored: {symlink_count}\n")
        f.write(f"# These will NOT be copied to any subvolume\n")
        f.write(f"# Note: A path is considered managed if it exists in ANY subvolume\n\n")
        for item in sorted(unmanaged):
            f.write(f"{item}\n")
    
    if unmanaged:
        print(f"{Colors.RED}Found {len(unmanaged)} unmanaged files/directories!{Colors.NC}")
        print(f"These will NOT be copied to any subvolume.\n")
        print("First 20 entries:")
        for item in sorted(unmanaged)[:20]:
            print(f"  {item}")
        if len(unmanaged) > 20:
            print(f"  ... and {len(unmanaged) - 20} more")
        print(f"\n{Colors.YELLOW}Full list saved to: unmanaged_files.txt{Colors.NC}")
    else:
        print(f"{Colors.GREEN}All files in checked paths are managed (excluding symlinks){Colors.NC}")
        print(f"Empty list saved to: unmanaged_files.txt")
    
    # Display copy plan
    print(f"\n{Colors.YELLOW}=== Copy Plan ===${Colors.NC}")
    subvolume_counts = {}
    for path_info in paths:
        subvolume_counts[path_info.subvolume] = subvolume_counts.get(path_info.subvolume, 0) + 1
    
    print("Will copy files from /persistent to the following subvolumes:")
    for subvolume, count in sorted(subvolume_counts.items()):
        dir_count = len([p for p in paths if p.subvolume == subvolume and p.is_dir])
        file_count = len([p for p in paths if p.subvolume == subvolume and not p.is_dir])
        print(f"  - {subvolume} ({dir_count} directories, {file_count} files)")

def confirm_proceed() -> bool:
    """Ask user for confirmation."""
    print()
    response = input("Do you want to proceed with copying? (yes/no): ").strip().lower()
    return response == "yes"

def copy_files(paths: List[PathInfo], log_file: str = "copied_files.log"):
    """Copy files from /persistent to their target subvolumes."""
    print(f"\n{Colors.BLUE}Starting copy operation...{Colors.NC}")
    
    copied = []
    skipped = []
    errors = []
    
    for path_info in paths:
        source = Path("/persistent") / path_info.path.lstrip("/")
        dest = Path(path_info.subvolume) / path_info.path.lstrip("/")
        
        # Check if source exists
        if not source.exists():
            skipped.append((str(source), "does not exist"))
            print(f"{Colors.YELLOW}SKIP: {source} (does not exist){Colors.NC}")
            continue
        
        # Check if destination already exists
        if dest.exists():
            skipped.append((str(source), "destination exists"))
            print(f"{Colors.YELLOW}EXISTS: {dest}{Colors.NC}")
            continue
        
        try:
            # Create parent directory
            dest.parent.mkdir(parents=True, exist_ok=True)
            
            # Copy with subprocess to preserve all attributes
            if path_info.is_dir:
                subprocess.run(
                    ["cp", "-a", str(source), str(dest.parent) + "/"],
                    check=True,
                    capture_output=True
                )
                print(f"{Colors.GREEN}✓{Colors.NC} Copied directory: {path_info.path}")
            else:
                subprocess.run(
                    ["cp", "-a", str(source), str(dest)],
                    check=True,
                    capture_output=True
                )
                print(f"{Colors.GREEN}✓{Colors.NC} Copied file: {path_info.path}")
            
            copied.append((str(source), str(dest)))
        
        except subprocess.CalledProcessError as e:
            error_msg = e.stderr.decode() if e.stderr else str(e)
            errors.append((str(source), error_msg))
            print(f"{Colors.RED}ERROR copying {source}: {error_msg}{Colors.NC}")
        except Exception as e:
            errors.append((str(source), str(e)))
            print(f"{Colors.RED}ERROR copying {source}: {e}{Colors.NC}")
    
    # Write log file
    with open(log_file, "w") as f:
        f.write("# Successfully copied files\n")
        f.write("# Format: source -> destination\n\n")
        for source, dest in copied:
            f.write(f"{source} -> {dest}\n")
        
        if skipped:
            f.write("\n# Skipped files\n")
            for source, reason in skipped:
                f.write(f"# SKIPPED: {source} ({reason})\n")
        
        if errors:
            f.write("\n# Errors\n")
            for source, error in errors:
                f.write(f"# ERROR: {source} - {error}\n")
    
    # Summary
    print(f"\n{Colors.GREEN}=== Copy Complete ==={Colors.NC}")
    print(f"Successfully copied: {len(copied)} items")
    print(f"Skipped: {len(skipped)} items")
    print(f"Errors: {len(errors)} items")
    print(f"\nLog saved to: {log_file}")
    
    if copied:
        print(f"\n{Colors.YELLOW}Next steps:{Colors.NC}")
        print("1. Verify the copied files in the new subvolumes")
        print("2. When ready to delete from /persistent, you can use:")
        print(f"   grep '^/' {log_file} | cut -d' ' -f1 | xargs rm -rf")
        print(f"\n{Colors.YELLOW}⚠  Please verify the copies before deleting from /persistent!{Colors.NC}")

def main():
    """Main execution function."""
    # Get and parse config
    config = get_nix_config()
    paths = parse_config(config)
    
    dir_count = len([p for p in paths if p.is_dir])
    file_count = len([p for p in paths if not p.is_dir])
    print(f"{Colors.GREEN}Found {dir_count} directories and {file_count} files in configuration{Colors.NC}")
    
    # Check permissions (only for directories)
    mismatches = check_permissions(paths)
    
    # Find unmanaged files
    unmanaged, symlink_count = find_unmanaged_files(paths)
    
    # Display results
    display_results(mismatches, unmanaged, symlink_count, paths)
    
    # Ask for confirmation
    if not confirm_proceed():
        print("Aborted.")
        sys.exit(0)
    
    # Perform copy
    copy_files(paths)

if __name__ == "__main__":
    main()
