library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity RV32ITop is
    port (
        clock, reset: in std_logic
    );
end RV32ITop;

architecture rtl of RV32ITop is

    component RV32I is
        port (
            clock, reset: in std_logic;
            pc: out std_logic_vector(XLEN-1 downto 0);
            inst: in std_logic_vector(31 downto 0);
            mem_addr: out std_logic_vector(31 downto 0);
            mem_w_en: out std_logic;
            mem_w_data: out std_logic_vector(31 downto 0);
            mem_r_data: in std_logic_vector(31 downto 0)
        );
    end component;
    component MemoryUnit is
        generic (
            filename: string := "src/external/mem_file/Memory.txt";
            rom_filename: string := ""
        );
        port (
            clock: in std_logic;
            write_enable: in std_logic;
            read_addr: in std_logic_vector(31 downto 0);
            write_addr: in std_logic_vector(31 downto 0);
            write_data: in std_logic_vector(31 downto 0);
            read_data: out std_logic_vector(31 downto 0)
        );
    end component;

    signal pc: std_logic_vector(XLEN-1 downto 0);
    signal inst: std_logic_vector(31 downto 0);

    signal mem_addr: std_logic_vector(31 downto 0);
    signal mem_w_en: std_logic;
    signal mem_w_data: std_logic_vector(31 downto 0);
    signal mem_r_data: std_logic_vector(31 downto 0);

begin

    rv: RV32I port map (clock, reset, pc, inst,
        mem_addr => mem_addr,
        mem_w_en => mem_w_en,
        mem_w_data => mem_w_data,
        mem_r_data => mem_r_data
    );

    im: MemoryUnit generic map (
        filename => "src/external/mem_file/InstructionMemory.txt",
        rom_filename => "src/external/mem_file/InstructionRom.txt"
    ) port map (clock,
        write_enable => '0',
        read_addr => pc,
        write_addr => x"XXXXXXXX",
        write_data => x"XXXXXXXX",
        read_data => inst
    );
    dm: MemoryUnit generic map (
        filename => "src/external/mem_file/DataMemory.txt"
    ) port map (clock,
        write_enable => mem_w_en,
        read_addr => mem_addr,
        write_addr => mem_addr,
        write_data => mem_w_data,
        read_data => mem_r_data
    );

end architecture;
