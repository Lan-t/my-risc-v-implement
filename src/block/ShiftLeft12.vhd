library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiskVGlobals.all;

entity ShiftLeft12 is
    port (
        n: in std_logic_vector(19 downto 0);
        result: out std_logic_vector(31 downto 0)
    );
end ShiftLeft12;

architecture rtl of ShiftLeft12 is
begin

    result <= n & x"000";

end architecture;
