library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package RiscVGlobals is
    constant XLEN: integer := 32;
    constant REG_SELECTOR_LEN: integer := integer(ceil(log2(real(XLEN))));
end package;

package body RiscVGlobals is

end package body;
