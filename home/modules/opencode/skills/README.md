# Matt Pocock's Skills (native)

Vendored from <https://github.com/mattpocock/skills> (MIT license, © Matt
Pocock), commit `84fdeffd12f2ee307994d1eb6feb48173b6e0502` — byte-identical to
upstream except for one deviation below.

## Deviation from upstream

The `agents/openai.yaml` beside every `SKILL.md` (Codex UI metadata +
invocation policy) is deleted. Codex is not used, and neither opencode nor
Claude Code read those files; keeping them would just be dead weight. The now
empty `agents/` directories are removed too. `SKILL.md` and all other resource
files are untouched, so `diff -r` against upstream differs only by these files.

Each subdirectory is one skill (`SKILL.md` plus its sibling resource files).
They are wired into `programs.opencode.skills` and
`programs.claude-code.skills` via `../default.nix`, which copies each directory
recursively to `~/.config/opencode/skills/<name>/` and `~/.claude/skills/<name>/`.

## Set (25 of 25 stable)

The full non-experimental suite: every stable skill in upstream's `engineering/`
and `productivity/` buckets. Excluded by upstream's own taxonomy: the beta
`in-progress/` skills, the empty `deprecated/` bucket, and the un-promoted
`misc/` tools.

- **Engineering:** `ask-matt`, `codebase-design`, `code-review`, `diagnosing-bugs`,
  `domain-modeling`, `grill-with-docs`, `implement`, `improve-codebase-architecture`,
  `prototype`, `research`, `resolving-merge-conflicts`, `setup-matt-pocock-skills`,
  `tdd`, `to-spec`, `to-tickets`, `triage`, `wayfinder`, `wizard`
- **Productivity:** `grilling`, `grill-me`, `handoff`, `teach`, `to-questionnaire`,
  `wait-what`, `writing-for-agents`

## Flow

```
/grill-me (or /grill-with-docs)     # align on the change; grill-with-docs also
                                    # writes CONTEXT.md + ADRs via /domain-modeling
  → /wayfinder <effort>             # multi-session effort: chart a decision-ticket
  → /to-spec #<map>                 # map   collapse the map into a spec issue
  → /to-tickets                     # spec → tracer-bullet tickets with blockers
  → /implement                      # /tdd at pre-agreed seams → /code-review → commit
  → /code-review                    # two-axis review (Standards + Spec)
```

`/triage` moves incoming issues through triage roles; `/handoff` bridges sessions;
`/wait-what` re-pitches anything that doesn't land; `/ask-matt` routes to whichever
user-invoked skill fits.

## Per-repo setup

Run `/setup-matt-pocock-skills` once per repo. It configures:

- The issue tracker (`wayfinder`/`to-spec`/`to-tickets` publish to it): GitHub,
  Linear, or local files (`.scratch/...`).
- Triage labels (used by `/triage`).
- Where docs (ADRs, domain docs) are saved.

Until it's run, the tracker-dependent skills will tell you to run it.

## Updating

Fork with one deviation. To pull upstream changes:

```bash
cd /home/mikilio/Code/Public/github.com/mattpocock/skills
git pull
# re-copy engineering/ and productivity/ skill dirs into this directory
```

Then re-apply the deviation:

```bash
find home/modules/opencode/skills -path "*/agents/openai.yaml" -delete
find home/modules/opencode/skills -name agents -type d -empty -delete
```
