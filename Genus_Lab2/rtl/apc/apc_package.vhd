library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package apc_package is
    function int_to_leading_zeros(x, string_width : integer) return string;




end apc_package;

package body apc_package is


    function int_to_leading_zeros(x, string_width : integer) return string is
      variable out_string: string(1 to string_width);
      variable i: integer;
    begin
      for i in 0 to string_width - 1 loop
        out_string(string_width - i to string_width - i) := integer'image(x/(10**i) mod 10);
      end loop;
      return out_string;
    end int_to_leading_zeros;

end apc_package;

