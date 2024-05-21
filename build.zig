const std = @import("std");
const raylib_zig = "libs/raylib-zig";
const rl = @import("libs/raylib-zig/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const raylib = rl.getModule(b, "libs/raylib-zig");
    const raylib_math = rl.math.getModule(b, "libs/raylib-zig");

    const exe = b.addExecutable(.{
        .name = "zig",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    rl.link(b, exe, target, optimize);
    exe.addModule("raylib", raylib);
    exe.addModule("raylib_math", raylib_math);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.installArtifact(exe);
}
