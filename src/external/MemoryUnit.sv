module MemoryUnit(
    input logic clock,
    input logic write_enable,
    input logic[31:0] read_addr,
    input logic[31:0] write_addr,
    input logic[31:0] write_data,
    output logic[31:0] read_data
);
parameter filename = "src/external/mem_file/Memory.txt";
parameter rom_filename = "";

/*** VHDL component

component MemoryUnit is
    generic (
        filename: string := "src/external/mem_file/Memory.txt";
        rom_filename: string := ""
    );
    port (
        clock: in std_logic;
        write_enable: in std_logic;
        read_addr: in std_logic_vector(31 downto 0);
        write_addr: in std_logic_vector(31 downto 0);
        write_data: in std_logic_vector(31 downto 0);
        read_data: out std_logic_vector(31 downto 0)
    );
end component;

***/

int ram_file;

initial begin
    int i, j, d;
    int rom_file;

    ram_file = $fopen(filename, "w+");
    $fdisplay(ram_file, "             3  2  1  0");
    if (rom_filename == "") begin
        for (i = 0; i < 'h1000; i += 4) begin
            $fwrite(ram_file, "0x%8h: ", i);

            $fwrite(ram_file, "%2h ", 8'h00);
            $fwrite(ram_file, "%2h ", 8'h00);
            $fwrite(ram_file, "%2h ", 8'h00);
            $fwrite(ram_file, "%2h\n", 8'h00);
        end
        $fflush(ram_file);
    end
    else begin
        rom_file = $fopen(rom_filename, "r");

        for (i = 0; i < 'h1000; i += 4) begin
            $fwrite(ram_file, "0x%8h: ", i);

            for (j = 0; j < 4; j ++) begin
                if ($fscanf(rom_file, "%2h", d) == -1)
                    d = 8'h00;

                if (j < 3)
                    $fwrite(ram_file, "%2h ", d);
                else
                    $fwrite(ram_file, "%2h\n", d);
            end
        end
        $fflush(ram_file);
        $fclose(rom_file);
    end
end


always @(read_addr) begin
    int offset, target;
    int col, row, seek_amount;

    target = read_addr + 0;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[31:24]));

    target = read_addr + 1;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[23:16]));

    target = read_addr + 2;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[15:8]));

    target = read_addr + 3;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[7:0]));
end

always_ff @(posedge clock) begin
    if (write_enable) begin
        int offset, target;
        int col, row, seek_amount;

        target = write_addr + 0;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[31:24]);

        target = write_addr + 1;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[23:16]);

        target = write_addr + 2;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[15:8]);

        target = write_addr + 3;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[7:0]);

        $fflush(ram_file);
    end
end

endmodule
