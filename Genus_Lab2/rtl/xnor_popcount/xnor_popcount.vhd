library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;
use work.predict_package.all;

use std.textio.all;


entity xnor_popcount is
    generic (
        N : integer := 768
    );
    port (
        CLK : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        is_valid : out std_logic;

        input_input : in std_logic_vector(0 to N-1);
        input_weights : in std_logic_vector(0 to N-1);

        is_sum_high : out std_logic;
        
        


        -- Debugging signals
        popcount_sum : out integer range 0 to 768
    );
end xnor_popcount;

architecture Behavioral of xnor_popcount is
  constant levels : integer := 48 + 1;
  constant bit_width : integer := 16;

  signal top_array : std_logic_vector(0 to N-1);
  -- signal end_sum : integer range 0 to 768 := 0;


  type propagate_array is array(0 to N/bit_width-1) of std_logic_vector(0 to N-1);
  signal propagate : propagate_array;

  type sums_array is array(0 to N/bit_width-1) of integer range 0 to bit_width;


  type total_sums_array is array(0 to N/bit_width-1) of integer range 0 to 768;
  signal total_sums : total_sums_array;




begin



    process(clk)
      variable will_be_valid : integer range 0 to levels := 0;


      variable sums : sums_array;

      variable line_out : line;


    begin
        if rising_edge(clk) then
          if rst = '1' then

            is_valid <= '0';

          else
            if enable = '1' then


            -- first level
            propagate(0) <= input_input xnor input_weights;


            -- rest of the levels
            for i in 1 to N/bit_width-1 loop
              propagate(i)(i*bit_width to N-1) <= propagate(i-1)(i*bit_width to N-1);
            end loop;

            -- print all propagate values
            for i in 0 to N/bit_width-1 loop
              -- write(line_out, to_hstring(propagate(i)));


              sums(i) := 0;
              for j in i*bit_width to (i+1)*bit_width-1 loop
                if propagate(i)(j) = '1' then
                  sums(i) := sums(i) + 1;
                end if;
              end loop;
              -- write(line_out, string'(" "));
              -- write(line_out, int_to_leading_zeros(sums(i), 2));


              if i = 0 then
                total_sums(i) <= sums(i);
              else 
                total_sums(i) <= total_sums(i-1) + sums(i);
              end if;
              -- write(line_out, string'(" "));
              -- write(line_out, int_to_leading_zeros(total_sums(i), 3));

              -- writeline(output, line_out);
            end loop;

            popcount_sum <= total_sums(N/bit_width-1);

            if total_sums(N/bit_width-1) >= 384 then
              is_sum_high <= '1';
            else
              is_sum_high <= '0';
            end if;


            -- writeline(output, line_out);
            -- writeline(output, line_out);
            -- writeline(output, line_out);




            if will_be_valid = levels then
              is_valid <= '1';
              will_be_valid := 0;
            else
              will_be_valid := will_be_valid + 1;
            end if;
            end if;
        end if;
      end if;
    end process;








end Behavioral;

