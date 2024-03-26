{ config, lib, self, inputs, ... }:

{
  options = {
    colmena-parts = lib.mkOption {
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

          sshConn = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            description = ''
              The SSH connection string for colmena nodes
            '';
            default = builtins.mapAttrs (_: v: "${v.targetUser}@${v.targetHost}") config.colmena-parts.deployment;
            readOnly = true;
          };
        };
      };
    };
  };

  config.flake = {
    colmena-parts = {
      inherit (config.colmena-parts) system sshConn;
    };

    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ ];
        };
        # https://github.com/zhaofengli/colmena/issues/60#issuecomment-1510496861
        nodeSpecialArgs = builtins.mapAttrs (_: value: value._module.specialArgs) self.nixosConfigurations;
      };
    } // builtins.mapAttrs
      (name: value: {
        imports = value._module.args.modules ++ [{
          deployment = config.colmena-parts.deployment.${name};
        }];
      })
      self.nixosConfigurations;
  };
}
