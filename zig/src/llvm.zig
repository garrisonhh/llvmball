const std = @import("std");

pub usingnamespace @cImport({
    @cInclude("llvm-c/Core.h");
});