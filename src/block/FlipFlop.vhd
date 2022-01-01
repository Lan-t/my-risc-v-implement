library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiskVGlobals.all;

entity FlipFlop is
    generic (
        width: integer := REGISTER_WIDTH
    );
    port (
        clock, reset: in std_logic;
        d: in std_logic_vector(width-1 downto 0);
        q: out std_logic_vector(width-1 downto 0)
    );
end FlipFlop;

architecture rtl of FlipFlop is
begin
    process (clock, reset) begin
        if reset then
            q <= (others => '0');
        elsif rising_edge(clock) then
            q <= d;
        end if;
    end process;
end rtl;
