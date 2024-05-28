library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package predict_package is
  function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer;
  function to_nearest_multiple_of_2(x: integer) return integer;
  function index_to_address_weights_1(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH, hidden_i, input_i :integer) return std_logic_vector;



end predict_package;

package body predict_package is

  --         address : in std_logic_vector(maximum(integer(log2(real(INPUT_SIZE/BIT_WIDTH))), maximum(integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH))), integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH))))) - 1 downto 0);

  function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer is
    variable address_width: integer;

  begin
    return maximum(integer(log2(real(INPUT_SIZE/BIT_WIDTH))), maximum(integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH))), integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH)))));
  end get_address_width;

  function to_nearest_multiple_of_2(x: integer) return integer is
    variable y: integer;
  begin
    y := 1;
    while y < x loop
      y := y * 2;
    end loop;
    return y;
  end to_nearest_multiple_of_2;


  function index_to_address_weights_1(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH, hidden_i, input_i :integer) return std_logic_vector is
    variable address: std_logic_vector(get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH) - 1 downto 0);
    variable n_input: integer;
    variable nearest_multiple: integer;
  begin
    -- it must be that the first bits are for the hidden layer and the last bits are for the input layer
    -- so for 1024 hidden size and 12 * 64 input size, the first 10 bits are for the hidden layer and the last 4 bits are for the input layer
    -- so the address is hidden_i * 64 + input_i

    n_input := INPUT_SIZE/BIT_WIDTH;
    nearest_multiple := to_nearest_multiple_of_2(n_input);


    address := std_logic_vector(to_unsigned(hidden_i * nearest_multiple + input_i, get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH)));
    return address;
  end index_to_address_weights_1;
end predict_package;

