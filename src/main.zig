const std = @import("std");

pub const _start = {};

comptime {
    asm (
        \\.section .text.boot, "ax", @progbits
        \\.globl _start
        \\.type _start, @function
        \\_start:
        \\
        \\  lla t0, __bss_start
        \\  lla t1, __bss_end
        \\
        \\1:
        \\  bgeu t0, t1, 2f
        \\  sd zero, 0(t0)
        \\  addi t0, t0, 8
        \\  j 1b
        \\
        \\2:
        \\  lla sp, __stack_top
        \\  call kernelMain
        \\
        \\3:
        \\  wfi
        \\  j 3b
        \\
        \\.size _start, . - _start
    );
}
const uart_base: usize = 0x10000000;

fn uartRegister(offset: usize) *volatile u8 {
    return @ptrFromInt(uart_base + offset);
}

fn writeByte(byte: u8) void {
    // 16550 Line Status Register, bit 5:
    // Transmitter Holding Register Empty.
    while (uartRegister(5).* & 0x20 == 0) {}

    // Offset 0 is the transmit holding register when DLAB is clear.
    uartRegister(0).* = byte;
}

fn write(message: []const u8) void {
    for (message) |byte| {
        writeByte(byte);
    }
}

export fn kernelMain(hart_id: usize, dtb: usize) noreturn {
    _ = hart_id;
    _ = dtb;

    write("hello from zmachine\r\n");

    halt();
}

pub const panic = std.debug.FullPanic(panicImpl);

fn panicImpl(message: []const u8, first_trace_addr: ?usize) noreturn {
    _ = first_trace_addr;

    write("\r\n!KERNEL PANIC!\r\n");
    write(message);
    write("\r\n");

    halt();
}

fn halt() noreturn {
    while (true) {
        asm volatile ("wfi");
    }
}
