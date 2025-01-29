//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");
const cpu = @import("cpu.zig");

pub fn main() !void {
    var cpuInstance = cpu.CPU.init();
    cpuInstance.tick();
}
