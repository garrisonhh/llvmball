{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    utils.url = github:numtide/flake-utils;
  };

  description = "llvm-16 dev build to a tarball";

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };
        llvmPkgs = pkgs.llvmPackages_16;
        llvm = llvmPkgs.llvm.dev;

        ball = pkgs.stdenv.mkDerivation rec {
          pname = "llvmball";
          version = llvm.version;
          inherit system;
          src = self;

          nativeBuildInputs = [
            pkgs.pkg-config
            llvm
          ];

          dontConfigure = true;
          dontPatch = true;
          dontInstall = true;

          buildPhase = ''
            BASE="llvmball"
            INCLUDE="$BASE/include"
            LIBS="$BASE/libs"
            LLVMBALL="$out/${pname}-${version}.tar.gz"

            mkdir -p $out
            mkdir -p "$BASE"

            install_dir_rec() {
              DIR="$1"
              DEST="$2"

              mkdir -p "$DEST"
              find "$DIR" | while read -r filepath; do
                relpath=`realpath --relative-to="$DIR" $filepath`
                dest="$DEST/$relpath"

                if [ -d $filepath ]; then
                  mkdir -p $dest
                else
                  dest_dir=`dirname $dest`
                  install -m 644 -t $dest_dir $filepath
                fi
              done
            }

            # llvm libs
            LLVM_LIBFILES=`{ llvm-config --libfiles --link-static & llvm-config --libfiles --link-shared; }`

            mkdir -p "$LIBS"
            for libpath in $LLVM_LIBFILES; do
              install -t "$LIBS" "$libpath"
            done

            # include
            INCLUDEDIR=`llvm-config --includedir`

            install_dir_rec "$INCLUDEDIR" "$INCLUDE"

            # tar it up
            tar czf "$LLVMBALL" "$BASE"
          '';
        };
      in
      {
        packages.default = ball;
        formatter = pkgs.nixpkgs-fmt;
      });
}
