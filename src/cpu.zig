var bus: u32 = 0;

pub const CPU = struct {
    halt: bool,
    ram: RAM,
    registerA: Register32,
    registerB: Register32,
    registerOut: Register32,
    registerMemoryAddress: Register32,
    alu: ArithmeticLogicUnit,
    programCounter: ProgramCounter,
    pub fn init() CPU {
        return CPU{
            .halt = false,
            .ram = RAM{},
            .registerA = Register32{ .output_enable = false, .input_enable = false, .value = 0 },
            .registerB = Register32{ .output_enable = false, .input_enable = false, .value = 0 },
            .registerOut = Register32{ .output_enable = false, .input_enable = false, .value = 0 },
            .registerMemoryAddress = Register32{ .output_enable = false, .input_enable = false, .value = 0 },
            .alu = ArithmeticLogicUnit{},
            .programCounter = ProgramCounter{ .register = Register32{ .output_enable = false, .input_enable = false, .value = 0 }, .count_enable = false },
        };
    }
    pub fn tick(self: *CPU) void {
        if (self.halt) {
            return;
        }
        self.ram.tick();
        self.registerMemoryAddress.tick();
        self.registerA.tick();
        self.registerB.tick();
        self.registerOut.tick();
        self.programCounter.tick();
        self.alu.tick();
    }
};

const RAM = struct {
    output_enable: bool = false,
    input_enable: bool = false,
    data_line: u32 = 0,
    address_line: u32 = 0,

    fn tick(self: *RAM) void {
        if (self.input_enable) {
            self.data_line = bus;
        }
        if (self.output_enable) {
            bus = self.data_line;
        }
    }
};

const Register32 = struct {
    output_enable: bool = false,
    input_enable: bool = false,
    value: u32 = 0,

    fn tick(self: *Register32) void {
        if (self.input_enable) {
            self.value = bus;
        }
        if (self.output_enable) {
            bus = self.value;
        }
    }
};

const ProgramCounter = struct {
    register: Register32 = .{},
    count_enable: bool = false,

    fn tick(self: *ProgramCounter) void {
        if (self.count_enable) {
            self.register.value += 1;
        }
        if (self.register.input_enable) {
            // Interpret the value as an address and jump to it, currently the bus handles both data and addresses
            self.register.value = bus;
        }
        if (self.register.output_enable) {
            bus = self.register.value;
        }
    }
};

const ArithmeticLogicUnit = struct {
    output_enable: bool = false,
    input_A: u32 = 0,
    input_B: u32 = 0,
    subtract: bool = false,

    fn result(self: *ArithmeticLogicUnit) u32 {
        if (self.subtract) {
            return self.input_A - self.input_B;
        } else {
            return self.input_A + self.input_B;
        }
    }

    fn tick(self: *ArithmeticLogicUnit) void {
        // ALU-specific operations
        if (self.output_enable) {
            bus = self.result();
        }
    }
};
