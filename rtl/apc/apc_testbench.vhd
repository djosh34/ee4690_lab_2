library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use std.env.all;

use IEEE.math_real.all;

library work;
use work.apc_package.all;

entity apc_testbench is
end apc_testbench;


architecture testbench of apc_testbench is
  constant CLK_PERIOD : time := 20 ns;


  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal start : std_logic := '0';
  signal parallel_input_counter : std_logic_vector(15 downto 0) := (others => '0');

  signal done : std_logic;

  component apc is
    generic (
        INPUT_SIZE : integer := 768
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;


        parallel_input_counter : in std_logic_vector(15 downto 0);

        -- debugging signals
        -- end debugging signals


        done : out std_logic
    );
  end component;
begin
    uut : apc
    generic map (
        INPUT_SIZE => 768
    )
    port map (
        clk => clk,
        rst => rst,
        start => start,
        parallel_input_counter => parallel_input_counter,
        done => done
    );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;


    -- Stimulus process
    stim_proc : process
        variable line_out : line;
    begin
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';


        parallel_input_counter <= "1111" & "1111" & "1111" & "1111";

        for i in 0 to 100 loop
            wait for CLK_PERIOD;
        end loop;

        write(line_out, string'("Done: "));
        writeline(output, line_out);




        finish;
    end process;
end architecture testbench;

