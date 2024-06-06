library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;

use IEEE.math_real.all;
use work.predict_package.all;

entity lfsr_10_testbench is
end lfsr_10_testbench;

architecture testbench of lfsr_10_testbench is
  constant clk_period : time := 20 ns;

  signal lfsr_output : std_logic_vector(10 downto 0);
  signal enable : std_logic := '1';
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

begin
  uut: entity work.lfsr_10
        port map (
            clk => clk,
            rst => rst,
            enable => enable,

            lfsr_output => lfsr_output 

        );





    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;






    -- Test process
    process
      variable starting_var : std_logic_vector(10 downto 0);

      variable line_out : line;
    begin
        wait for clk_period;
        rst <= '1';

        wait for clk_period;
        rst <= '0';






        starting_var := lfsr_output;
        for i in 0 to 1000000 loop

            if lfsr_output = starting_var then
              write(line_out, int_to_leading_zeros(i, 6));
              write(line_out, string'(" lfsr_out = "));
              write(line_out, lfsr_output);
              write(line_out, string'(" lfsr_repeated"));
              writeline(output, line_out);

              if i mod (2** lfsr_output'length - 1) /= 0 then
                report "TEST FAILED, did not repeat at correct iteration" severity failure;
              end if;
            end if;
            

            wait for clk_period;

        end loop;


        report "TEST PASSED" severity failure; 
    end process;

end architecture testbench;

