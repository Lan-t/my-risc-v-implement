library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity Controller is
    port (
        opcode: in std_logic_vector(6 downto 0);
        funct3: in std_logic_vector(2 downto 0);
        funct7: in std_logic_vector(6 downto 0);
        reg_write_enable: out std_logic;
        reg_write_data_sel: out std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
        src_a_sel: out std_logic; -- 0: reg_read_data1  1: pc
        src_b_sel: out std_logic_vector(2 downto 0); -- 000: i_imm  001: j_imm  010: u_imm  011: s_imm  100: reg_read_data2
        pc_sel_signal: out std_logic_vector(1 downto 0);  -- 00: pc_plus4  01: result  10: branch if zero
        mem_write_enable: out std_logic;
        result_sel: out std_logic; -- 0: alu_result  1: mem_read_data
        alu_control: out std_logic_vector(3 downto 0)
    );
end Controller;

-- +------+---------+--------+-----------+------------------+--------------------+-----------+-----------+---------------+------------------+------------+-------------+
-- | inst | opcode  | funct3 | funct7(5) | reg_write_enable | reg_write_data_sel | src_a_sel | src_b_sel | pc_sel_signal | mem_write_enable | result_sel | alu_control |
-- +------+---------+--------+-----------+------------------+--------------------+-----------+-----------+---------------+------------------+------------+-------------+
-- | lui  | 0110111 |  XXX   |     X     |         1        |         00         |     X     |    XXX    |       00      |        0         |      0     |    XXXX     |
-- | rs*i | 0010011 |  101   |     b     |         1        |         01         |     0     |    000    |       00      |        0         |      0     |    baaa     |
-- |op-imm| 0010011 |  aaa   |     X     |         1        |         01         |     0     |    000    |       00      |        0         |      0     |    0aaa     |
-- |  op  | 0110011 |  aaa   |     b     |         1        |         01         |     0     |    100    |       00      |        0         |      0     |    baaa     |
-- | jal  | 1101111 |  XXX   |     X     |         1        |         10         |     1     |    001    |       01      |        0         |      0     |    0000     |
-- | jalr | 1100111 |  XXX   |     X     |         1        |         10         |     0     |    000    |       01      |        0         |      0     |    0000     |
-- |auipc | 0010111 |  XXX   |     X     |         1        |         01         |     1     |    010    |       00      |        0         |      0     |    0000     |
-- |branch| 1100011 |  000   |     X     |         0        |         XX         |     0     |    100    |       10      |        0         |      0     |    0100     |
-- |  sw  | 0100011 |  010   |     X     |         0        |         XX         |     0     |    011    |       00      |        1         |      X     |    0000     |
-- |  lw  | 0000011 |  010   |     X     |         1        |         01         |     0     |    000    |       00      |        0         |      1     |    0000     |
-- +------+---------+--------+-----------+------------------+--------------------+-----------+-----------+---------------+------------------+------------+-------------+

architecture rtl of Controller is
    signal controls: std_logic_vector(14 downto 0);
begin

    controls <=
        "100XXXX0000XXXX"                   when opcode = "0110111" else  -- LUI
        "10100000000" & funct7(5) & funct3  when opcode = "0010011" and funct3 = "101" else  -- right shift imm
        "101000000000" & funct3  when opcode = "0010011" else  -- op-imm
        "10101000000" & funct7(5) & funct3  when opcode = "0110011" else  -- op
        "110100101000000"                   when opcode = "1101111" else  -- JAL
        "110000001000000"                   when opcode = "1100111" else  -- JALR
        "101101000000000"                   when opcode = "0010111" else  -- AUIPC
        "0XX010010000100"                   when opcode = "1100011" and funct3 = "000" else  -- BEQ
        "0XX0011001X0000"                   when opcode = "0100011" and funct3 = "010" else  -- SW
        "101000000010000"                   when opcode = "0000011" and funct3 = "010" else  -- LW
        "XXXXXXXXXXXXXXX";

    (reg_write_enable, reg_write_data_sel, src_a_sel, src_b_sel, pc_sel_signal, mem_write_enable, result_sel, alu_control) <= controls;

end architecture;
