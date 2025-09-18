{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.localModules.shellConfig;
in {
  options.localModules.shellConfig = {
    enable = mkEnableOption "Enable the config for the shell";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
        strategy = ["match_prev_cmd" "completion"];
      };
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
      };
    };
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        format = "$shlvl$shell$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";
        shlvl = {
          disabled = false;
          symbol = "ﰬ";
          style = "bright-red bold";
        };
        shell = {
          disabled = false;
          format = "$indicator";
          fish_indicator = "";
          bash_indicator = "[BASH](bright-white) ";
          zsh_indicator = "[ZSH](bright-white) ";
        };
        username = {
          style_user = "bright-white bold";
          style_root = "bright-red bold";
        };
      };
    };

    programs.tmux.enable = true;
    programs.zoxide.enable = true;
  };
}
