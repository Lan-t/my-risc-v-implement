library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RiscVGlobals.all;

entity SubController is
    port (
        pc_sel_signal: in std_logic_vector(1 downto 0);
        branch_cond_sel: in std_logic_vector(1 downto 0);
        alu_zero: in std_logic;
        alu_result0: in std_logic;
        pc_src_sel: out std_logic_vector(1 downto 0)
    );
end SubController;

-- +---------------+-----------------+----------+-------------+------------+
-- | pc_sel_signal | branch_cond_sel | alu_zero | alu_result0 | pc_src_sel |
-- +---------------+-----------------+----------+-------------+------------+
-- |       00      |       XX        |     X    |      X      |     00     |
-- |       01      |       XX        |     X    |      X      |     01     |
-- |       10      |       00 zero   |     0    |      X      |     00     |
-- |       10      |       00        |     1    |      X      |     10     |
-- |       10      |       01 ~zero  |     0    |      X      |     10     |
-- |       10      |       01        |     1    |      X      |     00     |
-- |       10      |       10 lt     |     X    |      0      |     00     |
-- |       10      |       10        |     X    |      1      |     10     |
-- |       10      |       11 ~lt    |     X    |      0      |     10     |
-- |       10      |       11        |     X    |      1      |     00     |
-- +---------------+-----------------+----------+-------------+------------+
--       S1,S0           C1,C0             Z           R          Q1,Q0        put each as
-- Q0 = S0
-- Q1 = S1~S0(~C1~C0Z + ~C1C0~Z + C1~C0R + C0C1R) = S1~S0(~C1(C0⊕Z) + C1(C0⊕R))
architecture rtl of SubController is
    signal S1, S0, C1, C0, Z, R: std_logic;
begin
    S1 <= pc_sel_signal(1);
    S0 <= pc_sel_signal(0);
    C1 <= branch_cond_sel(1);
    C0 <= branch_cond_sel(0);
    Z <= alu_zero;
    R <= alu_result0;

    pc_src_sel <= S1 and not S0 and ((not C1 and (C0 xor Z)) or (C1 and (C0 xor R))) & pc_sel_signal(0);

end architecture;
