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
        src_a_sel: out std_logic; -- 0: reg_read_data1  1: pc
        src_b_sel: out std_logic_vector(2 downto 0); -- 000: i_imm  001: j_imm  010: u_imm  100: reg_read_data2
        pc_sel_signal: out std_logic_vector(1 downto 0);  -- 00: pc_plus4  01: result  10: branch if zero
        alu_control: out std_logic_vector(2 downto 0)
    );
end Controller;

-- +------+---------+--------+------------------+--------------------+-----------+-----------+---------------+-------------+
-- | inst | opcode  | funct3 | reg_write_enable | reg_write_data_sel | src_a_sel | src_b_sel | pc_sel_signal | alu_control |
-- +------+---------+--------+------------------+--------------------+-----------+-----------+---------------+-------------+
-- | lui  | 0110111 |  XXX   |         1        |         00         |     X     |    XXX    |       00      |     XXX     |
-- |op-imm| 0010011 |  aaa   |         1        |         01         |     0     |    000    |       00      |     aaa     |
-- |  op  | 0110011 |  aaa   |         1        |         01         |     0     |    100    |       00      |     aaa     |
-- | jal  | 1101111 |  XXX   |         1        |         10         |     1     |    001    |       01      |     000     |
-- | jalr | 1100111 |  XXX   |         1        |         10         |     0     |    000    |       01      |     000     |
-- |auipc | 0010111 |  XXX   |         1        |         01         |     1     |    010    |       00      |     000     |
-- |branch| 1100011 |  000   |         0        |         XX         |     0     |    100    |       10      |     100     |
-- +------+---------+--------+------------------+--------------------+-----------+-----------+---------------+-------------+

architecture rtl of Controller is
    signal controls: std_logic_vector(11 downto 0);
begin

    controls <=
        "100XXXX00XXX"          when opcode = "0110111" else  -- LUI
        "101000000" & funct3    when opcode = "0010011" else  -- op-imm
        "101010000" & funct3    when opcode = "0110011" else  -- op
        "110100101000"          when opcode = "1101111" else  -- JAL
        "110000001000"          when opcode = "1100111" else  -- JALR
        "101101000000"          when opcode = "0010111" else  -- AUIPC
        "0XX010010100"          when opcode = "1100011" and funct3 = "000" else  -- BEQ
        "XXXXXXXXXXXX";

    (reg_write_enable, reg_write_data_sel, src_a_sel, src_b_sel, pc_sel_signal, alu_control) <= controls;

end architecture;
