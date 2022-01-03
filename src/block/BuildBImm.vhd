library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity BuildBImm is
    port (
        b_raw_imm: in std_logic_vector(24 downto 0);
        result: out std_logic_vector(XLEN-1 downto 0)
    );
end BuildBImm;

architecture rtl of BuildBImm is
begin

    result <= (
        31 downto 12 => b_raw_imm(24),
        11 => b_raw_imm(0),
        10 downto 5 => b_raw_imm(23 downto 18),
        4 downto 1 => b_raw_imm(4 downto 1),
        0 => '0'
    );

end architecture;
