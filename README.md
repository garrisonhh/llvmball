# llvmball

I don't want to build or even really touch llvm ever, if I can avoid it. this is
a nix flake that produces a nicely packaged llvm tarball for your project.

## usage

llvmball unzips to contain the following structure:
- `llvmball/include` - llvm headers
- `llvmball/libs` - llvm static libraries