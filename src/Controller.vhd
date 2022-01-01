library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity Controller is
    port (
        opcode: in std_logic_vector(6 downto 0);
        reg_write_enable: out std_logic
    );
end Controller;

-- +---------+------------------+
-- | opcode  | reg_write_enable |
-- +---------+------------------+
-- | 0110111 |         1        |
-- +---------+------------------+

architecture rtl of Controller is
    signal controls: std_logic_vector(0 downto 0);
begin

    controls <=
        "1" when opcode = "0110111" else  -- LUI
        "X";

    -- (reg_write_enable) <= controls;
    reg_write_enable <= controls(0);

end architecture;
