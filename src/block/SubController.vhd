library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity SubController is
    port (
        pc_sel_signal: in std_logic_vector(1 downto 0);
        alu_zero: in std_logic;
        pc_src_sel: out std_logic_vector(1 downto 0)
    );
end SubController;

-- +---------------+----------+------------+
-- | pc_sel_signal | alu_zero | pc_src_sel |
-- +---------------+----------+------------+
-- |       00      |     X    |     00     |
-- |       01      |     X    |     01     |
-- |       10      |     0    |     00     |
-- |       10      |     1    |     10     |
-- +---------------+----------+------------+

architecture rtl of SubController is
begin

    pc_src_sel <=
        "00" when pc_sel_signal = "00" else
        "01" when pc_sel_signal = "01" else
        "00" when pc_sel_signal = "10" and alu_zero = '0' else
        "10" when pc_sel_signal = "10" and alu_zero = '1' else
        "00";

end architecture;
