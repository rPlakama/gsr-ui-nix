{
  description = "gsr-ui pkg flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    gpu-screen-recorder = {
      url = "git+https://repo.dec05eba.com/gpu-screen-recorder";
      flake = false;
    };
    gpu-screen-recorder-ui = {
      url = "git+https://repo.dec05eba.com/gpu-screen-recorder-ui?submodules=1";
      flake = false;
    };
    gpu-screen-recorder-notification = {
      url = "git+https://repo.dec05eba.com/gpu-screen-recorder-notification?submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      gpu-screen-recorder,
      gpu-screen-recorder-ui,
      gpu-screen-recorder-notification,
    }:
    let
      mkModule =
        {
          name ? "default",
          class,
          file,
        }:
        {
          _class = class;
          _file = "${self.outPath}/flake.nix#${class}Modules.${name}";

          imports = [ (import file { flakeSelf = self; }) ];
        };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # https://discourse.nixos.org/t/different-ways-of-populating-pkgs-variable/29109/2
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.gpu-screen-recorder-ui;
          gpu-screen-recorder-ui = pkgs.callPackage ./gpu-screen-recorder-ui.nix {
            src = gpu-screen-recorder-ui;
            gpu-screen-recorder = self.packages.${system}.gpu-screen-recorder;
            gpu-screen-recorder-notification = self.packages.${system}.gpu-screen-recorder-notification;
          };
          gpu-screen-recorder = pkgs.callPackage ./gpu-screen-recorder.nix {
            src = gpu-screen-recorder;
          };
          gpu-screen-recorder-notification = pkgs.callPackage ./gpu-screen-recorder-notification.nix {
            src = gpu-screen-recorder-notification;
          };
        };

        apps = {
          update = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "gsr-update" ''
                exec ${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' flake update
              ''
            );
          };
        };
      }
    )
    // {
      nixosModules.default = mkModule {
        class = "nixos";
        file = ./module.nix;
      };
    };
}
