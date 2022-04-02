------------------------------------------------------------------------------
--! \file   tb_sclkfifo.vhd
--!
--! \brief  Direct testbench for lattice_ip/sclkfifo_lattice/sclkfifo_a_rtl_lattice.vhd
--!
--! \author Mehdi Taabouri 2021-10-xx
--!
--! Copyright &copy; Maquet Critical Care AB, Sweden
--!
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use IEEE.math_real.all;

use IEEE.numeric_std.all;

entity tb is
end entity tb;
architecture test of tb is

    component GSR
        port (GSR : in std_logic);
    end component;

    component PUR
        port (PUR : in std_logic);
    end component;

    signal pwr_reset : std_logic := '1';

    component fifo_8_8_sa
        generic (
            DataWidth : integer := 8 --! FIFO Data width
        );
        port (
            rst : in std_logic;
            rd_clk : in std_logic;
            din : in std_logic_vector(DataWidth - 1 downto 0);
            rd_en : in std_logic;
            wr_clk : in std_logic;
            wr_en : in std_logic;
            empty : out std_logic;
            full : out std_logic;
            dout : out std_logic_vector(DataWidth - 1 downto 0)
        );
    end component fifo_8_8_sa;

    signal Data : std_logic_vector(7 downto 0) := (others => '0');
    signal Clock : std_logic := '0';
    signal Clear : std_logic := '0';
    signal WrEn : std_logic := '0';
    signal RdEn : std_logic := '0';
    signal Reset : std_logic := '0';
    signal Q1 : std_logic_vector(7 downto 0);
    signal Empty1 : std_logic;
    signal Full1 : std_logic;

    -- TODO: move below functions to a package is they will be shared by more than
    -- one testbench

    shared variable nbr_assertions, nbr_fail_assertions : integer := 0;

    -- assert that output from FIFO is equal to an input value
    procedure assert_p(variable r_IN : in integer; signal s_IN : in std_logic_vector(7 downto 0)) is
    begin
        nbr_assertions := nbr_assertions + 1;
        if s_IN /= std_logic_vector(to_unsigned(r_IN, s_IN'length)) then
            nbr_fail_assertions := nbr_fail_assertions + 1;
        end if;
        assert s_IN = std_logic_vector(to_unsigned(r_IN, s_IN'length))
        report "Output from FIFO not expected. Expected: " & integer'image(r_IN)
            severity error;
    end assert_p;

    -- assert a signal is set high
    procedure assert_sig_h(signal s_IN : in std_logic) is
    begin
        nbr_assertions := nbr_assertions + 1;
        if s_IN /= '1' then
            nbr_fail_assertions := nbr_fail_assertions + 1;
        end if;
        assert s_IN = '1'
        report "Signal is not asserted high"
            severity error;
    end assert_sig_h;

    -- assert a signal is set low
    procedure assert_sig_l(signal s_IN : in std_logic) is
    begin
        nbr_assertions := nbr_assertions + 1;
        if s_IN /= '0' then
            nbr_fail_assertions := nbr_fail_assertions + 1;
        end if;
        assert s_IN = '0'
        report "Signal is not asserted low"
            severity error;
    end assert_sig_l;

    -- print assertions summary
    procedure print_result is
    begin
        report "Number of assertions: " & integer'image(nbr_assertions) &
            "; Number of failed assertions: " & integer'image(nbr_fail_assertions)
            severity note;

    end print_result;

begin

    GSR_INST : GSR port map(GSR => pwr_reset);
    PUR_INST : PUR port map(PUR => pwr_reset);

    u1 : fifo_8_8_sa
    generic map(
        DataWidth => 8
    )
    port map(
        rst => Reset,
        rd_clk => Clock,
        din => Data,
        rd_en => RdEn,
        wr_clk => Clock,
        wr_en => WrEn,
        empty => Empty1,
        full => Full1,
        dout => Q1
    );

    Clock <= not Clock after 5.00 ns;

    process

    begin
        Clear <= '0';
        Data <= "00000001";
        WrEn <= '0';
        wait for 100 ns;
        wait until Reset = '0';
        for i in 0 to 11 loop
            wait until Clock'event and Clock = '1';
            WrEn <= '1' after 2 ns;
            Data <= Data + '1' after 3 ns;
        end loop;
        WrEn <= '0';
        wait until RdEn = '1';
        wait until RdEn = '0';
        -- Start second write sequence
        wait for 40 ns;
        for i in 0 to 20 loop
            wait until Clock'event and Clock = '1';
            WrEn <= '1' after 2 ns;
            Data <= Data + '1' after 3 ns;
            if i = 4 then
                Clear <= '1' after 2 ns;
            elsif i = 10 then
                Clear <= '0' after 2 ns;
            end if;
        end loop;
        WrEn <= '0';
        wait until RdEn = '1';
        wait until RdEn = '0';
        -- Start third write sequence
        wait for 40 ns;
        for i in 0 to 11 loop
            wait until Clock'event and Clock = '1';
            WrEn <= '1' after 2 ns;
            Data <= Data + '1' after 3 ns;
        end loop;
        WrEn <= '0';
        -- Start fourth write sequence
        wait for 250 ns;
        for i in 0 to 11 loop
            wait until Clock'event and Clock = '1';
            WrEn <= '1' after 2 ns;
            Data <= Data + '1' after 3 ns;
        end loop;
        WrEn <= '0';
        wait until RdEn = '1';
        wait until RdEn = '0';
        -- Start fifth write sequence (one word only)
        wait for 40 ns;
        for i in 0 to 1 loop
            wait until Clock'event and Clock = '1';
            WrEn <= '1' after 2 ns;
            Data <= Data + '1' after 3 ns;
        end loop;
        WrEn <= '0';
        wait;
    end process;

    read_fifo_p : process
        variable expected : integer := 2; -- head of data in the FIFO
    begin
        RdEn <= '0';
        wait until Reset = '0';
        wait until WrEn = '1';
        wait until WrEn = '0';
        assert_sig_l(Empty1);
        for i in 0 to 11 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            -- verify output of Lattice fifo by assertions --
            if i >= 0 and i < 8 then
                wait until Clock'event and Clock = '0'; -- sample on negative edge
                assert_p(expected, Q1);
                expected := expected + 1;
            elsif i >= 8 then
                expected := 0;
                wait until Clock'event and Clock = '0';
                assert_p(expected, Q1);
                assert_sig_h(Empty1); -- FIFO should be empty at this stage
            end if;
            -------------------------------------------------
        end loop;
        RdEn <= '0';
        -- Start second read sequence
        wait until WrEn = '1';
        wait until WrEn = '0';
        expected := 24;
        assert_sig_l(Empty1);
        for i in 0 to 11 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            -- verify output of Lattice fifo by assertions --
            if i >= 0 and i < 8 then
                wait until Clock'event and Clock = '0'; -- sample on negative edge
                assert_p(expected, Q1);
            elsif i >= 8 then -- FIFO should be empty at this stage
                expected := 0;
                wait until Clock'event and Clock = '0';
                assert_p(expected, Q1);
                assert_sig_h(Empty1); -- FIFO should be empty at this stage
            end if;
            expected := expected + 1;
            -------------------------------------------------
        end loop;
        RdEn <= '0';
        -- Start third read sequence interrupted
        wait until WrEn = '1';
        wait until WrEn = '0';
        expected := 35;
        for i in 0 to 4 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            -- verify output of Lattice fifo by assertions --
            wait until Clock'event and Clock = '0'; -- sample on negative edge
            assert_p(expected, Q1);
            expected := expected + 1;
            -------------------------------------------------
        end loop;
        -- Interrupt reading a bit
        RdEn <= '0';
        wait for 60 ns;
        -- Resume reading
        expected := 39;
        for i in 0 to 7 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            -- verify output of Lattice fifo by assertions --
            if i >= 0 and i < 4 then
                wait until Clock'event and Clock = '0'; -- sample on negative edge
                assert_p(expected, Q1);
            elsif i >= 4 then -- FIFO should be empty at this stage
                expected := 0;
                wait until Clock'event and Clock = '0';
                assert_p(expected, Q1);
                assert_sig_h(Empty1); -- FIFO should be empty at this stage
            end if;
            expected := expected + 1;
            -------------------------------------------------
        end loop;
        RdEn <= '0';
        expected := 47; -- 0x2f
        -- Start fourth read sequence
        wait until Empty1 = '0';
        for i in 0 to 6 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            -- verify output of Lattice fifo by assertions --
            wait until Clock'event and Clock = '0'; -- sample on negative edge
            assert_p(expected, Q1);
            expected := expected + 1;
            -------------------------------------------------
        end loop;
        -- Interrupt reading a bit
        RdEn <= '0';
        expected := 53; -- 0x35
        wait until Full1 = '1' or WrEn = '0';
        wait for 40 ns;
        for i in 0 to 7 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            -- verify output of Lattice fifo by assertions --
            if i >= 0 and i < 5 then
                wait until Clock'event and Clock = '0'; -- sample on negative edge
                assert_p(expected, Q1);
            elsif i >= 5 then -- FIFO should be empty at this stage
                expected := 0;
                wait until Clock'event and Clock = '0';
                assert_p(expected, Q1);
                assert_sig_h(Empty1); -- FIFO should be empty at this stage
            end if;
            expected := expected + 1;
            -------------------------------------------------
        end loop;
        RdEn <= '0';
        -- Start fifth read sequence (one word only)
        expected := 59; -- 0x3B
        wait until WrEn = '1';
        wait until WrEn = '0';
        wait for 40 ns;
        for i in 0 to 1 loop
            wait until Clock'event and Clock = '1';
            RdEn <= '1' after 2 ns;
            if i >= 0 and i < 1 then
                wait until Clock'event and Clock = '0'; -- sample on negative edge
                assert_p(expected, Q1);
            elsif i >= 1 then -- FIFO should be empty at this stage
                expected := 0;
                wait until Clock'event and Clock = '0';
                assert_p(expected, Q1);
                assert_sig_h(Empty1); -- FIFO should be empty at this stage
            end if;
        end loop;
        RdEn <= '0';
        -- Read from empty FIFO
        wait for 40 ns;
        expected := 0;
        wait until Clock'event and Clock = '1';
        RdEn <= '1';
        wait until Clock'event and Clock = '1';
        assert_sig_h(Empty1);
        assert_p(expected, Q1);
        print_result;
        wait;
    end process;

    process

    begin
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait;
    end process;

end architecture test;