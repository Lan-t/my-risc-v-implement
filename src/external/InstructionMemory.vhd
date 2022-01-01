library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiskVGlobals.all;

entity InstructionMemory is
    port (
        addr: in std_logic_vector(REGISTER_WIDTH-1 downto 0);
        inst: out std_logic_vector(31 downto 0)
    );
end InstructionMemory;

architecture rtl of InstructionMemory is



begin

    inst <=
        x"12345" & b"00000_0110111" when addr = x"00000000" else  -- LUI $0, 0
        x"00000000";

end architecture;
