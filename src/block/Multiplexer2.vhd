library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity Multiplexer2 is
    generic (
        width: integer := XLEN
    );
    port (
        data0, data1: in std_logic_vector(width-1 downto 0);
        selector: in std_logic;
        result: out std_logic_vector(width-1 downto 0)
    );
end Multiplexer2;

architecture rtl of Multiplexer2 is
begin
    result <= data0 when selector = '0' else data1;
end rtl;
