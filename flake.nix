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

        ball = pkgs.stdenv.mkDerivation {
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

          buildPhase = ''
            INCLUDE=include/
            LIBS=libs/
            LLVMBALL=llvmball.tar.gz

            # llvm libs
            LLVM_LIBFILES=`llvm-config --libfiles --link-static`

            mkdir -p "$LIBS"
            for libpath in $LLVM_LIBFILES; do
              install -t "$LIBS" "$libpath"
            done

            # include
            INCLUDEDIR=`llvm-config --includedir`

            mkdir -p "$INCLUDE"
            find "$INCLUDEDIR" | while read -r filepath; do
              relpath=`realpath --relative-to="$INCLUDEDIR" $filepath`
              dest="$INCLUDE/$relpath"

              if [ -d $filepath ]; then
                mkdir -p $dest
              else
                dest_dir=`dirname $dest`
                install -m 644 -t $dest_dir $filepath
              fi
            done

            # tar it up
            tar czf "$LLVMBALL" "$INCLUDE" "$LIBS"
          '';

          installPhase = ''
            mkdir -p $out
            install -t $out "$LLVMBALL"
          '';
        };
      in
      {
        packages.default = ball;
        formatter = pkgs.nixpkgs-fmt;
      });
}
