library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package predict_package is
    function int_to_leading_zeros(x, string_width : integer) return string;
    function clog2(x : integer) return integer;
    function std_logic_to_boolean_char(x : std_logic) return string;


    type logic_array is array (natural range <>) of std_logic;
    type unsigned_array is array (natural range <>) of unsigned(0 downto 0);
    function array_to_unsigned(input: logic_array) return unsigned_array;


    type state_type is (PREDICT_IDLE, PREDICT_RUNNING, PREDICT_DONE);
    function state_to_string(state : state_type) return string;



    constant INPUT_SIZE : integer := 784;
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;

    type weights_1_type is array(0 to HIDDEN_SIZE - 1) of std_logic_vector(0 to INPUT_SIZE - 1);
    type weights_2_type is array(0 to HIDDEN_SIZE - 1) of std_logic_vector(0 to OUTPUT_SIZE - 1);



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


    function clog2(x : integer) return integer is
      variable i : integer := 0;
    begin
      while 2**i < x loop
        i := i + 1;
      end loop;
      return i;
    end clog2;


    function std_logic_to_boolean_char(x : std_logic) return string is
    begin
      if x = '1' then
        return "TRUE ";
      else
        return "FALSE";
      end if;
    end std_logic_to_boolean_char;


    function array_to_unsigned(input: logic_array) return unsigned_array is
      variable output: unsigned_array(0 to input'length - 1);
    begin
      for i in 0 to input'length - 1 loop
        output(i) := "" & input(i);
      end loop;
      return output;
    end array_to_unsigned;

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

