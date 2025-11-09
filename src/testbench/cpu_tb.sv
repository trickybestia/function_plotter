module cpu_tb;

// Set to 0 to not regenerate test programs (useful for debugging)
localparam RUN_REFERENCE_MODEL = 1;

localparam INSTRUCTION_WIDTH          = 16;
localparam INSTRUCTION_MEM_SIZE       = 1024;
localparam INSTRUCTION_MEM_ADDR_WIDTH = $clog2(INSTRUCTION_MEM_SIZE);

localparam DATA_WIDTH          = 16;
localparam DATA_MEM_SIZE       = 1024;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_SIZE);

reg clk;
reg rst;

// cpu_instr_mem
wire [INSTRUCTION_MEM_ADDR_WIDTH - 1:0] instr_mem_addr;
wire [INSTRUCTION_WIDTH - 1:0]          instr_mem_data_0;
wire [INSTRUCTION_WIDTH - 1:0]          instr_mem_data_1;

// cpu_data_mem
wire [DATA_MEM_ADDR_WIDTH - 1:0] data_mem_addr;
wire [DATA_WIDTH - 1:0]          data_mem_read_data;
wire                             data_mem_write_enable;
wire [DATA_WIDTH - 1:0]          data_mem_write_data;

int log_file_fd;

cpu_instr_mem #(
    .DATA_WIDTH (INSTRUCTION_WIDTH),
    .SIZE       (INSTRUCTION_MEM_SIZE),
    .INIT_FILE  ("")
) cpu_instr_mem (
    .clk,
    .addr   (instr_mem_addr),
    .data_0 (instr_mem_data_0),
    .data_1 (instr_mem_data_1)
);

cpu_data_mem #(
    .DATA_WIDTH (DATA_WIDTH),
    .SIZE       (DATA_MEM_SIZE),
    .ADDR_WIDTH (DATA_MEM_ADDR_WIDTH)
) cpu_data_mem (
    .clk,
    .addr         (data_mem_addr),
    .read_data    (data_mem_read_data),
    .write_enable (data_mem_write_enable),
    .write_data   (data_mem_write_data)
);

cpu cpu (
    .clk,
    .rst,
    .instr_mem_addr,
    .instr_mem_data_0,
    .instr_mem_data_1,
    .data_mem_addr,
    .data_mem_read_data,
    .data_mem_write_enable,
    .data_mem_write_data,
    .accel_id           (),
    .accel_can_read     (1),
    .accel_can_write    (1),
    .accel_read_enable  (),
    .accel_read_data    (42),
    .accel_write_enable (),
    .accel_write_data   ()
);

task run_reference_model;
    $system("env -i PYTHONPATH=\"../../../../../model/cpu/\" python -m cpu.cli.fuzzer asm.s instructions.mem expected_log.txt");
endtask

task read_instruction_mem;
    $readmemb("instructions.mem", cpu_instr_mem.mem);
endtask

task dump_cpu_state;
    input int fd;

    $fwrite(fd, "executed: %0d; pc: %0d; regs: [", cpu.executed, cpu.pc);

    for (int i = 1; i != 16; i++) begin
        $fwrite(fd, "%0d", cpu.cpu_reg_file.regs[i]);

        if (i != 15) $fwrite(fd, ", ");
    end

    $fwrite(fd, "]\n");
endtask

task reset;
    rst <= 1;
    @(posedge clk);

    // reset cpu_instr_mem
    for (int i = 0; i != INSTRUCTION_MEM_SIZE; i++) begin
        cpu_instr_mem.mem[i] = '0;
    end

    // reset cpu_data_mem
    for (int i = 0; i != DATA_MEM_SIZE; i++) begin
        cpu_data_mem.mem[i] = '0;
    end

    // reset cpu regs
    for (int i = 1; i != 16; i++) begin
        cpu.cpu_reg_file.regs[i] = '0;
    end

    @(posedge clk);
    @(posedge clk);

    rst <= 0;
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    for (int programs_tested = 0; ; programs_tested++) begin
        reset;
        if (RUN_REFERENCE_MODEL) run_reference_model;
        read_instruction_mem;

        log_file_fd = $fopen("actual_log.txt", "w");

        for (int tick = 0; tick != 1000; tick++) begin
            @(negedge clk);

            dump_cpu_state(log_file_fd);
        end

        $fclose(log_file_fd);

        if ($system("diff -q expected_log.txt actual_log.txt") != 0) begin
            $fatal("expected_log.txt and actual_log.txt differ");
        end

        if (!RUN_REFERENCE_MODEL) $finish;
    end
end

endmodule
