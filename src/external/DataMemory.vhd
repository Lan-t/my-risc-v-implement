library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity DataMemory is
    port (
        clock: in std_logic;
        addr: in std_logic_vector(31 downto 0);
        write_enable: in std_logic;
        write_data: in std_logic_vector(31 downto 0);
        read_data: out std_logic_vector(31 downto 0)
    );
end DataMemory;

architecture rtl of DataMemory is

    subtype RamWord is std_logic_vector(7 downto 0);
    type RamArray is array (0 to 4095) of RamWord;

    signal ram: RamArray;

begin

    -- write
    process (clock)
        variable addr_int: integer := 0;
    begin
        if rising_edge(clock) and write_enable = '1' then
            addr_int := to_integer(unsigned(addr));

            if addr_int <= 4095 then
                ram(addr_int) <= write_data(31 downto 24);
                ram(addr_int+1) <= write_data(23 downto 16);
                ram(addr_int+2) <= write_data(15 downto 8);
                ram(addr_int+3) <= write_data(7 downto 0);
            end if;
        end if;
    end process;

    -- read 1
    process (all)
        variable addr_int: integer := 0;
    begin
        addr_int := to_integer(unsigned(addr));

        if addr_int > 4095 then
            read_data <= (others => 'X');
        else
            read_data(31 downto 24) <= ram(addr_int);
            read_data(23 downto 16) <= ram(addr_int+1);
            read_data(15 downto 8) <= ram(addr_int+2);
            read_data(7 downto 0) <= ram(addr_int+3);
        end if;
    end process;

end architecture;
