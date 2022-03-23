-------------------------------------------------------------
-- Good/Bad state machine design
-- Book: VHDL för konstruktion
--
-- Purpose: The goal of this exercise is to understand the
-- difference between some constructions in VHDL and how
-- they affect the actual synthesis result of state-machines
--
-- 2022-03-22
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity example1 is
    port (
        clk, resetn, a : in std_logic;
        q : out std_logic_vector(3 downto 0)
    );
end example1;

architecture bad of example1 is
    type state_type is (s0, s1, s2, s3);
    signal state : state_type;

    main : process (clk, resetn)
    begin
        if resetn = '0' then
            state <= s0;
            q <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when s0 =>
                    if a = '1' then
                        state <= s1;
                        q <= "1001";
                    end if;
                when s1 =>
                    if a = '0' then
                        state <= s2;
                        q <= "1100";
                    end if;
                when s2 =>
                    if a = '1' then
                        state <= s3;
                        q <= "1111";
                    end if;
                when s3 =>
                    if a = '0' then
                        state <= s0;
                        q <= "0000";
                    end if;
            end case;
        end if;
    end process main; -- main
end;

architecture good of example1 is
    type state_type is (s0, s1, s2, s3);
    signal state : state_type;

    main : process (clk, resetn)
    begin
        if resetn = '0' then
            state <= s0;
            q <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when s0 =>
                    if a = '1' then
                        state <= s1;
                        q <= "1001";
                    else
                        q <= "0000";
                    end if;
                when s1 =>
                    if a = '0' then
                        state <= s2;
                        q <= "1100";
                    else
                        q <= "1001";
                    end if;
                when s2 =>
                    if a = '1' then
                        state <= s3;
                        q <= "1111";
                    else
                        q <= "1100";
                    end if;
                when s3 =>
                    if a = '0' then
                        state <= s0;
                        q <= "0000";
                    else
                        q <= "1111";
                    end if;
            end case;
        end if;
    end process main; -- main
end;