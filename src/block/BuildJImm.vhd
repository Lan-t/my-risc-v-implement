library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiskVGlobals.all;

entity BuildJImm is
    port (
        j_raw_imm: in std_logic_vector(19 downto 0);
        result: out std_logic_vector(XLEN-1 downto 0)
    );
end BuildJImm;

architecture rtl of BuildJImm is
begin

    result <= (
        31 downto 20 => j_raw_imm(19),
        19 downto 12 => j_raw_imm(7 downto 0),
        11 => j_raw_imm(8),
        10 downto 1 => j_raw_imm(18 downto 9),
        0 => '0'
    );

end architecture;
