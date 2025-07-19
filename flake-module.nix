{
  config,
  lib,
  self,
  inputs,
  ...
}:

{
  options = {
    colmena-flake = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          deployment = lib.mkOption {
            type = lib.types.attrsOf (lib.types.attrsOf lib.types.raw);
            description = ''
              Deployment configuration for colmena nodes
            '';
          };

          system = lib.mkOption {
            type = lib.types.str;
            description = ''
              The system for colmena nodes
            '';
            default = "x86_64-linux";
          };

          usePerNixosConfigPackages = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Each system uses a version of nixpkgs with the already defined system in the nixosConfiguration.
              As long this is enabled the colmena-flake.system has no effect. You can opt-out this feature
              by setting this option to false.
            '';
          };

          sshConn = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            description = ''
              The SSH connection string for colmena nodes
            '';
            default = builtins.mapAttrs (
              _: v: "${v.targetUser}@${v.targetHost}"
            ) config.colmena-flake.deployment;
            readOnly = true;
          };
        };
      };
    };
  };

  config.flake = {
    colmena-flake = {
      inherit (config.colmena-flake) sshConn;
    };

    colmena =
      {
        meta =
          {
            nixpkgs = import inputs.nixpkgs {
              inherit (config.colmena-flake) system;
              overlays = [ ];
            };
            # https://github.com/zhaofengli/colmena/issues/60#issuecomment-1510496861
            nodeSpecialArgs = builtins.mapAttrs (_: value: value._module.specialArgs) self.nixosConfigurations;

          }
          // lib.optionalAttrs config.colmena-flake.usePerNixosConfigPackages {
            nodeNixpkgs = builtins.mapAttrs (
              _: value:
              import inputs.nixpkgs {
                inherit (value.config.nixpkgs) system;
                overlays = [ ];
              }
            ) self.nixosConfigurations;
          };
      }
      // builtins.mapAttrs (name: value: {
        imports = value._module.args.modules ++ [
          {
            deployment = config.colmena-flake.deployment.${name};
          }
        ];
      }) (lib.filterAttrs (k: _: lib.hasAttr k config.colmena-flake.deployment) self.nixosConfigurations);
  };
}
