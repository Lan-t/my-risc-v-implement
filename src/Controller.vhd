library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity Controller is
    port (
        opcode: in std_logic_vector(6 downto 0);
        funct3: in std_logic_vector(2 downto 0);
        reg_write_enable: out std_logic;
        reg_write_data_sel: out std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
        src_a_sel: out std_logic; -- 0: reg_read_data  1: pc
        src_b_sel: out std_logic_vector(1 downto 0); -- 00: i_imm  01: j_imm  10: u_imm
        pc_src_sel: out std_logic;  -- 0: pc_plus4  1: result
        alu_control: out std_logic_vector(2 downto 0)
    );
end Controller;

-- +------+---------+--------+------------------+--------------------+-----------+-----------+------------+-------------+
-- | inst | opcode  | funct3 | reg_write_enable | reg_write_data_sel | src_a_sel | src_b_sel | pc_src_sel | alu_control |
-- +------+---------+--------+------------------+--------------------+-----------+-----------+------------+-------------+
-- | lui  | 0110111 |  XXX   |         1        |         00         |     X     |    XX     |      0     |     XXX     |
-- |op-imm| 0010011 |  aaa   |         1        |         01         |     0     |    00     |      0     |     aaa     |
-- | jal  | 1101111 |  XXX   |         1        |         10         |     1     |    01     |      1     |     000     |
-- | jalr | 1100111 |  XXX   |         1        |         10         |     0     |    00     |      1     |     000     |
-- |auipc | 0010111 |  XXX   |         1        |         01         |     1     |    10     |      0     |     000     |
-- +------+---------+--------+------------------+--------------------+-----------+-----------+------------+-------------+

architecture rtl of Controller is
    signal controls: std_logic_vector(9 downto 0);
begin

    controls <=
        "100XXX0XXX" when opcode = "0110111" else  -- LUI
        "1010000" & funct3 when opcode = "0010011" else  -- op-imm
        "1101011000" when opcode = "1101111" else  -- JAL
        "1100001000" when opcode = "1100111" else  -- JALR
        "1011100000" when opcode = "0010111" else  -- AUIPC
        "XXXXXXXXXX";

    (reg_write_enable, reg_write_data_sel, src_a_sel, src_b_sel, pc_src_sel, alu_control) <= controls;

end architecture;
