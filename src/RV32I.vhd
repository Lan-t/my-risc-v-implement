library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity RV32I is
    port (
        clock, reset: in std_logic;
        pc: out std_logic_vector(XLEN-1 downto 0);
        inst: in std_logic_vector(31 downto 0)
    );
end RV32I;

architecture rtl of RV32I is

    component Controller is
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
    end component;
    component DataPath is
        port (
            clock, reset: in std_logic;
            pc: buffer std_logic_vector(XLEN-1 downto 0);
            inst: in std_logic_vector(31 downto 0);
            reg_write_enable: in std_logic;
            reg_write_data_sel: in std_logic_vector(1 downto 0); -- 00: u-imm  01: alu result  10: pc_plus4
            src_a_sel: in std_logic; -- 0: reg_read_data  1: pc
            src_b_sel: in std_logic_vector(1 downto 0); -- 00: i_imm  01: j_imm  10: u_imm
            pc_src_sel: in std_logic;  -- 0: pc_plus4  1: result
            alu_control: in std_logic_vector(2 downto 0)
        );
    end component;

    signal reg_write_enable: std_logic;
    signal reg_write_data_sel: std_logic_vector(1 downto 0);
    signal src_a_sel: std_logic;
    signal src_b_sel: std_logic_vector(1 downto 0);
    signal pc_src_sel: std_logic;

    signal alu_control: std_logic_vector(2 downto 0);

    signal opcode: std_logic_vector(6 downto 0);
    signal funct3: std_logic_vector(2 downto 0);

begin

    opcode <= inst(6 downto 0);
    funct3 <= inst(14 downto 12);

    con: Controller port map (
        opcode => opcode,
        funct3 => funct3,
        reg_write_enable => reg_write_enable,
        reg_write_data_sel => reg_write_data_sel,
        src_a_sel => src_a_sel,
        src_b_sel => src_b_sel,
        pc_src_sel => pc_src_sel,
        alu_control => alu_control
    );
    dp: DataPath port map (clock, reset,
        pc => pc,
        inst => inst,
        reg_write_enable => reg_write_enable,
        reg_write_data_sel => reg_write_data_sel,
        src_a_sel => src_a_sel,
        src_b_sel => src_b_sel,
        pc_src_sel => pc_src_sel,
        alu_control => alu_control
    );

end architecture;
