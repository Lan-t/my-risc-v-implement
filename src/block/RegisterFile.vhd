library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity RegisterFile is
    port (
        clock: in std_logic;
        write_enable: in std_logic;
        write_addr: in std_logic_vector(REG_SELECTOR_LEN-1 downto 0);
        write_data: in std_logic_vector(REGISTER_WIDTH-1 downto 0)
    );
end RegisterFile;

architecture rtl of RegisterFile is

    type RegisterFileType is array (XLEN-1 downto 0)
        of std_logic_vector(REGISTER_WIDTH-1 downto 0);

    signal regfile: RegisterFileType;

begin

    process (clock) begin
        if rising_edge(clock) and write_enable = '1' then
            regfile(to_integer(unsigned(write_addr))) <= write_data;
        end if;
    end process;

end architecture;
