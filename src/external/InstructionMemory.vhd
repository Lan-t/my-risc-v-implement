library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

    inst <=
        x"12345" & "00001" & "0110111"                                  when addr = x"00000000" else  -- LUI r1, 0x12345
        x"678" & "00001" & "110" & "00001" & "0010011"                  when addr = x"00000004" else  -- ORI r1, r1, 0x678
        x"678" & "00000" & "000" & "00010" & "0010011"                  when addr = x"00000008" else  -- ADDI r2, r0, 0x678
        x"12000" & "00100" & "0010111"                                  when addr = x"0000000c" else  -- AUIPC r4, 0x12000
        b"0000000_00000_00000_000_00101_0010011"                        when addr = x"00000010" else  -- ADD r5, r0, r0
        x"00428293"                                                     when addr = x"00000014" else  -- ADDI r5, r5, 4
        x"0012a423"                                                     when addr = x"00000018" else  -- SW r1, 8(r5)
        x"0082a303"                                                     when addr = x"0000001c" else  -- LW r6, 8(r5)
        -- b"0000000_00000_00000_000_00101_0010011"                        when addr = x"00000010" else  -- ADD r5, r0, r0
        -- b"1_111111" & "00000" & "00000" & "000" & b"0110_1" & "1100011"  when addr = x"00000014" else  -- BEQ r0, r0, pc - 14
        -- b"1_1111111000_1_11111111" & b"00011" & b"1101111" when addr = x"00000010" else  -- JAL r3, pc - 0x010
        x"00000000";

end architecture;
