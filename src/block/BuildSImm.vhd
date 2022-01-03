library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity BuildSImm is
    port (
        s_raw_imm: in std_logic_vector(24 downto 0);
        result: out std_logic_vector(XLEN-1 downto 0)
    );
end BuildSImm;

architecture rtl of BuildSImm is
begin

    result <= (
        31 downto 11 => s_raw_imm(24),
        10 downto 5 => s_raw_imm(23 downto 18),
        4 downto 0 => s_raw_imm(4 downto 0)
    );

end architecture;
