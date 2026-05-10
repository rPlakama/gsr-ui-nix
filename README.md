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
      enable = true;
      ui.enable = true;
    };
```


