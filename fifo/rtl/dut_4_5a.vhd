library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dut_4_5a is
    port (
        clk, rst : in std_logic;
        a, b : in std_logic_vector(3 downto 0);
        q : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of dut_4_5a is

begin
    process (clk, rst)
        variable int : std_logic_vector(3 downto 0);
    begin
        if rst = '0' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if int(3) /= '1' then
                int := a + b;
                q <= shr(int, "10"); -- shift right by two steps.
            else
                int := int + 1;
                q <= shr(int, "10"); -- shift right by two steps.
            end if;
        end if;
    end process;
end architecture;