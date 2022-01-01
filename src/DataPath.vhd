library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity DataPath is
    port (
        clock, reset: in std_logic;
        pc: buffer std_logic_vector(XLEN-1 downto 0);
        inst: in std_logic_vector(31 downto 0);
        reg_write_enable: in std_logic;
        reg_write_data_sel: in std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
        src_a_sel: in std_logic; -- 0: reg_read_data  1: pc
        src_b_sel: in std_logic; -- 0: i_imm  1: j_imm
        pc_src_sel: in std_logic;  -- 0: pc_plus4  1: result
        alu_control: in std_logic_vector(2 downto 0)
    );
end DataPath;

architecture rtl of DataPath is

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
            clock: in std_logic;
            read_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
            read_data: out std_logic_vector(XLEN-1 downto 0);
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
            alu_control: in std_logic_vector(2 downto 0);
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
    component BuildJImm is
        port (
            j_raw_imm: in std_logic_vector(19 downto 0);
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

    signal pc_plus4: std_logic_vector(XLEN-1 downto 0);
    signal pc_src: std_logic_vector(XLEN-1 downto 0);
    signal opcode: std_logic_vector(6 downto 0);
    signal rs1, rd: std_logic_vector(4 downto 0);
    signal i_raw_imm: std_logic_vector(11 downto 0);
    signal i_imm: std_logic_vector(XLEN-1 downto 0);
    signal u_raw_imm: std_logic_vector(19 downto 0);
    signal u_imm: std_logic_vector(XLEN-1 downto 0);
    signal j_raw_imm: std_logic_vector(19 downto 0);
    signal j_imm: std_logic_vector(XLEN-1 downto 0);

    signal src_a: std_logic_vector(XLEN-1 downto 0);
    signal src_b: std_logic_vector(XLEN-1 downto 0);
    signal result: std_logic_vector(XLEN-1 downto 0);
    signal zero: std_logic;

    signal reg_read_data: std_logic_vector(XLEN-1 downto 0);
    signal reg_write_data: std_logic_vector(XLEN-1 downto 0);

begin

    -- inst
    opcode <= inst(6 downto 0);
    rs1 <= inst(19 downto 15);
    rd <= inst(11 downto 7);
    i_raw_imm <= inst(31 downto 20);
    u_raw_imm <= inst(31 downto 12);
    j_raw_imm <= inst(31 downto 12);

    make_i_imm: SignExtend port map (i_raw_imm, i_imm);
    make_u_imm: ShiftLeft12 port map (u_raw_imm, u_imm);
    make_j_imm: BuildJImm port map (j_raw_imm, j_imm);

    -- PC
    pc_ff: FlipFlop port map (clock, reset, d => pc_src, q => pc);
    pc_add4: Adder port map (pc, x"00000004", result => pc_plus4);
    sel_pc_src: Multiplexer2 port map (pc_plus4, result, selector => pc_src_sel, result => pc_src);

    -- Register
    rf: RegisterFile port map (clock,
        read_addr => rs1,
        read_data => reg_read_data,
        write_enable => reg_write_enable,
        write_addr => rd,
        write_data => reg_write_data
    );

    -- ALU
    main_alu: ALU port map (
        alu_control => alu_control,
        a => src_a,
        b => src_b,
        result => result,
        zero => zero
    );
    sel_src_a: Multiplexer2 port map (reg_read_data, pc, selector => src_a_sel, result => src_a);
    sel_src_b: Multiplexer2 port map (i_imm, j_imm, selector => src_b_sel, result => src_b);

    -- result
    sel_write_data: Multiplexer4 port map (u_imm, result, pc_plus4, x"XXXXXXXX", selector => reg_write_data_sel, result => reg_write_data);

end architecture;
