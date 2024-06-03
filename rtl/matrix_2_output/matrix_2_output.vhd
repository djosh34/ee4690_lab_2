library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_misc.ALL;

use IEEE.math_real.all;
use work.predict_package.all;

entity matrix_2_output is

	-- - [ ] hardware IO
	-- 	- [ ] current weights row 10 bits in 
	-- 	- [ ] current input bit 1 bit in
	-- 	- [ ] prediction out 10 bits
	-- 	- [ ] done out
    generic (
        HIDDEN_DIM : integer := 1024;
        OUTPUT_DIM : integer := 10
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        current_weights_row : in std_logic_vector(0 to OUTPUT_DIM - 1);
        current_input_bit : in std_logic;

        prediction : out std_logic_vector(0 to OUTPUT_DIM - 1);
        done : out std_logic
    );
end matrix_2_output;


architecture Behavioral of matrix_2_output is

  -- output_counter: for i in 0 to OUTPUT_DIM - 1 generate
  --   signal output_accumulator : unsigned(9 downto 0) := (others => '0');
  -- end generate;

  type output_accumulator_array is array(0 to OUTPUT_DIM - 1) of unsigned(9 downto 0);
  signal output_accumulator : output_accumulator_array := (others => (others => '0'));


  signal highest_counter : unsigned(9 downto 0) := (others => '0');

  signal equal_to_highest : std_logic_vector(0 to OUTPUT_DIM - 1) := (others => '0');



begin


  -- equal to highest
  equal_to_highest_generate: for i in 0 to OUTPUT_DIM - 1 generate
    equal_to_highest(i) <= '1' when output_accumulator(i) = highest_counter else '0';
  end generate;

  prediction <= equal_to_highest;



  process(clk, rst)
    variable should_increment_bit : unsigned(0 to 0) := (others => '0');
    variable should_increment_logic : std_logic;
    variable should_increment_vector : std_logic_vector(0 to OUTPUT_DIM - 1) := (others => '0');

    variable will_highest_increment_vector : std_logic_vector(0 to OUTPUT_DIM - 1) := (others => '0');
    variable will_highest_increment : std_logic;
    variable will_highest_increment_bit : unsigned(0 to 0) := (others => '0');

    variable hidden_dim_counter : natural := 0;
  begin
    if rst = '1' then

      output_accumulator <= (others => (others => '0'));
      highest_counter <= (others => '0');
      done <= '0';
      should_increment_bit := (others => '0');
      should_increment_logic := '0';
      should_increment_vector := (others => '0');

      hidden_dim_counter := 0;

    elsif rising_edge(clk) then

      for i in 0 to OUTPUT_DIM - 1 loop
        should_increment_logic := current_weights_row(i) xnor current_input_bit;
        should_increment_vector(i) := should_increment_logic;

        should_increment_bit := b"1" when should_increment_logic = '1' else b"0";
        output_accumulator(i) <= output_accumulator(i) + should_increment_bit;
      end loop;


      will_highest_increment_vector := should_increment_vector and equal_to_highest;
      will_highest_increment := or_reduce(will_highest_increment_vector);
      will_highest_increment_bit := b"1" when will_highest_increment = '1' else b"0";

      highest_counter <= highest_counter + will_highest_increment_bit;


      hidden_dim_counter := hidden_dim_counter + 1;

      if hidden_dim_counter >= HIDDEN_DIM then
        done <= '1';
      end if;

    end if;
  end process;

end Behavioral;
