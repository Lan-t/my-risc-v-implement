library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.RiscVGlobals.all;

entity ALU_test is
end ALU_test;

architecture rtl of ALU_test is

    component ALU is
        generic (
            width: integer := XLEN
        );
        port (
            controle: in std_logic_vector(3 downto 0);
            a, b: in std_logic_vector(width-1 downto 0);
            result: buffer std_logic_vector(width-1 downto 0);
            zero: out std_logic
        );
    end component;

    signal controle: std_logic_vector(3 downto 0);
    signal a, b: std_logic_vector(31 downto 0);
    signal result: std_logic_vector(31 downto 0);
    signal zero: std_logic;

begin

    DUT: ALU port map (controle, a, b, result, zero);

    controle <=
        "0000" after 0 ns,
        "1000" after 10 ns,
        "0001" after 20 ns,
        "0010" after 30 ns,
        "0011" after 40 ns,
        "0100" after 50 ns,
        "0101" after 60 ns,
        "1101" after 70 ns,
        "0110" after 80 ns,
        "0111" after 90 ns,
        "0000" after 100 ns;


    a <= x"80001000";
    b <= x"00000004";

end architecture;
