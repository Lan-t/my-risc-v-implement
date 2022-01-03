library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity Multiplexer8 is
    generic (
        width: integer := XLEN
    );
    port (
        data0, data1, data2, data3: in std_logic_vector(width-1 downto 0);
        data4, data5, data6, data7: in std_logic_vector(width-1 downto 0);
        selector: in std_logic_vector(2 downto 0);
        result: out std_logic_vector(width-1 downto 0)
    );
end Multiplexer8;

architecture rtl of Multiplexer8 is
begin
    result <=
        data0 when selector = "000" else
        data1 when selector = "001" else
        data2 when selector = "010" else
        data3 when selector = "011" else
        data4 when selector = "100" else
        data5 when selector = "101" else
        data6 when selector = "110" else
        data7 when selector = "111" else
        (others => 'X');
end rtl;
