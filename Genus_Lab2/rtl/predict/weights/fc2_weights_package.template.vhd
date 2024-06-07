library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;


package fc2_weights_package is
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;

    type weights_2_type is array(0 to HIDDEN_SIZE - 1) of std_logic_vector(0 to OUTPUT_SIZE - 1);

    function read_and_populate_weights_2 return weights_2_type;
end fc2_weights_package;

package body fc2_weights_package is
    -- populate the weights_1 array
    function read_and_populate_weights_2 return weights_2_type is
      variable weights_array : weights_2_type;

    begin

      -- weights array: 1024 x 768 
      -- weights_array(0) := "....";
      $WEIGHTS_ARRAY

      return weights_array;
    end function;
end fc2_weights_package;

