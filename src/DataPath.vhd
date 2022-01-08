library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity DataPath is
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
end DataPath;


architecture rtl of DataPath is

    component FlipFlop is
        generic (
            width: integer := XLEN
        );
        port (
            clock, reset: in std_logic;
            d: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component RegisterFile is
        port (
            clock, reset: in std_logic;
            read_addr1, read_addr2: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
            read_data1, read_data2: out std_logic_vector(XLEN-1 downto 0);
            write_enable: in std_logic;
            write_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
            write_data: in std_logic_vector(XLEN-1 downto 0)
        );
    end component;
    component ALU is
        generic (
            width: integer := XLEN
        );
        port (
            controle: in std_logic_vector(3 downto 0);
            a, b: in std_logic_vector(width-1 downto 0);
            result: buffer std_logic_vector(width-1 downto 0);
            zero: out std_logic
        );
    end component;
    component Adder is
        generic (
            width: integer := XLEN
        );
        port (
            a, b: in std_logic_vector(width-1 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component BuildImm is
        port (
            inst_opland: in std_logic_vector(24 downto 0);
            i_imm: out std_logic_vector(XLEN-1 downto 0);
            s_imm: out std_logic_vector(XLEN-1 downto 0);
            b_imm: out std_logic_vector(XLEN-1 downto 0);
            u_imm: out std_logic_vector(XLEN-1 downto 0);
            j_imm: out std_logic_vector(XLEN-1 downto 0)
        );
    end component;
    component Multiplexer2 is
        generic (
            width: integer := XLEN
        );
        port (
            data0, data1: in std_logic_vector(width-1 downto 0);
            selector: in std_logic;
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component Multiplexer4 is
        generic (
            width: integer := XLEN
        );
        port (
            data0, data1, data2, data3: in std_logic_vector(width-1 downto 0);
            selector: in std_logic_vector(1 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component Multiplexer8 is
        generic (
            width: integer := XLEN
        );
        port (
            data0, data1, data2, data3: in std_logic_vector(width-1 downto 0);
            data4, data5, data6, data7: in std_logic_vector(width-1 downto 0);
            selector: in std_logic_vector(2 downto 0);
            result: out std_logic_vector(width-1 downto 0)
        );
    end component;

    signal pc_plus4, pc_next, pc_branch: std_logic_vector(XLEN-1 downto 0);

    signal rs1, rs2, rd: std_logic_vector(4 downto 0);
    signal i_imm: std_logic_vector(XLEN-1 downto 0);
    signal s_imm: std_logic_vector(XLEN-1 downto 0);
    signal b_imm: std_logic_vector(XLEN-1 downto 0);
    signal u_imm: std_logic_vector(XLEN-1 downto 0);
    signal j_imm: std_logic_vector(XLEN-1 downto 0);

    signal src_a: std_logic_vector(XLEN-1 downto 0);
    signal src_b: std_logic_vector(XLEN-1 downto 0);
    signal alu_result: std_logic_vector(XLEN-1 downto 0);
    signal result: std_logic_vector(XLEN-1 downto 0);

    signal reg_r_data1: std_logic_vector(XLEN-1 downto 0);
    signal reg_r_data2: std_logic_vector(XLEN-1 downto 0);
    signal reg_w_data: std_logic_vector(XLEN-1 downto 0);

begin

    -- inst, imm
    rs1 <= inst(19 downto 15);
    rs2 <= inst(24 downto 20);
    rd <= inst(11 downto 7);

    makeimm: BuildImm port map (inst(31 downto 7),
        i_imm => i_imm,
        s_imm => s_imm,
        b_imm => b_imm,
        u_imm => u_imm,
        j_imm => j_imm
    );

    -- memory

    mem_addr <= alu_result;
    mem_w_data <= reg_r_data2;

    -- PC
    pc_ff: FlipFlop port map (clock, reset, d => pc_next, q => pc);
    pc_add4: Adder port map (pc, x"00000004", result => pc_plus4);
    pc_addbr: Adder port map (pc, b_imm, result => pc_branch);
    sel_pc_src: Multiplexer4 port map (
        pc_plus4, result, pc_branch, x"XXXXXXXX",
        selector => pc_sel, result => pc_next
    );

    -- Register
    rf: RegisterFile port map (clock, reset,
        read_addr1 => rs1,
        read_data1 => reg_r_data1,
        read_addr2 => rs2,
        read_data2 => reg_r_data2,
        write_enable => reg_w_en,
        write_addr => rd,
        write_data => reg_w_data
    );
    sel_write_data: Multiplexer4 port map (
        u_imm, result, pc_plus4, x"XXXXXXXX",
        selector => reg_w_sel, result => reg_w_data
    );

    -- ALU
    sel_src_a: Multiplexer2 port map (
        reg_r_data1, pc,
        selector => src_a_sel, result => src_a
    );
    sel_src_b: Multiplexer8 port map (
        i_imm, s_imm, u_imm, j_imm,
        reg_r_data2, x"XXXXXXXX", x"XXXXXXXX", x"XXXXXXXX",
        selector => src_b_sel, result => src_b
    );
    main_alu: ALU port map (
        controle => alu_con,
        a => src_a,
        b => src_b,
        result => alu_result,
        zero => alu_zero
    );
    alu_result_0 <= alu_result(0);

    -- result
    sel_result: Multiplexer2 port map (
        alu_result, mem_r_data,
        selector => result_sel, result => result
    );

end architecture;
