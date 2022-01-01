library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity InstructionMemory is
    port (
        addr: in std_logic_vector(XLEN-1 downto 0);
        inst: out std_logic_vector(31 downto 0)
    );
end InstructionMemory;

architecture rtl of InstructionMemory is



begin

    inst <=
        x"12345" & b"00001" & b"0110111" when addr = x"00000000" else  -- LUI r1, 0x12345
        x"678" & b"00001" & b"110" & b"00001" & b"0010011" when addr = x"00000004" else  -- ORI r1, r1, 0x678
        x"678" & b"00000" & b"000" & b"00010" & b"0010011" when addr = x"00000008" else  -- ADD r2, r0, 0x678
        x"12000" & b"00100" & b"0010111" when addr = x"0000000c" else  -- AUIPC r4, 0x12000
        b"1_1111111000_1_11111111" & b"00011" & b"1101111" when addr = x"00000010" else  -- JAL r3, pc - 0x010
        x"00000000";

end architecture;
