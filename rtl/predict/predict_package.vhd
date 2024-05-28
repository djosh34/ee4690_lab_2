library ieee;

use IEEE.math_real.all;

package predict_package is
  function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer;

end predict_package;

package body predict_package is

  --         address : in std_logic_vector(maximum(integer(log2(real(INPUT_SIZE/BIT_WIDTH))), maximum(integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH))), integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH))))) - 1 downto 0);

  function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer is
    variable address_width: integer;

  begin
    return maximum(integer(log2(real(INPUT_SIZE/BIT_WIDTH))), maximum(integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH))), integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH)))));
  end get_address_width;
end predict_package;

