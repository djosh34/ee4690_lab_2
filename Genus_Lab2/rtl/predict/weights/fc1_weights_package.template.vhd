library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

use std.textio.all;
use ieee.std_logic_textio.all;


package fc1_weights_package is
    constant INPUT_SIZE : integer := 768;
    constant HIDDEN_SIZE : integer := 1024;

    type weights_1_type is array(0 to HIDDEN_SIZE - 1) of std_logic_vector(0 to INPUT_SIZE - 1);

    function read_and_populate_weights_1 return weights_1_type;
end fc1_weights_package;

package body fc1_weights_package is
    -- populate the weights_1 array
    function read_and_populate_weights_1 return weights_1_type is
      variable weights_array : weights_1_type;

      variable i : integer := 0;
    begin

      -- weights array: 1024 x 768 
      -- weights_array(0) := "....";
      $WEIGHTS_ARRAY

      return weights_array;
    end function;
end fc1_weights_package;

