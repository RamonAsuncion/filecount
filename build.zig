const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "filecount",
        .root_source_file = b.path("src/main.zig"),
        .target = b.host,
    });

    const run_exe = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run filecount.");
    run_step.dependOn(&run_exe.step);
}
