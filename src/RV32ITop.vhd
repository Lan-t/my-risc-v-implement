library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiskVGlobals.all;

entity RV32ITop is
    port (
        clock, reset: in std_logic
    );
end RV32ITop;

architecture rtl of RV32ITop is

    component RV32I is
        port (
            clock, reset: in std_logic;
            pc: out std_logic_vector(REGISTER_WIDTH-1 downto 0);
            inst: in std_logic_vector(31 downto 0)
        );
    end component;
    component InstructionMemory is
        port (
            addr: in std_logic_vector(REGISTER_WIDTH-1 downto 0);
            inst: out std_logic_vector(31 downto 0)
        );
    end component;

    signal pc: std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal inst: std_logic_vector(31 downto 0);

begin

    rv: RV32I port map (clock, reset, pc, inst);
    im: InstructionMemory port map (pc, inst);

end architecture;