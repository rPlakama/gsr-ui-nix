As input:

```
    gsr-ui-nix = {
      url = "github:rPlakama/gsr-ui-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```
Then you can use it in your configuration.nix

```
  imports = [
    inputs.gsr-ui-nix.nixosModules.default
  ];

    programs.gpu-screen-recorder = {
      package = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
      enable = true;
      ui.enable = true;
    };
```

# btw, err 128 similar is 'cause gsr-ui git (link) is down; I guess so...
