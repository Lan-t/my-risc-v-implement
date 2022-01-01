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
        reg_write_data_sel: in std_logic -- 0: u-imm(<<12)  1: alu result
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
    signal opcode: std_logic_vector(6 downto 0);
    signal funct3: std_logic_vector(2 downto 0);
    signal rs1, rd: std_logic_vector(4 downto 0);
    signal i_imm: std_logic_vector(11 downto 0);
    signal u_imm: std_logic_vector(19 downto 0);
    signal imm_sl12: std_logic_vector(XLEN-1 downto 0);

    signal src_a: std_logic_vector(XLEN-1 downto 0);
    signal i_imm_sx: std_logic_vector(XLEN-1 downto 0);
    signal result: std_logic_vector(XLEN-1 downto 0);
    signal zero: std_logic;

    signal reg_write_data: std_logic_vector(XLEN-1 downto 0);

begin

    -- inst
    opcode <= inst(6 downto 0);
    funct3 <= inst(14 downto 12);
    rs1 <= inst(19 downto 15);
    rd <= inst(11 downto 7);
    i_imm <= inst(31 downto 20);
    u_imm <= inst(31 downto 12);

    imm_sl: ShiftLeft12 port map (u_imm, imm_sl12);

    -- PC
    pc_ff: FlipFlop port map (clock, reset, d => pc_plus4, q => pc);
    pc_add4: Adder port map (pc, x"00000004", result => pc_plus4);

    -- Register
    rf: RegisterFile port map (clock,
        read_addr => rs1,
        read_data => src_a,
        write_enable => reg_write_enable,
        write_addr => rd,
        write_data => reg_write_data
    );

    -- ALU
    main_alu: ALU port map (
        alu_control => funct3,
        a => src_a,
        b => i_imm_sx,
        result => result,
        zero => zero
    );
    imm_sx1: SignExtend port map (i_imm, i_imm_sx);

    -- result
    sel_write_data: Multiplexer2 port map (imm_sl12, result, selector => reg_write_data_sel, result => reg_write_data);

end architecture;
