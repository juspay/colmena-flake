{
  description = "A `flake-parts` module for colmena";
  outputs = _: {
    flakeModules.default = ./flake-module;
  };
}
