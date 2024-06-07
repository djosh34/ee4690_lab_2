library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.predict_package.all;

use work.fc1_weights_package.all;
use work.fc2_weights_package.all;

entity predict is
    generic (
        INPUT_SIZE : integer := 768;
        HIDDEN_SIZE : integer := 1024;
        OUTPUT_SIZE : integer := 10
    );
    port (
        CLK : in std_logic;
        rst : in std_logic;

        input_row : in std_logic_vector(0 to INPUT_SIZE - 1);
        output_row : out std_logic_vector(0 to OUTPUT_SIZE - 1);
      

        done : out std_logic
    );
end predict;

architecture Behavioral of predict is
    -- - [ ] Matrix weights_1 1024 * 768 bits = 1024 * 12 * 64 bits
    -- - [ ] Matrix  weights_2 10 * 1024 bits = 10 * 16 * 64 bits




    constant weights_1 : weights_1_type := read_and_populate_weights_1;
    constant weights_2 : weights_2_type := read_and_populate_weights_2;

    signal is_valid : std_logic;
    signal is_sum_high : std_logic;
    signal popcount_sum : unsigned(9 downto 0);

    signal current_2_input_bit : std_logic;
    signal matrix_2_output_enable : std_logic;

    signal current_weights_1_row : std_logic_vector(0 to INPUT_SIZE - 1);
    signal current_weights_2_row : std_logic_vector(0 to OUTPUT_SIZE - 1);

    

begin

    unit_xnor_popcount : entity work.xnor_popcount
        generic map (
            N => INPUT_SIZE
        )
        port map (
            clk => clk,
            rst => rst,
            enable => '1',
            is_valid => is_valid,

            input_input => input_row,
            input_weights => current_weights_1_row,

            is_sum_high => is_sum_high,
            popcount_sum => popcount_sum
        );


    unit_matrix_2_output : entity work.matrix_2_output
        generic map (
            HIDDEN_DIM => HIDDEN_SIZE,
            OUTPUT_DIM => OUTPUT_SIZE
        )
        port map (
            clk => clk,
            rst => rst,
            enable => is_valid,

            current_weights_row => current_weights_2_row,
            current_input_bit => is_sum_high,

            prediction => output_row,
            done => done
        );



    process(clk)
      variable matrix_1_i : natural range 0 to HIDDEN_SIZE - 1 := 0;
      variable matrix_2_i : natural range 0 to HIDDEN_SIZE - 1 := 0;

      variable line_out : line;
    begin
        if rising_edge(clk) then
            if rst = '1' then

              matrix_1_i := 0;
              matrix_2_i := 0;

              current_weights_1_row <= weights_1(0);
              current_weights_2_row <= weights_2(0);



            elsif rst = '0' then

              -- write(line_out, string'("Matrix 1 i: "));
              -- write(line_out, int_to_leading_zeros(matrix_1_i, 4));

              -- write(line_out, string'(" Matrix 2 i: "));
              -- write(line_out, int_to_leading_zeros(matrix_2_i, 4));

              -- write(line_out, string'(" is_valid: "));
              -- write(line_out, is_valid);

              -- write(line_out, string'(" is_sum_high: "));
              -- write(line_out, is_sum_high);

              -- write(line_out, string'(" current_2_input_bit: "));
              -- write(line_out, current_2_input_bit);

              -- write(line_out, string'(" current_weights_2_row: "));
              -- write(line_out, current_weights_2_row);

              -- write(line_out, string'(" popcount_sum: "));
              -- write(line_out, int_to_leading_zeros(to_integer(popcount_sum), 4));

              -- writeline(output, line_out);



              current_weights_1_row <= weights_1(matrix_1_i);
              current_weights_2_row <= weights_2(matrix_2_i);


              if matrix_1_i < HIDDEN_SIZE - 1 then
                matrix_1_i := matrix_1_i + 1;
              end if;

              if is_valid = '1' and matrix_2_i < HIDDEN_SIZE - 1 then
                matrix_2_i := matrix_2_i + 1;
              end if;

            end if;


        end if;
    end process;

end Behavioral;

