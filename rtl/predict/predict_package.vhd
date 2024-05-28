library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package predict_package is
  function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer;
  function to_nearest_multiple_of_2(x: integer) return integer;
  function index_to_address(INDEX_SIZE, BIT_WIDTH_INDEX_SIZE, ADDRESS_SIZE, hidden_i, input_i :integer) return std_logic_vector;
  function int_to_leading_zeros(x, string_width : integer) return string;



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


  function index_to_address(INDEX_SIZE, BIT_WIDTH_INDEX_SIZE, ADDRESS_SIZE, hidden_i, input_i :integer) return std_logic_vector is
    variable nearest_multiple: integer;
  begin
    -- it must be that the first bits are for the hidden layer and the last bits are for the input layer
    -- so for 1024 hidden size and 12 * 64 input size, the first 10 bits are for the hidden layer and the last 4 bits are for the input layer
    -- so the address is hidden_i * 64 + input_i

    nearest_multiple := to_nearest_multiple_of_2(BIT_WIDTH_INDEX_SIZE);


    return std_logic_vector(to_unsigned(hidden_i * nearest_multiple + input_i, ADDRESS_SIZE));
  end index_to_address;

-- Range is limited to from 1 to 9 as 10 digit
-- integer can already overflow in VHDL
-- function fIntToStringLeading0 (a : natural; d : integer range 1 to 9) return string is
--   variable vString : string(1 to d);
-- begin
--   if(a >= 10**d) then
--     return integer'image(a);
--   else
--     for i in 0 to d-1 loop
--       vString(d-i to d-i) := integer'image(a/(10**i) mod 10);
--     end loop;
--     return vString;
--   end if;
-- end function;

    function int_to_leading_zeros(x, string_width : integer) return string is
      variable out_string: string(1 to string_width);
      variable i: integer;
    begin
      for i in 0 to string_width - 1 loop
        out_string(string_width - i to string_width - i) := integer'image(x/(10**i) mod 10);
      end loop;
      return out_string;
    end int_to_leading_zeros;

end predict_package;

