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

          nativeBuildInputs = [ llvm ];

          dontConfigure = true;
          dontPatch = true;

          buildPhase = ''
            # libs
            LIBS=libs/
            LIBFILES=`llvm-config --libfiles --link-static`

            mkdir -p "$LIBS"
            for libpath in $LIBFILES; do
              install -t "$LIBS" "$libpath"
            done

            # include
            INCLUDE=include/
            INCLUDEDIR=`llvm-config --includedir`

            cp -r "$INCLUDEDIR" "$INCLUDE"

            # tar it up
            LLVMBALL=llvmball.tar.gz

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
