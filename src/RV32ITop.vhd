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
            mem_write_enable: out std_logic;
            mem_write_data: out std_logic_vector(31 downto 0);
            mem_read_data: in std_logic_vector(31 downto 0)
        );
    end component;
    component InstructionMemory is
        port (
            addr: in std_logic_vector(XLEN-1 downto 0);
            inst: out std_logic_vector(31 downto 0)
        );
    end component;
    component DataMemory is
        port (
            clock: in std_logic;
            addr: in std_logic_vector(31 downto 0);
            write_enable: in std_logic;
            write_data: in std_logic_vector(31 downto 0);
            read_data: out std_logic_vector(31 downto 0)
        );
    end component;

    signal pc: std_logic_vector(XLEN-1 downto 0);
    signal inst: std_logic_vector(31 downto 0);

    signal mem_addr: std_logic_vector(31 downto 0);
    signal mem_write_enable: std_logic;
    signal mem_write_data: std_logic_vector(31 downto 0);
    signal mem_read_data: std_logic_vector(31 downto 0);

begin

    rv: RV32I port map (clock, reset, pc, inst,
        mem_addr => mem_addr,
        mem_write_enable => mem_write_enable,
        mem_write_data => mem_write_data,
        mem_read_data => mem_read_data
    );
    im: InstructionMemory port map (pc, inst);
    dm: DataMemory port map (clock,
        addr => mem_addr,
        write_enable => mem_write_enable,
        write_data => mem_write_data,
        read_data => mem_read_data
    );

end architecture;