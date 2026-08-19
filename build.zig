const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv64,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const kernel = b.addExecutable(.{
        .name = "zmachine",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .code_model = .medium,
        }),
    });

    kernel.setLinkerScript(b.path("src/arch/riscv64/linker.ld"));

    b.installArtifact(kernel);

    const run = b.step("run", "Boot zmachine in QEMU");

    const qemu = b.addSystemCommand(&.{
        "qemu-system-riscv64",
        "-machine",
        "virt",
        "-bios",
        "none",
        "-smp",
        "1",
        "-m",
        "128M",
        "-display",
        "none",
        "-monitor",
        "none",
        "-serial",
        "stdio",
        "-kernel",
    });

    qemu.addFileArg(kernel.getEmittedBin());

    run.dependOn(&qemu.step);
}
