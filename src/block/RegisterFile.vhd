library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity RegisterFile is
    port (
        clock: in std_logic;
        read_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
        read_data: out std_logic_vector(XLEN-1 downto 0);
        write_enable: in std_logic;
        write_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
        write_data: in std_logic_vector(XLEN-1 downto 0)
    );
end RegisterFile;

architecture rtl of RegisterFile is

    type RegisterFileType is array (31 downto 1)
        of std_logic_vector(XLEN-1 downto 0);

    signal regfile: RegisterFileType;

begin

    process (clock)
        variable addr_int: integer := 0;
    begin
        if rising_edge(clock) and write_enable = '1' then
            addr_int := to_integer(unsigned(write_addr));
            if addr_int /= 0 then
                regfile(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;
    end process;

    process (all)
        variable addr_int: integer := 0;
    begin
        addr_int := to_integer(unsigned(read_addr));
        if addr_int /= 0 then
            read_data <= regfile(addr_int);
        else
            report "all 0.";
            read_data <= (others => '0');
        end if;
    end process;

end architecture;
