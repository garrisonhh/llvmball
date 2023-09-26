const std = @import("std");
const path = std.fs.path;
const Build = std.Build;
const Compile = Build.Step.Compile;
const LazyPath = Build.LazyPath;

const zig_root = LazyPath{ .path = "src/llvm.zig" };
const include_path = LazyPath{ .path = "include" };
const libs_path = LazyPath{ .path = "libs" };

fn linkLlvm(b: *Build, com: *Compile) !void {
    const ally = b.allocator;

    // system deps
    com.linkLibCpp();

    // everything in libs_path
    com.addLibraryPath(libs_path);

    var dir = try std.fs.cwd().openIterableDir(libs_path.path, .{});
    defer dir.close();

    var walker = try dir.walk(ally);
    defer walker.deinit();

    const prefix = "lib";
    const postfix = ".a";

    while (try walker.next()) |entry| {
        const libpath = entry.path;

        std.debug.assert(entry.kind == .file);
        std.debug.assert(std.mem.startsWith(u8, libpath, prefix));
        std.debug.assert(std.mem.endsWith(u8, libpath, postfix));

        const libname = libpath[prefix.len .. libpath.len - postfix.len];

        com.linkSystemLibrary2(libname, .{
            .preferred_link_mode = .Static,
        });
    }
}

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("llvm", .{
        .source_file = zig_root,
    });

    const lib = b.addStaticLibrary(.{
        .name = "llvmball",
        .root_source_file = zig_root,
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(include_path);
    try linkLlvm(b, lib);

    b.installArtifact(lib);
}