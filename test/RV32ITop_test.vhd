library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiskVGlobals.all;

entity RV32ITop_test is
end RV32ITop_test;

architecture tb of RV32ITop_test is

    component RV32ITop is
        port (
            clock, reset: in std_logic
        );
    end component;

    signal clock, reset: std_logic;

begin

    DUT: RV32ITop port map (clock, reset);

    process begin
        clock <= '1';
        wait for 5 ns;
        clock <= '0';
        wait for 5 ns;
    end process;

    process begin
        reset <= '0';
        wait for 12 ns;
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
        wait;
    end process;

end architecture;
