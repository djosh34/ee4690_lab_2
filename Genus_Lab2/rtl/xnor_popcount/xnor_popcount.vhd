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
  constant bit_width : integer := 32;
  -- constant levels : integer := N/bit_width + 1;
  constant levels : integer := 1;

  signal top_array : std_logic_vector(0 to N-1);


  type in_between_array_type is array(0 to N/bit_width - 1) of integer range 0 to bit_width;
  signal in_between_array : in_between_array_type;




begin



    process(clk)
      variable will_be_valid : integer range 0 to levels := 0;


      variable in_between : integer range 0 to bit_width;
      variable total_sum : integer range 0 to N;

      variable line_out : line;


    begin
        if rising_edge(clk) then
          if rst = '1' then

            is_valid <= '0';

          else
            if enable = '1' then

            -- level 0 to in between
            for i in 0 to (N/bit_width - 1) loop
              in_between := 0;
              for j in 0 to (bit_width - 1) loop
                if input_input(i*bit_width + j) = input_weights(i*bit_width + j) then
                  in_between := in_between + 1;
                end if;
              end loop;
              in_between_array(i) <= in_between;
            end loop;


            -- in between to sum
            total_sum := 0;
            for i in 0 to (N/bit_width - 1) loop
              total_sum := total_sum + in_between_array(i);
            end loop;

            popcount_sum <= total_sum;

            if total_sum >= N/2 then
              is_sum_high <= '1';
            else
              is_sum_high <= '0';
            end if;



            if will_be_valid = levels then
              is_valid <= '1';
            else
              will_be_valid := will_be_valid + 1;
            end if;
            end if;
        end if;
      end if;
    end process;








end Behavioral;

