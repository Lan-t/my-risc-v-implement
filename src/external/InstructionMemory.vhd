library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.RiscVGlobals.all;

entity InstructionMemory is
    port (
        addr: in std_logic_vector(XLEN-1 downto 0);
        inst: out std_logic_vector(31 downto 0)
    );
end InstructionMemory;

architecture rtl of InstructionMemory is



begin

    process (addr)
        file rom_file: text;
        variable li: line;
        variable addr_int: integer;
        variable addr_d4: integer;
        variable inst_var: std_logic_vector(31 downto 0);
        variable readline_good: boolean;
    begin
        addr_int := to_integer(signed(addr));
        addr_d4 := addr_int / 4;
        file_open(rom_file, "src/external/mem_file/InstructionRom.txt", READ_MODE);
        for i in 0 to addr_d4 loop
            if endfile(rom_file) then
                readline_good := false;
                exit;
            end if;
            readline(rom_file, li);
            readline_good := true;
        end loop;

        if readline_good then
            hread(li, inst_var);
            inst <= inst_var;
        else
            inst <= x"00000000";
        end if;
        file_close(rom_file);
    end process;

end architecture;
