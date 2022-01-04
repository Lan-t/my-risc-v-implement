library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity DataPath is
    port (
        clock, reset: in std_logic;
        pc: buffer std_logic_vector(XLEN-1 downto 0);
        inst: in std_logic_vector(31 downto 0);
        mem_addr: out std_logic_vector(31 downto 0);
        mem_write_data: out std_logic_vector(31 downto 0);
        mem_read_data: in std_logic_vector(31 downto 0);
        reg_write_enable: in std_logic;
        reg_write_data_sel: in std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
        src_a_sel: in std_logic; -- 0: reg_read_data1  1: pc
        src_b_sel: in std_logic_vector(2 downto 0); -- 000: i_imm  001: j_imm  010: u_imm  011: s_imm  100: reg_read_data2
        pc_sel_signal: in std_logic_vector(1 downto 0);  -- 00: pc_plus4  01: result  10: branch if true
        branch_cond_sel: in std_logic_vector(1 downto 0);  -- 00: zero  01: not zero  10: result(0)  11: not result(0)
        result_sel: in std_logic; -- 0: alu_result  1: mem_read_data
        alu_control: in std_logic_vector(3 downto 0)
    );
end DataPath;

architecture rtl of DataPath is


    component SubController is
        port (
            pc_sel_signal: in std_logic_vector(1 downto 0);
            branch_cond_sel: in std_logic_vector(1 downto 0);
            alu_zero: in std_logic;
            alu_result0: in std_logic;
            pc_src_sel: out std_logic_vector(1 downto 0)
        );
    end component;

    component FlipFlop is
        generic (
            width: integer := XLEN
        );
        port (
            clock, reset: in std_logic;
            d: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component RegisterFile is
        port (
            clock, reset: in std_logic;
            read_addr1, read_addr2: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
            read_data1, read_data2: out std_logic_vector(XLEN-1 downto 0);
            write_enable: in std_logic;
            write_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
            write_data: in std_logic_vector(XLEN-1 downto 0)
        );
    end component;
    component ALU is
        generic (
            width: integer := XLEN
        );
        port (
            alu_control: in std_logic_vector(3 downto 0);
            a, b: in std_logic_vector(width-1 downto 0);
            result: buffer std_logic_vector(width-1 downto 0);
            zero: out std_logic
        );
    end component;
    component Adder is
        generic (
            width: integer := XLEN
        );
        port (
            a, b: in std_logic_vector(width-1 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component BuildBImm is
        port (
            b_raw_imm: in std_logic_vector(24 downto 0);
            result: out std_logic_vector(XLEN-1 downto 0)
        );
    end component;
    component BuildJImm is
        port (
            j_raw_imm: in std_logic_vector(19 downto 0);
            result: out std_logic_vector(XLEN-1 downto 0)
        );
    end component;
    component BuildSImm is
        port (
            s_raw_imm: in std_logic_vector(24 downto 0);
            result: out std_logic_vector(XLEN-1 downto 0)
        );
    end component;
    component Multiplexer2 is
        generic (
            width: integer := XLEN
        );
        port (
            data0, data1: in std_logic_vector(width-1 downto 0);
            selector: in std_logic;
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component Multiplexer4 is
        generic (
            width: integer := XLEN
        );
        port (
            data0, data1, data2, data3: in std_logic_vector(width-1 downto 0);
            selector: in std_logic_vector(1 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component Multiplexer8 is
        generic (
            width: integer := XLEN
        );
        port (
            data0, data1, data2, data3: in std_logic_vector(width-1 downto 0);
            data4, data5, data6, data7: in std_logic_vector(width-1 downto 0);
            selector: in std_logic_vector(2 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component ShiftLeft12 is
        port (
            n: in std_logic_vector(19 downto 0);
            result: out std_logic_vector(31 downto 0)
        );
    end component;
    component SignExtend is
        generic (
            input_width: integer := 12;
            output_width: integer := 32
        );
        port (
            n: in std_logic_vector(input_width-1 downto 0);
            result: out std_logic_vector(output_width-1 downto 0)
        );
    end component;

    signal pc_plus4, pc_src, pc_branch: std_logic_vector(XLEN-1 downto 0);
    signal pc_src_sel: std_logic_vector(1 downto 0);

    signal opcode: std_logic_vector(6 downto 0);
    signal rs1, rs2, rd: std_logic_vector(4 downto 0);
    signal i_raw_imm: std_logic_vector(11 downto 0);
    signal i_imm: std_logic_vector(XLEN-1 downto 0);
    signal b_raw_imm: std_logic_vector(24 downto 0);
    signal b_imm: std_logic_vector(XLEN-1 downto 0);
    signal u_raw_imm: std_logic_vector(19 downto 0);
    signal u_imm: std_logic_vector(XLEN-1 downto 0);
    signal j_raw_imm: std_logic_vector(19 downto 0);
    signal j_imm: std_logic_vector(XLEN-1 downto 0);
    signal s_raw_imm: std_logic_vector(24 downto 0);
    signal s_imm: std_logic_vector(XLEN-1 downto 0);

    signal src_a: std_logic_vector(XLEN-1 downto 0);
    signal src_b: std_logic_vector(XLEN-1 downto 0);
    signal alu_result: std_logic_vector(XLEN-1 downto 0);
    signal result: std_logic_vector(XLEN-1 downto 0);
    signal zero: std_logic;

    signal reg_read_data1: std_logic_vector(XLEN-1 downto 0);
    signal reg_read_data2: std_logic_vector(XLEN-1 downto 0);
    signal reg_write_data: std_logic_vector(XLEN-1 downto 0);

begin

    -- inst, imm
    opcode <= inst(6 downto 0);
    rs1 <= inst(19 downto 15);
    rs2 <= inst(24 downto 20);
    rd <= inst(11 downto 7);
    i_raw_imm <= inst(31 downto 20);
    b_raw_imm <= inst(31 downto 7);
    u_raw_imm <= inst(31 downto 12);
    j_raw_imm <= inst(31 downto 12);
    s_raw_imm <= inst(31 downto 7);

    make_i_imm: SignExtend port map (i_raw_imm, i_imm);
    make_b_imm: BuildBImm port map (b_raw_imm, b_imm);
    make_u_imm: ShiftLeft12 port map (u_raw_imm, u_imm);
    make_j_imm: BuildJImm port map (j_raw_imm, j_imm);
    make_s_imm: BuildSImm port map (s_raw_imm, s_imm);

    -- memory

    mem_addr <= alu_result;
    mem_write_data <= reg_read_data2;

    -- PC
    pc_ff: FlipFlop port map (clock, reset, d => pc_src, q => pc);
    pc_add4: Adder port map (pc, x"00000004", result => pc_plus4);
    pc_addbr: Adder port map (pc, b_imm, result => pc_branch);
    sel_pc_src: Multiplexer4 port map (pc_plus4, result, pc_branch, x"XXXXXXXX", selector => pc_src_sel, result => pc_src);

    subcon: SubController port map (
        pc_sel_signal => pc_sel_signal,
        branch_cond_sel => branch_cond_sel,
        alu_zero => zero,
        alu_result0 => alu_result(0),
        pc_src_sel => pc_src_sel
    );

    -- Register
    rf: RegisterFile port map (clock, reset,
        read_addr1 => rs1,
        read_data1 => reg_read_data1,
        read_addr2 => rs2,
        read_data2 => reg_read_data2,
        write_enable => reg_write_enable,
        write_addr => rd,
        write_data => reg_write_data
    );

    -- ALU
    main_alu: ALU port map (
        alu_control => alu_control,
        a => src_a,
        b => src_b,
        result => alu_result,
        zero => zero
    );
    sel_src_a: Multiplexer2 port map (reg_read_data1, pc, selector => src_a_sel, result => src_a);
    sel_src_b: Multiplexer8 port map (
        i_imm, j_imm, u_imm, s_imm,
        reg_read_data2, x"XXXXXXXX", x"XXXXXXXX", x"XXXXXXXX",
        selector => src_b_sel, result => src_b
    );

    -- result
    sel_write_data: Multiplexer4 port map (u_imm, result, pc_plus4, x"XXXXXXXX", selector => reg_write_data_sel, result => reg_write_data);

    sel_result: Multiplexer2 port map (alu_result, mem_read_data, selector => result_sel, result => result);

end architecture;
