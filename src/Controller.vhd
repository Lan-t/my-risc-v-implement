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
        pc_sel_signal: out std_logic_vector(1 downto 0);  -- 00: pc_plus4  01: result  10: branch if true
        branch_cond_sel: out std_logic_vector(1 downto 0);  -- 00: zero  01: not zero  10: result(0)  11: not result(0)
        mem_write_enable: out std_logic;
        result_sel: out std_logic; -- 0: alu_result  1: mem_read_data
        alu_control: out std_logic_vector(3 downto 0)
    );
end Controller;

-- +------+---------+--------+-----------+------------------+--------------------+-----------+-----------+---------------+-----------------+------------------+------------+-------------+
-- | inst | opcode  | funct3 | funct7(5) | reg_write_enable | reg_write_data_sel | src_a_sel | src_b_sel | pc_sel_signal | branch_cond_sel | mem_write_enable | result_sel | alu_control |
-- +------+---------+--------+-----------+------------------+--------------------+-----------+-----------+---------------+-----------------+------------------+------------+-------------+
-- | lui  | 0110111 |  XXX   |     X     |         1        |         00         |     X     |    XXX    |       00      |        XX       |        0         |      0     |    XXXX     |
-- | rs*i | 0010011 |  101   |     b     |         1        |         01         |     0     |    000    |       00      |        XX       |        0         |      0     |    baaa     |
-- |op-imm| 0010011 |  aaa   |     X     |         1        |         01         |     0     |    000    |       00      |        XX       |        0         |      0     |    0aaa     |
-- |  op  | 0110011 |  aaa   |     b     |         1        |         01         |     0     |    100    |       00      |        XX       |        0         |      0     |    baaa     |
-- | jal  | 1101111 |  XXX   |     X     |         1        |         10         |     1     |    001    |       01      |        XX       |        0         |      0     |    0000 add |
-- | jalr | 1100111 |  XXX   |     X     |         1        |         10         |     0     |    000    |       01      |        XX       |        0         |      0     |    0000 add |
-- |auipc | 0010111 |  XXX   |     X     |         1        |         01         |     1     |    010    |       00      |        XX       |        0         |      0     |    0000 add |
-- | beq  | 1100011 |  000   |     X     |         0        |         XX         |     0     |    100    |       10      |        00       |        0         |      0     |    0100 xor | -
-- | bne  | 1100011 |  001   |     X     |         0        |         XX         |     0     |    100    |       10      |        01       |        0         |      0     |    0100 xor |  |
-- | blt  | 1100011 |  100   |     X     |         0        |         XX         |     0     |    100    |       10      |        10       |        0         |      0     |    0010 slt |  |- funct3からbranch_cond_sel,alu_controlを出す
-- | bge  | 1100011 |  101   |     X     |         0        |         XX         |     0     |    100    |       10      |        11       |        0         |      0     |    0010 slt |  |   (下表)
-- | bltu | 1100011 |  110   |     X     |         0        |         XX         |     0     |    100    |       10      |        10       |        0         |      0     |    0011 sltu|  |
-- | bgeu | 1100011 |  111   |     X     |         0        |         XX         |     0     |    100    |       10      |        11       |        0         |      0     |    0011 sltu| -
-- |  sw  | 0100011 |  010   |     X     |         0        |         XX         |     0     |    011    |       00      |        XX       |        1         |      X     |    0000 add |
-- |  lw  | 0000011 |  010   |     X     |         1        |         01         |     0     |    000    |       00      |        XX       |        0         |      1     |    0000 add |
-- +------+---------+--------+-----------+------------------+--------------------+-----------+-----------+---------------+-----------------+------------------+------------+-------------+

architecture rtl of Controller is
    signal controls: std_logic_vector(16 downto 0);
begin

    controls <=
        "100XXXX00XX00XXXX"                   when opcode = "0110111" else  -- LUI
        "101000000XX00" & funct7(5) & funct3  when opcode = "0010011" and funct3 = "101" else  -- right shift imm
        "101000000XX000" & funct3  when opcode = "0010011" else  -- op-imm
        "101010000XX00" & funct7(5) & funct3  when opcode = "0110011" else  -- op
        "110100101XX000000"                   when opcode = "1101111" else  -- JAL
        "110000001XX000000"                   when opcode = "1100111" else  -- JALR
        "101101000XX000000"                   when opcode = "0010111" else  -- AUIPC
        "0XX010010" & (funct3(2), funct3(0)) & "00" & ('0', not funct3(2), funct3(2), funct3(1)) when opcode = "1100011" else  -- branch
        "0XX001100XX1X0000"                   when opcode = "0100011" and funct3 = "010" else  -- SW
        "101000000XX010000"                   when opcode = "0000011" and funct3 = "010" else  -- LW
        "XXXXXXXXXXXXXXXXX";

    (reg_write_enable, reg_write_data_sel, src_a_sel, src_b_sel, pc_sel_signal, branch_cond_sel, mem_write_enable, result_sel, alu_control) <= controls;

end architecture;


-- branch

-- +------+------+---------------+-----------+
-- | inst |funct3|branch_cond_sel|alu_control|
-- +------+------+---------------+-----------+
-- | beq  | 000  |      00       |   0100    |
-- | bne  | 001  |      01       |   0100    |
-- | blt  | 100  |      10       |   0010    |
-- | bge  | 101  |      11       |   0010    |
-- | bltu | 110  |      10       |   0011    |
-- | bgeu | 111  |      11       |   0011    |
-- +------+------+---------------+-----------+

-- => branch_cond_sel = (2) & (0)
-- => alu_control => '0' & not(2) & (2) & (1)
