{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  # media - control and enjoy audio/video
in {
  config = {
    home.packages = with pkgs; [
      #reading, writing and editing meta information
      exiftool
      # audio control
      pavucontrol
      # torrents
      transmission-remote-gtk
      #bluetooth
      bluez
      #mpris
      playerctl
      #music player
      mpc
    ];

    services = {
      mpd = {
        enable = true;
        extraConfig = ''
          audio_output {
              type    "pulse"
              name    "pipewire-pulse"
          }
        '';
      };
      mpd-mpris.enable = true;
    };

    programs = {
      mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [pkgs.mpvScripts.mpris];
      };

      imv.enable = true;

      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
        ];
      };

      beets = let
        python = pkgs.python3.pkgs;
        beets-xtractor = with python;
          buildPythonPackage rec {
            pname = "beets-xtractor";
            version = "v0.4.2";
            pyproject = true;

            src = pkgs.fetchFromGitHub {
              owner = "adamjakab";
              repo = "BeetsPluginXtractor";
              rev = version;
              hash = "sha256-it4qQ2OS4qBEaGLJK8FVGpjlvg0MQICazV7TAM8lH9s=";
            };

            build-system = [
              setuptools
            ];

            nativeBuildInputs = [
              beets-minimal
            ];
          };
      in {
        enable = true;
        package = python.beets.override {
          pluginOverrides = {
            xtractor = {
              enable = true;
              propagatedBuildInputs = [beets-xtractor];
            };
          };
        };
        mpdIntegration = {
          enableStats = true;
          enableUpdate = true;
        };
        settings = {
          plugins = [
            "smartplaylist"
            "musicbrainz"
            "edit"
            "chroma"
            "xtractor"
            "listenbrainz"
            "mpdstats"
            "mpdupdate"
          ];
          match = {
            strong_rec_thresh = 0.1;
            max_rec = {
              missing_tracks = "strong";
              track_length = "medium";
            };
            distance_weights = {
              data_source = 2.0;
              artist = 3.0;
              album = 3.0;
              media = 1.0;
              mediums = 1.0;
              year = 5.0;
              country = 0.5;
              label = 0.5;
              catalognum = 0.5;
              albumdisambig = 0.5;
              album_id = 5.0;
              tracks = 3.0;
              missing_tracks = 0.0;
              unmatched_tracks = 5.0;
              track_title = 3.0;
              track_artist = 2.0;
              track_index = 1.0;
              track_length = 10.0;
              track_id = 5.0;
              medium = 1.0;
            };
            preferred = {
              media = [
                "Digital Media|File"
                "Digital Media"
              ];
              countries = ["XW"];
            };
          };

          listenbrainz = {
            token = "TOKEN";
            username = "LISTENBRAINZ_USERNAME";
          };
          smartplaylist = {
            relative_to = config.services.mpd.musicDirectory;
            playlist_dir = config.services.mpd.playlistDirectory;
            forward_slash = "no";
            playlists = [
              {
                name = "all.m3u";
                query = "";
              }
            ];
          };
          musicbrainz = {
            data_source_mismatch_penalty = 0.0;
            extra_tags = ["country" "label" "year"];
            genres = "yes";
            # external_ids = {
            #   spotify = "yes";
            # };
          };
          xtractor = {
            threads = 2;
            keep_output = "yes";
            keep_profiles = "yes";
            output_path = "${config.xdg.dataHome}/essentia/xtraction_data";
            essentia_extractor = lib.getExe pkgs.essentia-extractor;
            extractor_profile = {
              highlevel = {
                svm_models = let
                  extractors = "${config.xdg.dataHome}/essentia/extractors";
                in [
                  "${extractors}/beta5/svm_models/danceability.history"
                  "${extractors}/beta5/svm_models/gender.history"
                  "${extractors}/beta5/svm_models/genre_rosamerica.history"
                  "${extractors}/beta5/svm_models/mood_acoustic.history"
                  "${extractors}/beta5/svm_models/mood_aggressive.history"
                  "${extractors}/beta5/svm_models/mood_electronic.history"
                  "${extractors}/beta5/svm_models/mood_happy.history"
                  "${extractors}/beta5/svm_models/mood_sad.history"
                  "${extractors}/beta5/svm_models/mood_party.history"
                  "${extractors}/beta5/svm_models/mood_relaxed.history"
                  "${extractors}/beta5/svm_models/voice_instrumental.history"
                  "${extractors}/beta5/svm_models/moods_mirex.history"
                ];
              };
            };
          };
        };
      };
    };

    services = {
      udiskie.enable = true;
    };
  };
}
