{
  pkgs,
  lib,
  config,
  options,
  ...
}: {
  config = {
    programs = let
      context = ''
        You are running on NixOS. Key facts:

        - You have access to all nix CLI commands.
        - If a tool or package is missing, install it impermanently with `nix-shell -p <package> --run "..."` or `nix run nixpkgs#<package> -- ...`. Do not attempt to use package managers like apt, dnf, or brew.
        - If a command fails because a binary is missing, reach for nix first.

        All dependencies you care about are likely in the nix store. Always use the nix CLI to discover them.
        DO NOT search or query the nix store with any unix commands.

        ## Engineering skills

        Matt Pocock's full suite of stable skills is installed verbatim from upstream (engineering + productivity). User-invoked skills are fired by typing `/name` (e.g. `/grill-with-docs`); model-invoked skills (`/tdd`, `/code-review`, `/codebase-design`, `/domain-modeling`, `/diagnosing-bugs`, `/research`, `/prototype`, `/wizard`, `/grilling`) fire automatically when the task fits. `/ask-matt` is the router over the user-invoked skills.

        The flow:

        - `/grill-me` or `/grill-with-docs` — interview to sharpen a plan or design. `/grill-with-docs` also builds the project's shared language, writing `CONTEXT.md` and ADRs lazily via `/domain-modeling`.
        - `/wayfinder <effort>` — for work too big for one session: chart a decision-ticket map on the repo's issue tracker and resolve one ticket per session until the way is clear.
        - `/to-spec #<map>` — collapse the conversation or map into a single spec issue (Problem Statement / Solution / User Stories / Implementation Decisions incl. seams / Testing Decisions / Out of Scope / Further Notes). No interview — pure synthesis.
        - `/to-tickets` — break the spec into tracer-bullet tickets with blocking edges, each sized to one fresh context window, published to the tracker.
        - `/implement` — drive `/tdd` at the pre-agreed seams, run `/code-review`, then commit.
        - `/triage` moves incoming issues through triage roles; `/handoff` bridges sessions; `/wait-what` re-pitches anything that doesn't land.

        Run `/setup-matt-pocock-skills` once per repo to configure the issue tracker (GitHub, Linear, or local files), triage labels, and docs location. `CONTEXT.md` is the shared vocabulary — keep it sharp via `/domain-modeling`.

        Note: OpenSpec's `/opsx:*` commands are also available via the `openspec` CLI where a repo has been initialized with it — an independent, alternative flow kept around for comparison.
      '';
      skills = {
        ask-matt = ./skills/ask-matt;
        codebase-design = ./skills/codebase-design;
        code-review = ./skills/code-review;
        diagnosing-bugs = ./skills/diagnosing-bugs;
        domain-modeling = ./skills/domain-modeling;
        grilling = ./skills/grilling;
        grill-me = ./skills/grill-me;
        grill-with-docs = ./skills/grill-with-docs;
        handoff = ./skills/handoff;
        implement = ./skills/implement;
        improve-codebase-architecture = ./skills/improve-codebase-architecture;
        prototype = ./skills/prototype;
        research = ./skills/research;
        resolving-merge-conflicts = ./skills/resolving-merge-conflicts;
        setup-matt-pocock-skills = ./skills/setup-matt-pocock-skills;
        tdd = ./skills/tdd;
        teach = ./skills/teach;
        to-questionnaire = ./skills/to-questionnaire;
        to-spec = ./skills/to-spec;
        to-tickets = ./skills/to-tickets;
        triage = ./skills/triage;
        wait-what = ./skills/wait-what;
        wayfinder = ./skills/wayfinder;
        wizard = ./skills/wizard;
        writing-for-agents = ./skills/writing-for-agents;
      };
    in {
      claude-code = {
        enable = true;
        enableMcpIntegration = true;
        inherit context skills;
      };

      opencode = {
        enable = true;
        enableMcpIntegration = true;
        inherit context skills;
      };

      herdr = {
        enable = true;
        settings = {};
      };

      mcp = {
        enable = true;
        servers = {
          playwright = {
            enabled = false;
            command = "docker";
            args = ["run" "-i" "--rm" "--init" "--pull=always" "mcr.microsoft.com/playwright/mcp"];
          };
        };
      };
    };
    home =
      {
        packages = with pkgs; [
          mgrep
          openspec
          nono
          pi-coding-agent
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/cache" = {
          directories = [
            {
              directory = ".local/share/opencode";
              mode = "0700";
            }
          ];
        };
      };
  };
}
