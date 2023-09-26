# llvmball

I don't want to build or even really touch llvm ever, if I can avoid it. this is
a nix flake that produces a nicely packaged llvm tarball for your project.

## usage

llvmball unzips to contain the following structure:
- `include` - llvm headers
- `libs` - llvm static libraries
- `src` and `build.zig` - zig package

### zig

I included a zig build for this... but the zig build system dislikes something
about the tarball. when I update zig past 0.11.0 I will come back and fix this,
I would like to be able to use llvmball through the zig package manager