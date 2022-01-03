library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity RegisterFile is
    port (
        clock: in std_logic;
        read_addr1, read_addr2: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
        read_data1, read_data2: out std_logic_vector(XLEN-1 downto 0);
        write_enable: in std_logic;
        write_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
        write_data: in std_logic_vector(XLEN-1 downto 0)
    );
end RegisterFile;

architecture rtl of RegisterFile is

    type RegisterFileType is array (1 to 31)
        of std_logic_vector(XLEN-1 downto 0);

    signal regfile: RegisterFileType;

begin

    -- write
    process (clock)
        variable addr_int: integer := 0;
    begin
        if rising_edge(clock) and write_enable = '1' then
            addr_int := to_integer(unsigned(write_addr));
            if addr_int /= 0 then
                regfile(addr_int) <= write_data;
            end if;
        end if;
    end process;

    -- read 1
    process (all)
        variable addr_int: integer := 0;
    begin
        addr_int := to_integer(unsigned(read_addr1));
        if addr_int /= 0 then
            read_data1 <= regfile(addr_int);
        else
            read_data1 <= (others => '0');
        end if;
    end process;

    -- read 2
    process (all)
        variable addr_int: integer := 0;
    begin
        addr_int := to_integer(unsigned(read_addr2));
        if addr_int /= 0 then
            read_data2 <= regfile(addr_int);
        else
            read_data2 <= (others => '0');
        end if;
    end process;

end architecture;
