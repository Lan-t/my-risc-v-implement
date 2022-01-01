library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity Controller is
    port (
        opcode: in std_logic_vector(6 downto 0);
        reg_write_enable: out std_logic;
        reg_write_data_sel: out std_logic -- 0: u-imm(<<12)  1: alu result
    );
end Controller;

-- +------+---------+--------+------------------+--------------------+
-- | inst | opcode  | funct3 | reg_write_enable | reg_write_data_sel |
-- +------+---------+--------+------------------+--------------------+
-- | lui  | 0110111 |  XXX   |         1        |          0         |
-- |op-imm| 0010011 |  000   |         1        |          1         |
-- +------+---------+--------+------------------+--------------------+

architecture rtl of Controller is
    signal controls: std_logic_vector(1 downto 0);
begin

    controls <=
        "10" when opcode = "0110111" else  -- LUI
        "11" when opcode = "0010011" else  -- op-imm
        "XX";

    (reg_write_enable, reg_write_data_sel) <= controls;

end architecture;
