const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // raylib
    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raylib_math = raylib_dep.module("raylib-math"); // raymath module
    const rlgl = raylib_dep.module("rlgl"); // rlgl module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    const exe = b.addExecutable(.{
        .name = "zig",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raylib-math", raylib_math);
    exe.root_module.addImport("rlgl", rlgl);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
