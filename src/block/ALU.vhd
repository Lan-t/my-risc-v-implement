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
        alu_control: in std_logic_vector(3 downto 0);
        a, b: in std_logic_vector(width-1 downto 0);
        result: buffer std_logic_vector(width-1 downto 0);
        zero: out std_logic
    );
end ALU;

-- +-------------+----------+
-- | alu_control | function |
-- +-------------+----------+
-- |    0000     |     +    |
-- |    1000     |     -    |
-- |    -001     |    <<    |
-- |    -010     | set less than |
-- |    -011     | set less than unsigned |
-- |    -100     |    xor   |
-- |    0101     |    >>    |
-- |    1101     |    >>>   |
-- |    -110     |    or    |
-- |    -111     |    and   |
-- +-------------+----------+

architecture rtl of ALU is
    component ALU_SLL is
        generic (
            width: integer := XLEN
        );
        port (
            a, b: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component ALU_SRL is
        generic (
            width: integer := XLEN
        );
        port (
            a, b: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;
    component ALU_SRA is
        generic (
            width: integer := XLEN
        );
        port (
            a, b: in std_logic_vector(width-1 downto 0);
            q: out std_logic_vector(width-1 downto 0)
        );
    end component;

    signal sll_result: std_logic_vector(width-1 downto 0);
    signal srl_result: std_logic_vector(width-1 downto 0);
    signal sra_result: std_logic_vector(width-1 downto 0);
begin

    sll0: ALU_SLL port map (a, b, sll_result);
    srl0: ALU_SRL port map (a, b, srl_result);
    sra0: ALU_SRA port map (a, b, sra_result);

    process (all)
        variable minus_tmp: std_logic_vector(width-1 downto 0) := (others => '0');
    begin
        case? alu_control is
            when "0000" =>
                result <= a + b;
            when "1000" =>
                result <= a - b;
            when "-001" =>
                result <= sll_result;
            when "-010" =>
                if signed(a) < signed(b) then
                    result <= conv_std_logic_vector(1, width);
                else
                    result <= conv_std_logic_vector(0, width);
                end if;
            when "-011" =>
                if unsigned(a) < unsigned(b) then
                    result <= conv_std_logic_vector(1, width);
                else
                    result <= conv_std_logic_vector(0, width);
                end if;
            when "-100" =>
                result <= a xor b;
            when "0101" =>
                result <= srl_result;
            when "1101" =>
                result <= sra_result;
            when "-110" =>
                result <= a or b;
            when "-111" =>
                result <= a and b;
            when others =>
                result <= (others => 'X');
        end case?;
    end process;

    process (result)
        variable a: std_logic := '0';
    begin
        a := '0';
        for i in 0 to width-1 loop
            a := a or result(i);
        end loop;
        zero <= not a;
    end process;

end architecture;

-------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.RiscVGlobals.all;

entity ALU_SLL is
    generic (
        width: integer := XLEN
    );
    port (
        a, b: in std_logic_vector(width-1 downto 0);
        q: out std_logic_vector(width-1 downto 0)
    );
end ALU_SLL;

architecture rtl of ALU_SLL is
begin
    process (all)
        variable shamt: integer;
    begin
        shamt := conv_integer(unsigned(b(4 downto 0)));
        report integer'image(shamt);
        if shamt /= 0 then
            q <= a(31-shamt downto 0) & (shamt-1 downto 0 => '0');
        else
            q <= a;
        end if;
    end process;
end architecture;

-------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.RiscVGlobals.all;

entity ALU_SRL is
    generic (
        width: integer := XLEN
    );
    port (
        a, b: in std_logic_vector(width-1 downto 0);
        q: out std_logic_vector(width-1 downto 0)
    );
end ALU_SRL;

architecture rtl of ALU_SRL is
begin
    process (all)
        variable shamt: integer;
    begin
        shamt := conv_integer(unsigned(b(4 downto 0)));
        if shamt /= 0 then
            q <= (shamt-1 downto 0 => '0') & a(31 downto shamt);
        else
            q <= a;
        end if;
    end process;
end architecture;

-------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.RiscVGlobals.all;

entity ALU_SRA is
    generic (
        width: integer := XLEN
    );
    port (
        a, b: in std_logic_vector(width-1 downto 0);
        q: out std_logic_vector(width-1 downto 0)
    );
end ALU_SRA;

architecture rtl of ALU_SRA is
begin
    process (all)
        variable shamt: integer;
    begin
        shamt := conv_integer(unsigned(b(4 downto 0)));
        if shamt /= 0 then
            q <= (shamt-1 downto 0 => a(31)) & a(31 downto shamt);
        else
            q <= a;
        end if;
    end process;
end architecture;
