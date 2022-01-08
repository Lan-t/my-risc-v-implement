library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity RV32I is
    port (
        clock, reset: in std_logic;
        pc: out std_logic_vector(XLEN-1 downto 0);
        inst: in std_logic_vector(31 downto 0);
        mem_addr: out std_logic_vector(31 downto 0);
        mem_w_en: out std_logic;
        mem_w_data: out std_logic_vector(31 downto 0);
        mem_r_data: in std_logic_vector(31 downto 0)
    );
end RV32I;

architecture rtl of RV32I is

    component Controller is
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
    end component;
    component DataPath is
        port (
            clock, reset: in std_logic;
            pc: out std_logic_vector(XLEN-1 downto 0);
            inst: in std_logic_vector(XLEN-1 downto 0);
            src_a_sel: in std_logic;  -- 0: reg_read_data1  1: pc
            src_b_sel: in std_logic_vector(2 downto 0); -- 000: i_imm  001: s_imm  010: u_imm  011: j_imm  100: reg_read_data2
            alu_con: in std_logic_vector(3 downto 0);
            result_sel: in std_logic; -- 0: alu_result  1: mem_read_data
            reg_w_en: in std_logic;
            reg_w_sel: in std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
            pc_sel: in std_logic_vector(1 downto 0);  -- 00: pc_plus4  01: result  10: branch
            mem_r_data: in std_logic_vector(XLEN-1 downto 0);

            alu_zero, alu_result_0: out std_logic;
            mem_addr: out std_logic_vector(XLEN-1 downto 0);
            mem_w_data: out std_logic_vector(XLEN-1 downto 0)
        );
    end component;

    signal reg_w_en: std_logic;
    signal reg_w_sel: std_logic_vector(1 downto 0);
    signal src_a_sel: std_logic;
    signal src_b_sel: std_logic_vector(2 downto 0);
    signal pc_sel: std_logic_vector(1 downto 0);
    signal result_sel: std_logic;
    signal alu_con: std_logic_vector(3 downto 0);

    signal alu_zero, alu_result_0: std_logic;

    signal opcode: std_logic_vector(6 downto 0);
    signal funct3: std_logic_vector(2 downto 0);
    signal funct7: std_logic_vector(6 downto 0);

begin

    opcode <= inst(6 downto 0);
    funct3 <= inst(14 downto 12);
    funct7 <= inst(31 downto 25);

    con: Controller port map (
        opcode => opcode,
        funct3 => funct3,
        funct7 => funct7,
        alu_zero => alu_zero,
        alu_result_0 => alu_result_0,

        src_a_sel => src_a_sel,
        src_b_sel => src_b_sel,
        alu_con => alu_con,
        result_sel => result_sel,
        reg_w_en => reg_w_en,
        reg_w_sel => reg_w_sel,
        mem_w_en => mem_w_en,
        pc_sel => pc_sel
    );
    dp: DataPath port map (clock, reset,
        pc => pc,
        inst => inst,

        src_a_sel => src_a_sel,
        src_b_sel => src_b_sel,
        alu_con => alu_con,
        result_sel => result_sel,
        reg_w_en => reg_w_en,
        reg_w_sel => reg_w_sel,
        pc_sel => pc_sel,
        mem_r_data => mem_r_data,

        alu_zero => alu_zero,
        alu_result_0 => alu_result_0,
        mem_addr => mem_addr,
        mem_w_data => mem_w_data
    );

end architecture;
