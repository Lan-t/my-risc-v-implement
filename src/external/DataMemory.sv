module DataMemory(
    input logic clock,
    input logic[31:0] addr,
    input logic write_enable,
    input logic[31:0] write_data,
    output logic[31:0] read_data
);

int ram_file;

initial begin
    int i;
    ram_file = $fopen("src/external/mem_file/DataRam.txt", "w+");
    $fdisplay(ram_file, "             3  2  1  0");
    for (i = 0; i < 'h1000; i += 4) begin
        $fwrite(ram_file, "0x%8h: ", i);
        $fwrite(ram_file, "%2h ", 8'h00);
        $fwrite(ram_file, "%2h ", 8'h00);
        $fwrite(ram_file, "%2h ", 8'h00);
        $fwrite(ram_file, "%2h\n", 8'h00);
    end
    $fflush(ram_file);
end


always @(addr) begin
    int offset, target;
    int col, row, seek_amount;

    target = addr + 0;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[31-0:24-0]));

    target = addr + 1;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[31-8:24-8]));

    target = addr + 2;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[31-16:24-16]));

    target = addr + 3;
    row = target / 4;
    col = target % 4;
    seek_amount = 24 * (1 + row) + 12 + 3 * col;
    void'($fseek(ram_file, seek_amount, 0));
    void'($fscanf(ram_file, "%2h", read_data[31-24:24-24]));
end

always_ff @(posedge clock) begin
    if (write_enable) begin
        int offset, target;
        int col, row, seek_amount;

        target = addr + 0;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[31:24]);

        target = addr + 1;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[23:16]);

        target = addr + 2;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[15:8]);

        target = addr + 3;
        row = target / 4;
        col = target % 4;
        seek_amount = 24 * (1 + row) + 12 + 3 * col;
        void'($fseek(ram_file, seek_amount, 0));
        $fwrite(ram_file, "%2h", write_data[7:0]);

        $fflush(ram_file);
    end
end

endmodule
