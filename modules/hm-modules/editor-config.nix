{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.localModules.editorConfig;
in {
  options.localModules.editorConfig = {
    enable = mkEnableOption "Enable the editor config (nvim)";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          theme = {
            enable = true;
            name = "tokyonight";
            transparent = true;
            style = "night";
          };
          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;
          viAlias = true;
          vimAlias = true;
          lsp = {
            enable = true;
            formatOnSave = true;
          };

          clipboard = {
            enable = true;
            providers.wl-copy.enable = true;
            registers = "unnamedplus";
          };

          languages = {
            enableTreesitter = true;
            enableFormat = true;
            enableExtraDiagnostics = true;

            nix = {
              enable = true;
            };
            css.enable = true;
            ts.enable = true;
            markdown.enable = true;
            tailwind.enable = true;
            tailwind.lsp.enable = true;
          };

          keymaps = [
            {
              key = "<leader>e";
              mode = ["n" "v" "x"];
              action = ":Neotree toggle<CR>";
            }
          ];

          filetree.neo-tree = {
            enable = true;
            setupOpts = {
              default_source = "last";
            };
          };

          formatter.conform-nvim.enable = true;
          utility.snacks-nvim.enable = true;
          binds.whichKey.enable = true;
          utility.oil-nvim.enable = true;
          globals.editorconfig = true;
          ui.colorizer.setupOpts.user_default_options.tailwind = true;
        };
      };
    };
  };
}
