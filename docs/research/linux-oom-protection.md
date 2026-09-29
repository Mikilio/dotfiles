# Linux OOM protection and `herdr`

**Research date:** 2026-09-25

## Bottom line

Linux has several independent controls that are often conflated:

- `oom_score_adj` and systemd's `OOMScoreAdjust=` influence which tasks the **kernel OOM killer** considers more or less likely victims.
- `memory.min`, `memory.low`, and systemd's `MemoryMin=`/`MemoryLow=` influence **reclaim pressure** in cgroup v2; they are not a general guarantee against an OOM kill.
- `memory.oom.group` and systemd's `OOMPolicy=kill` determine whether a kill is treated as a group kill, not which workload should be preferred.
- PSI and `systemd-oomd` provide a separate, userspace policy that can kill eligible cgroups before the kernel reaches an OOM condition.

`herdr` is launched from a repository-defined **Home Manager user service** that carries an explicit OOM policy, and Ghostty attaches to that service instead of starting a server of its own. The policy is deliberately split between two independent mechanisms: reclaim pressure and growth are bounded by the service's slice, while the question of which workload `systemd-oomd` may kill first belongs to `ManagedOOMPreference=`.

## Kernel victim selection

The kernel documents a badness heuristic from 0 (never kill) to 1000 (always kill). The score is based on estimated memory and swap use relative to the resource context in which the OOM occurred, so it is a heuristic rather than a fixed priority queue. [`/proc/<pid>/oom_score_adj`][proc] adds an adjustment in the range `-1000..1000` to that score:

- A negative adjustment makes the task less preferred.
- A positive adjustment makes it more preferred.
- `-1000` is special: the task always reports badness 0 and is therefore not killed by the ordinary kernel OOM selection path.
- The exported `/proc/<pid>/oom_score` already includes the adjustment, so it should be used together with `oom_score_adj` when inspecting current state.

`-1000` means “do not select this task for the kernel OOM killer”; it does not reserve memory for the task, prevent cgroup limits, or make the workload incapable of causing pressure elsewhere. Raising the value also has no universal safe value: it is a workload-specific tradeoff between preserving the selected process and making other processes more likely victims.

The kernel documentation also notes that lowering `oom_score_adj` requires `CAP_SYS_RESOURCE` once the value would be reduced below the last value set by a process with that capability. [`/proc` documentation][proc]

## cgroup v2 memory controls

`memory.min` is hard protection from reclaim within the effective cgroup boundary. It is not absolute protection: if no unprotected reclaimable memory remains, the OOM killer is invoked. Protection is also bounded by ancestors, and overcommitted child protection is distributed proportionally. [`memory.min`][cgroup]

`memory.low` is best-effort protection. Memory in the effective low boundary can still be reclaimed when there is no reclaimable memory in unprotected cgroups. This is usually the less dangerous starting point when the goal is to reduce reclaim pressure rather than guarantee survival. [`memory.low`][cgroup]

The related controls have different failure modes:

- `memory.high` throttles and aggressively reclaims; crossing it does not itself invoke the OOM killer.
- `memory.max` is a hard cgroup limit; if usage cannot be reduced after reaching it, the OOM killer is invoked inside that cgroup.
- `memory.oom.group=1` makes the cgroup an indivisible OOM victim: its tasks are killed together or not at all. It is useful for workload integrity, not for making a service less likely to be selected. Tasks with `oom_score_adj=-1000` are an exception and are never killed by that group operation. [`memory.oom.group`][cgroup]

systemd maps `MemoryMin=` and `MemoryLow=` to the corresponding cgroup files. Effective protection generally requires corresponding allocation on ancestors; protections can be shared and compete among children. [`systemd.resource-control`][resource-control]

## systemd service controls

For a systemd unit, the two primary settings have different jobs:

### `OOMScoreAdjust=`

`OOMScoreAdjust=` sets the kernel OOM score adjustment for processes executed by the unit. Its accepted range is `-1000..1000`; the default is the service manager's own adjustment, normally 0. It changes candidate selection, not what the service manager does after a kill. [`systemd.exec`][exec]

### `OOMPolicy=`

`OOMPolicy=` controls the reaction after a process in the unit is killed by the kernel OOM killer or by `systemd-oomd`:

- `continue` logs the event and lets the unit continue.
- `stop` logs the event and has the service manager terminate the unit's remaining processes cleanly.
- `kill` sets `memory.oom.group=1`, causing the kernel OOM killer to kill the remaining unit processes as a group; the unit ultimately reaches the `oom-kill` failed state, where `Restart=` may apply.

The default comes from `DefaultOOMPolicy=`; units with `Delegate=` default to `continue`, so the effective default is configuration-dependent. `OOMPolicy=` also determines the state transition after a `systemd-oomd` kill. [`systemd.service`][service]

A negative `OOMScoreAdjust=` needs privilege, and that is the one policy this design gives up. Lowering the inherited score requires `CAP_SYS_RESOURCE`, which a user manager does not have: live transient units requesting `-500` and `0` both started at the user manager's `+100` floor, while positive requests were applied. A system-manager unit with `User=mikilio` and `OOMScoreAdjust=-500` did run as UID 1000 with `/proc/<pid>/oom_score_adj=-500`. So a user service can still make a modest improvement (`OOMScoreAdjust=100` here), but a genuinely negative score requires a privileged system unit or another root-owned launcher. The kernel capability rule is documented in [`/proc`][proc]. Once `MemoryMax` is set, the ceiling dominates anyway: inside the cgroup the kernel has only `herdr` to choose from, so a negative score would not change the outcome. [`systemd.resource-control`][resource-control]

## PSI and `systemd-oomd`

PSI reports time spent stalled on CPU, memory, and I/O. The `some` metric means at least some tasks were stalled; `full` means all non-idle tasks were stalled. Averages cover recent 10-, 60-, and 300-second windows, and cgroup v2 exposes the same metrics through files such as `memory.pressure`. [`PSI`][psi]

`systemd-oomd` uses cgroup v2 and PSI to take corrective action before the kernel OOM killer acts. Units opt in with `ManagedOOMMemoryPressure=kill` and/or `ManagedOOMSwap=kill`. When thresholds are exceeded, `systemd-oomd` selects an eligible descendant cgroup and sends `SIGKILL` to all processes in it. The unit configured with the property is not itself the kill candidate unless an ancestor makes it eligible; only leaf cgroups and cgroups with `memory.oom.group=1` are eligible candidates. [`systemd-oomd.service`][oomd]

The documented `systemd-oomd` policy does not use `oom_score_adj` as a ranking input. Its documented controls are cgroup eligibility, pressure or swap thresholds, and `ManagedOOMPreference=`:

- `avoid` selects a cgroup only when no other viable candidate exists.
- `omit` ignores the cgroup.
- These preferences are not applied recursively and have ownership restrictions for the monitored cgroup.

[`systemd.resource-control`][resource-control]

The service requires a unified cgroup hierarchy, memory accounting, and kernel PSI support; swap is recommended for its swap-based mode. The current upstream defaults describe a 60% memory-pressure limit over a 10-second PSI window sustained for 30 seconds, but these are systemd defaults rather than kernel OOM guarantees. [`oomd.conf`][oomd-conf]

## The implemented policy

- `home/modules/herdr.nix` defines `herdr.service` and `herdr.slice` as `systemd.user` units, under `systemd.user.services` and `systemd.user.slices`, whenever `programs.herdr.enable` is set. It is a plain Home Manager module, so the service exists exactly for the users whose configuration enables it, and there is no host-level `nixos` module and no inference of which user "owns" Herdr.
- The service runs as the session user, never as root, with `Slice=herdr.slice`, `Type=exec`, `OOMPolicy=continue`, and `Restart=on-failure`. Being an unprivileged user unit is the point: it needs no `User=`, no wrapper that waits for `/run/user/$(id -u)/bus`, and no import of the user manager's environment, because the user manager *is* the environment it starts in.
- Resource controls work in the user manager because `user@.service` is delegated: on this host `systemctl show user@1000.service` reports `Delegate=yes` and `DelegateControllers=cpu memory pids`. `home-herdr` asserts the live result — `systemctl --user show herdr.slice -p MemoryMax` reports `17179869184` for a 32 GiB machine.
- `herdr.slice` holds the reclaim, ceiling, and oomd policy: `MemoryAccounting=true`, `MemoryLow=1G`, `MemoryMax=<derived>`, `ManagedOOMMemoryPressure=kill`, `ManagedOOMPreference=avoid`. The limit lives on the slice rather than the service, so it bounds every process in it — the server, anything it forks, and any future unit placed alongside it.
- The ceiling is derived from the machine's installed memory rather than hard-coded. Home Manager reaches the NixOS configuration as `osConfig`, so the module reads `osConfig.hardware.facter.report` (populated by `hardware.facter.reportPath`) and sums `smbios.memory_device[].size`, which nixos-facter reports in KiB, so 32 GiB of installed RAM becomes `MemoryMax=16384M` at the default `memoryMaxPercent = 50`. `smbios.memory_array[].max_size` is deliberately not used: it is the maximum the board accepts, not what is installed. `programs.herdr.memoryMax` overrides the derivation outright, and a host with no hardware report must set it, otherwise an assertion explains the gap. Clan already sets `hardware.facter.reportPath` for any machine that has a `facter.json`, so no host configuration is needed. [`hardware.facter`][facter]
- The ceiling and the ranking policy are different mechanisms, and the ceiling wins inside its own domain. `MemoryMax` makes `herdr.slice` a cgroup that can itself hit an OOM condition; the kernel then selects within that cgroup, where `herdr` is the only candidate and no score adjustment — negative or positive — buys anything. Above the limit the unit is not protected, it is capped — that is the intended trade. `OOMPolicy=continue` and `Restart=on-failure` keep the consequence soft: the killed process is restarted and the unit does not enter a failed state.
- There is deliberately no `OOMPolicy=kill`, so a single kill is never turned into a group kill of every `herdr` process.
- The unit is wanted by `default.target`, so the server starts with the session and stops with it. It is not a boot-time service: there is no session, no runtime directory, and no user to own the cgroup before login, and starting a session multiplexer before anyone logs in has no benefit. The trade is that `herdr` is unavailable until first login, which is also when anything could want to attach to it.
- The socket path is `${config.home.homeDirectory}/.config/herdr/herdr.sock`, exported through `systemd.user.sessionVariables`, which Home Manager writes to `~/.config/environment.d/10-home-manager.conf`. That one file feeds the user manager (and therefore the service) *and* the session generators that every shell reads, so a single option keeps the server, the shells, and the clients in agreement. `home.sessionVariables` is deliberately not also set: it writes the same filename, and two definitions of the same `xdg.configFile` entry would collide.
- `home/modules/ghostty.nix` runs the `programs.herdr.attachCommand` wrapper that the module generates: it checks that the socket exists and that `herdr api snapshot` answers within a timeout, and otherwise execs an interactive shell. A failed, hung, or not-yet-started service therefore degrades to an ordinary terminal instead of silently spawning a second, unprotected server. The wrapper uses the Home Manager `programs.herdr.package`, so client and server cannot drift apart. The tmux command still takes precedence where `programs.tmux` is enabled; no host currently imports `home/modules/tmux.nix`.

The reasoning that produced those values:

1. The service should be owned by the thing it serves. A Home Manager user service lives in the user's session with the user's own environment, so it needs no privileged unit, no `User=`, and no bus-waiting wrapper — and it cannot outlive or leak past the session it belongs to. The cost is a positive-only `oom_score_adj`, which the ceiling already makes moot.
1. The blast radius should stay small: `OOMPolicy=continue` rather than `kill`, so a kernel or oomd kill of one process does not become a kill of every `herdr` process.
1. Reclaim pressure is the soft concern, so `MemoryLow=1G` rather than `MemoryMin=`, which would make the slice's own usage a hard claim on the machine.
1. Growth is the hard concern, so a ceiling caps the whole slice rather than letting one session multiplexer grow until the machine is out of memory. It is placed on the slice, not the service, so it covers every process under `herdr`, and it is derived at 50% of installed memory so a 32 GiB laptop and a 8 GiB machine each get a proportional rather than an identical limit.
1. Early cleanup under sustained pressure is `systemd-oomd`'s job, and `ManagedOOMPreference=avoid` makes the slice the last viable candidate rather than a preferred victim. systemd-oomd honours this for descendants of the monitored `user@UID.service`, which is the cgroup a user slice lives in. [`systemd.resource-control`][resource-control]
1. Client and server are separated so that the OOM policy cannot be bypassed: the client attaches to whatever the service owns, and degrades to a plain shell when the service is absent.

Useful runtime checks are `/proc/<pid>/oom_score_adj`, `/proc/<pid>/oom_score`, `/proc/<pid>/cgroup`, the unit's cgroup `memory.current`, `memory.events`, and `memory.pressure`, and `oomctl` where available. Validate thresholds in a disposable test system rather than by provoking an uncontrolled OOM on a production desktop.

## Sources

All sources were accessed on 2026-09-25. Kernel pages currently identify the documentation as Linux 7.3.0-rc4; systemd links point to the upstream `systemd` manual sources on the `main` branch.

[cgroup]: https://docs.kernel.org/admin-guide/cgroup-v2.html#memory-interface-files
[exec]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.exec.xml
[facter]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/facter/default.nix
[oomd]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd-oomd.service.xml
[oomd-conf]: https://raw.githubusercontent.com/systemd/systemd/main/man/oomd.conf.xml
[proc]: https://docs.kernel.org/filesystems/proc.html#proc-pid-oom-adj-proc-pid-oom-score-adj-adjust-the-oom-killer-score
[psi]: https://docs.kernel.org/accounting/psi.html
[resource-control]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.resource-control.xml
[service]: https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.service.xml
