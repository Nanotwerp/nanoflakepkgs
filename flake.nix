{
  description = "NarSil";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        system = system;
      });
    in
    {
      packages.default = forAllSystems
        ({ system, pkgs, lib, enableSdl2 }:
          pkgs.clangStdenv.mkDerivation rec {
            pname = "narsil";
            version = "1.3.0";

            src = pkgs.fetchFromGitHub
              {
                owner = "NickMcConnell";
                repo = "NarSil";
                rev = version;
                sha256 = "sha256-XH2FUTJJaH5TqV2UD1CKKAXE4CRAb6zfg1UQ79a15k9=";
              };

            nativeBuildInputs = [ pkgs.autoreconfHook ];
            buildInputs = [ pkgs.ncurses6 ] ++ lib.optionals enableSdl2 [
              pkgs.SDL2
              pkgs.SDL2_image
              pkgs.SDL2_sound
              pkgs.SDL2_mixer
              pkgs.SDL2_ttf
            ];

            configureFlags = lib.optional enableSdl2 "--enable-sdl2";

            installFlags = [ "bindir=$(out)/bin" ];

            meta = with lib; {
              homepage = "https://github.com/NickMcConnell/NarSil";
              description = "Unofficial rewrite of Sil 1.3.0";
              maintainers = [ maintainers.nanotwerp ];
              license = licenses.gpl2;
            };
          });
    };

}
