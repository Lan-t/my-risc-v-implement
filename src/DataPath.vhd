library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity DataPath is
    port (
        clock, reset: in std_logic;
        pc: buffer std_logic_vector(REGISTER_WIDTH-1 downto 0);
        inst: in std_logic_vector(31 downto 0);
        reg_write_enable: in std_logic
    );
end DataPath;

architecture rtl of DataPath is

    component FlipFlop is
        generic (
            width: integer := REGISTER_WIDTH
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
            write_enable: in std_logic;
            write_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
            write_data: in std_logic_vector(REGISTER_WIDTH-1 downto 0)
        );
    end component;
    component Adder is
        generic (
            width: integer := REGISTER_WIDTH
        );
        port (
            a, b: in std_logic_vector(width-1 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component ShiftLeft12 is
        port (
            n: in std_logic_vector(19 downto 0);
            result: out std_logic_vector(31 downto 0)
        );
    end component;

    signal pc_plus4: std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal opcode: std_logic_vector(6 downto 0);
    signal rd: std_logic_vector(4 downto 0);
    signal u_imm: std_logic_vector(19 downto 0);
    signal imm_sl12: std_logic_vector(REGISTER_WIDTH-1 downto 0);

begin

    -- inst
    opcode <= inst(6 downto 0);
    rd <= inst(11 downto 7);
    u_imm <= inst(31 downto 12);

    imm_sl: ShiftLeft12 port map (u_imm, imm_sl12);

    -- PC
    pc_ff: FlipFlop port map (clock, reset, d => pc_plus4, q => pc);
    pc_add4: Adder port map (pc, x"00000004", result => pc_plus4);

    -- Register
    rf: RegisterFile port map (clock,
        write_enable => reg_write_enable,
        write_addr => rd,
        write_data => imm_sl12
    );

end architecture;
