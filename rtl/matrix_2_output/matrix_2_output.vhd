library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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



begin

  done <= '1';
  prediction <= b"0000000010";

end Behavioral;
