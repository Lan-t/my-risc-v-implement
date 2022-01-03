library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.RiscVGlobals.all;

entity ALU is
    generic (
        width: integer := XLEN
    );
    port (
        alu_control: in std_logic_vector(2 downto 0);
        a, b: in std_logic_vector(width-1 downto 0);
        result: buffer std_logic_vector(width-1 downto 0);
        zero: out std_logic
    );
end ALU;

-- +-------------+----------+
-- | alu_control | function |
-- +-------------+----------+
-- |     000     |     +    |
-- |     001     | -------- |
-- |     010     | set less than |
-- |     011     | set less than unsigned |
-- |     100     |    xor   |
-- |     101     | -------- |
-- |     110     |    or    |
-- |     111     |    and   |
-- +-------------+----------+

architecture rtl of ALU is
begin

    process (all)
        variable minus_tmp: std_logic_vector(width-1 downto 0) := (others => '0');
    begin
        case alu_control is
            when "000" =>
                result <= a + b;
            -- when "001" =>
            when "010" =>
                minus_tmp := signed(a) - signed(b);
                if minus_tmp(width-1) then
                    result <= conv_std_logic_vector(1, width);
                else
                    result <= conv_std_logic_vector(0, width);
                end if;
            when "011" =>
                minus_tmp := a - b;
                if minus_tmp(width-1) then
                    result <= conv_std_logic_vector(1, width);
                else
                    result <= conv_std_logic_vector(0, width);
                end if;
            when "100" =>
                result <= a xor b;
            -- when "101" =>
            when "110" =>
                result <= a or b;
            when "111" =>
                result <= a and b;
            when others =>
                result <= (others => 'X');
        end case;
    end process;

    process (result)
        variable a: std_logic := '0';
    begin
        for i in 0 to width-1 loop
            a := a or result(i);
        end loop;
        zero <= not a;
    end process;

end architecture;