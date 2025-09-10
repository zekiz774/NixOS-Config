{config, lib, pkgs}: let
  inherit (lib) mkEnableOption mkOption types mkIf
in
{
  options.config.shellConfig = {
    enable = mkEnableOption "Enable the config for the shell"
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
    };

    programs.zoxide.enable = true;

  };
}
