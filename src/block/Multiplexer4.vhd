library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiskVGlobals.all;

entity Multiplexer4 is
    generic (
        width: integer := XLEN
    );
    port (
        data0, data1, data2, data3: in std_logic_vector(width-1 downto 0);
        selector: in std_logic_vector(1 downto 0);
        result: out std_logic_vector(width-1 downto 0)
    );
end Multiplexer4;

architecture rtl of Multiplexer4 is
begin
    result <=
        data0 when selector = "00" else
        data1 when selector = "01" else
        data2 when selector = "10" else
        data3 when selector = "11" else
        (others => 'X');
end rtl;
