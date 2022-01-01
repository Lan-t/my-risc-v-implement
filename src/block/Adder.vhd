library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.RiskVGlobals.all;

entity Adder is
    generic (
        width: integer := XLEN
    );
    port (
        a, b: in std_logic_vector(width-1 downto 0);
        result: out std_logic_vector(width-1 downto 0)
    );
end Adder;

architecture rtl of Adder is
begin

    result <= a + b;

end architecture;
