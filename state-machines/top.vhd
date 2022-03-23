--------------------------------------------
-- Good/Bad state machine design (top level)
-- Book: VHDL för konstruktion
--
-- 2022-03-22
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        clk, resetn : in std_logic;
        a1, a2 : in std_logic;
        q1, q2 : out std_logic_vector(3 downto 0)
    );
end top;

architecture structure of top is

    component example1
        port (
            clk, resetn, a : in std_logic;
            q : out std_logic_vector(3 downto 0)
        );
    end component;

begin

U1: entity work.example1(bad)
    port map (
        clk => clk,
        resetn => resetn,
        a => a1,
        q => q1
    );

U2: entity work.example1(good)
    port map (
        clk => clk,
        resetn => resetn,
        a => a2,
        q => q2
    );

end architecture;