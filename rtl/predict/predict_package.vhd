library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package predict_package is
    function int_to_leading_zeros(x, string_width : integer) return string;

    type state_type is (PREDICT_IDLE, PREDICT_RUNNING, PREDICT_DONE);
    function state_to_string(state : state_type) return string;



end predict_package;

package body predict_package is


    function int_to_leading_zeros(x, string_width : integer) return string is
      variable out_string: string(1 to string_width);
      variable i: integer;
    begin
      for i in 0 to string_width - 1 loop
        out_string(string_width - i to string_width - i) := integer'image(x/(10**i) mod 10);
      end loop;
      return out_string;
    end int_to_leading_zeros;

    function state_to_string(state : state_type) return string is
    begin
      case state is
        when PREDICT_IDLE => return "PREDICT_IDLE";
        when PREDICT_RUNNING => return "PREDICT_RUNNING";
        when PREDICT_DONE => return "PREDICT_DONE";
        when others => return "UNKNOWN";
      end case;
    end state_to_string;
end predict_package;

