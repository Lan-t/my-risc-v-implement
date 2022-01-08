library ieee;
use ieee.std_logic_1164.all;

library work;
use work.RiscVGlobals.all;

entity BuildImm is
    port (
        inst_opland: in std_logic_vector(24 downto 0);
        i_imm: out std_logic_vector(XLEN-1 downto 0);
        s_imm: out std_logic_vector(XLEN-1 downto 0);
        b_imm: out std_logic_vector(XLEN-1 downto 0);
        u_imm: out std_logic_vector(XLEN-1 downto 0);
        j_imm: out std_logic_vector(XLEN-1 downto 0)
    );
end BuildImm;

architecture rtl of BuildImm is
begin

    i_imm <= (
        31 downto 11 => inst_opland(24),
        10 downto 0 => inst_opland(23 downto 13)
    );

    s_imm <= (
        31 downto 11 => inst_opland(24),
        10 downto 5 => inst_opland(23 downto 18),
        4 downto 0 => inst_opland(4 downto 0)
    );

    b_imm <= (
        31 downto 12 => inst_opland(24),
        11 => inst_opland(0),
        10 downto 5 => inst_opland(23 downto 18),
        4 downto 1 => inst_opland(4 downto 1),
        0 => '0'
    );

    u_imm <= (
        31 downto 12 => inst_opland(24 downto 5),
        11 downto 0 => '0'
    );

    j_imm <= (
        31 downto 20 => inst_opland(24),
        19 downto 12 => inst_opland(12 downto 5),
        11 => inst_opland(13),
        10 downto 1 => inst_opland(23 downto 14),
        0 => '0'
    );

end architecture;
