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
        alu_zero, alu_result_0: in std_logic;
        src_a_sel: out std_logic; -- 0: reg_read_data1  1: pc
        src_b_sel: out std_logic_vector(2 downto 0); -- 000: i_imm  001: s_imm  010: u_imm  011: j_imm  100: reg_read_data2
        alu_con: out std_logic_vector(3 downto 0);
        result_sel: out std_logic; -- 0: alu_result  1: mem_read_data
        reg_w_en: out std_logic;
        reg_w_sel: out std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
        mem_w_en: out std_logic;
        pc_sel: out std_logic_vector(1 downto 0)  -- 00: pc_plus4  01: result  10: branch
    );
end Controller;

architecture rtl of Controller is

    component BranchController is
        port (
            pc_sel_sig: in std_logic_vector(1 downto 0);
            funct3: in std_logic_vector(2 downto 0);
            alu_zero, alu_result_0: in std_logic;
            pc_sel: out std_logic_vector(1 downto 0)
        );
    end component;
    component MainController is
        port (
            opcode: in std_logic_vector(6 downto 0);
            funct3: in std_logic_vector(2 downto 0);
            funct7: in std_logic_vector(6 downto 0);
            src_a_sel: out std_logic; -- 0: reg_read_data1  1: pc
            src_b_sel: out std_logic_vector(2 downto 0); -- 000: i_imm  001: s_imm  010: u_imm  011: j_imm  100: reg_read_data2
            alu_con: out std_logic_vector(3 downto 0);
            result_sel: out std_logic; -- 0: alu_result  1: mem_read_data
            reg_w_en: out std_logic;
            reg_w_sel: out std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
            mem_w_en: out std_logic;
            pc_sel_sig: out std_logic_vector(1 downto 0)  -- 00: pc_plus4  01: result  10: branch if true
        );
    end component;

    signal pc_sel_sig: std_logic_vector(1 downto 0);

begin

    main: MainController port map (
        opcode, funct3, funct7, src_a_sel, src_b_sel,
        alu_con, result_sel, reg_w_en, reg_w_sel, mem_w_en, pc_sel_sig
    );

    branch: BranchController port map (
        pc_sel_sig, funct3, alu_zero, alu_result_0, pc_sel
    );

end architecture;


--------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;


entity MainController is
    port (
        opcode: in std_logic_vector(6 downto 0);
        funct3: in std_logic_vector(2 downto 0);
        funct7: in std_logic_vector(6 downto 0);
        src_a_sel: out std_logic; -- 0: reg_read_data1  1: pc
        src_b_sel: out std_logic_vector(2 downto 0); -- 000: i_imm  001: s_imm  010: u_imm  011: j_imm  100: reg_read_data2
        alu_con: out std_logic_vector(3 downto 0);
        result_sel: out std_logic; -- 0: alu_result  1: mem_read_data
        reg_w_en: out std_logic;
        reg_w_sel: out std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
        mem_w_en: out std_logic;
        pc_sel_sig: out std_logic_vector(1 downto 0)  -- 00: pc_plus4  01: result  10: branch if true
    );
end MainController;

-- +------+---+---------+-----+-------+---+-----+------+-----+------+--------+--------+-------+
-- | inst | F | opcode  | f3  | f7(5) | a |  b  | alu  | res | r_we | r_wsel | mem_we | pcsig |
-- +------+---+---------+-----+-------+---+-----+------+-----+------+--------+--------+-------+
-- |op-imm| I | 0010011 | aaa |   -   | 0 | 000 | 0aaa |  0  |  1   |   01   |   0    |   00  |
-- | rs*i | I | 0010011 | 101 |   b   | 0 | 000 | b101 |  0  |  1   |   01   |   0    |   00  |  -- op-imm: right shift
-- | lui  | U | 0110111 | --- |   -   | X | 010 | XXXX |  0  |  1   |   00   |   0    |   00  |
-- |auipc | U | 0010111 | --- |   -   | 1 | 010 | 0000 |  0  |  1   |   01   |   0    |   00  |
-- |  op  | R | 0110011 | aaa |   b   | 0 | 100 | baaa |  0  |  1   |   01   |   0    |   00  |
-- | jal  | J | 1101111 | --- |   -   | 1 | 011 | 0000 |  0  |  1   |   10   |   0    |   01  |
-- | jalr | I | 1100111 | --- |   -   | 0 | 000 | 0000 |  0  |  1   |   10   |   0    |   01  |
-- |branch| B | 1100011 | aaa |   -   | 0 | 100 | (  ) |  0  |  0   |   XX   |   0    |   10  |  -- (  ): '0' & not(2) & (2) & (1)  -- 下表
-- |  lw  | I | 0000011 | 010 |   -   | 0 | 000 | 0000 |  1  |  1   |   01   |   0    |   00  |
-- |  sw  | S | 0100011 | 010 |   -   | 0 | 001 | 0000 |  X  |  0   |   XX   |   1    |   00  |
-- +------+---+---------+-----+-------+---+-----+------+-----+------+--------+--------+-------+

architecture rtl of MainController is
    signal controles: std_logic_vector(14 downto 0);
begin

    process (all) begin
        case? opcode & funct3 & funct7(5) is
            when "0010011----" =>
                if funct3 = "101" then
                    controles <= "0000" & funct7(5) & "1010101000";  -- right shift
                else
                    controles <= "00000" & funct3 & "0101000";  -- op-imm
                end if;
            when "0110111----" => controles <= "X010XXXX0100000";
            when "0010111----" => controles <= "101000000101000";
            when "0110011----" => controles <= "0100" & funct7(5) & funct3 & "0101000";
            when "1101111----" => controles <= "101100000110001";
            when "1100111----" => controles <= "000000000110001";
            when "1100011----" => controles <= "0100" & '0' & not funct3(2) & funct3(2) & funct3(1) & "00XX010";
            when "0000011010-" => controles <= "000000001101000";
            when "0100011010-" => controles <= "00010000X0XX100";
            when others => controles <= "XXXXXXXXXXXXXXX";
        end case?;
    end process;

    (src_a_sel, src_b_sel, alu_con, result_sel, reg_w_en, reg_w_sel, mem_w_en, pc_sel_sig) <= controles;

end architecture;


-- alu_con at branch
-- +------+-----+---------+
-- | inst | f3  | alu_con |
-- +------+-----+---------+
-- | beq  | 000 |  0100   | xor
-- | bne  | 001 |  0100   |
-- | blt  | 100 |  0010   | slt
-- | bge  | 101 |  0010   |
-- | bltu | 110 |  0011   | sltu
-- | bgeu | 111 |  0011   |
-- +------+-----+---------+
-- => alu_con => '0' & not(2) & (2) & (1)


--------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity BranchController is
    port (
        pc_sel_sig: in std_logic_vector(1 downto 0);
        funct3: in std_logic_vector(2 downto 0);
        alu_zero, alu_result_0: in std_logic;
        pc_sel: out std_logic_vector(1 downto 0)
    );
end BranchController;

architecture rtl of BranchController is
begin

    process (all) begin
        case pc_sel_sig is
            when "00" => pc_sel <= "00";
            when "01" => pc_sel <= "01";
            when "10" =>
                pc_sel(0) <= '0';
                case funct3 is
                    when "000" => pc_sel(1) <= alu_zero;
                    when "001" => pc_sel(1) <= not alu_zero;
                    when "100" => pc_sel(1) <= alu_result_0;
                    when "101" => pc_sel(1) <= not alu_result_0;
                    when "110" => pc_sel(1) <= alu_result_0;
                    when "111" => pc_sel(1) <= not alu_result_0;
                    when others => pc_sel(1) <= 'X';
                end case;
            when others => pc_sel <= "XX";
        end case;
    end process;

end architecture;


-- pc_sel table
-- +------+------+-----------+
-- | inst |funct3| pc_sel(1) |
-- +------+------+-----------+
-- | beq  | 000  |  zero     |
-- | bne  | 001  |  not zero |
-- | blt  | 100  |  r0       |
-- | bge  | 101  |  not r0   |
-- | bltu | 110  |  r0       |
-- | bgeu | 111  |  not r0   |
-- +------+------+-----------+
