library ieee;
use ieee.std_logic_1164.all;

entity SignExtend is
    generic (
        input_width: integer := 12;
        output_width: integer := 32
    );
    port (
        n: in std_logic_vector(input_width-1 downto 0);
        result: out std_logic_vector(output_width-1 downto 0)
    );
end SignExtend;

architecture rtl of SignExtend is
begin

    result <= x"fffff" & n when n(input_width-1) else x"00000" & n;

end architecture; -- rtl
