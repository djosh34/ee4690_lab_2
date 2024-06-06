library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

use std.textio.all;

package predict_package is
    function int_to_leading_zeros(x, string_width : integer) return string;
    function clog2(x : integer) return integer;
    function std_logic_to_boolean_char(x : std_logic) return string;


    type logic_array is array (natural range <>) of std_logic;
    type unsigned_array is array (natural range <>) of unsigned(0 downto 0);
    function array_to_unsigned(input: logic_array) return unsigned_array;


    type state_type is (PREDICT_IDLE, PREDICT_RUNNING, PREDICT_DONE);
    function state_to_string(state : state_type) return string;



    constant INPUT_SIZE : integer := 768;
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;

    type weights_1_type is array(0 to HIDDEN_SIZE - 1) of std_logic_vector(0 to INPUT_SIZE - 1);
    type weights_2_type is array(0 to HIDDEN_SIZE - 1) of std_logic_vector(0 to OUTPUT_SIZE - 1);

    type weights_temp_array_type is array(0 to OUTPUT_SIZE - 1) of std_logic_vector(0 to HIDDEN_SIZE - 1);

    function read_and_populate_weights_1(file weights_1_file : text) return weights_1_type;
    function read_and_populate_weights_2(file weights_2_file : text) return weights_2_type;



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



    -- populate the weights_1 array
    function read_and_populate_weights_1(file weights_1_file : text) return weights_1_type is

      variable weights_line : line;
      variable weights_vector : std_logic_vector(0 to INPUT_SIZE - 1);
      variable weights_array : weights_1_type;

      variable i : integer := 0;

      variable line_out : line;
    begin
      write(line_out, string'("Reading weights 1 from file..."));
      writeline(output, line_out);

      -- weights array: 1024 x 768 
      while not endfile(weights_1_file) loop

        readline(weights_1_file, weights_line);
        read(weights_line, weights_vector);

        weights_array(i) := weights_vector;

        -- write(line_out, string'("i: "));
        -- write(line_out, int_to_leading_zeros(i, 4));
        -- write(line_out, string'(" "));
        -- write(line_out, string'(" Data: "));
        -- write(line_out, weights_array(i));
        -- writeline(output, line_out);

        i := i + 1;

        -- if i > 10 then
        --   report "Too many weights in file" severity failure;
        -- end if;




      end loop;

      write(line_out, string'("Done reading weights 1 from file..."));
      writeline(output, line_out);

      return weights_array;
    end function;



    -- populate the weights_2 array
    function read_and_populate_weights_2(file weights_2_file : text) return weights_2_type is

      variable weights_temp_array : weights_temp_array_type;
      variable weights_out_array : weights_2_type;

      variable weights_line : line;
      variable output_i : integer := 0;


      variable line_out : line;
    begin
      write(line_out, string'("Reading weights 2 from file..."));
      writeline(output, line_out);

      -- weights array: 10 x 1024
      while not endfile(weights_2_file) loop

        readline(weights_2_file, weights_line);
        read(weights_line, weights_temp_array(output_i));

        -- write(line_out, string'("output_i: "));
        -- write(line_out, int_to_leading_zeros(output_i, 4));
        -- write(line_out, string'(" "));
        -- write(line_out, string'(" Data: "));
        -- write(line_out, weights_temp_array(output_i));
        -- writeline(output, line_out);

        output_i := output_i + 1;

        -- if output_i > 10 then
        --   report "Too many weights in file" severity failure;
        -- end if;
      end loop;

      write(line_out, string'("Done reading weights 2 from file..."));
      writeline(output, line_out);
      write(line_out, string'("Populating weights 2..."));
      writeline(output, line_out);

    -- virtual transpose, so now output for each hidden_i output 10 bits
      weights_out_array := (others => (others => '0'));
      for i in 0 to HIDDEN_SIZE - 1 loop

        for j in 0 to OUTPUT_SIZE - 1 loop
          weights_out_array(i)(j) := weights_temp_array(j)(i);
        end loop;

        -- write(line_out, string'("i: "));
        -- write(line_out, int_to_leading_zeros(i, 4));
        -- write(line_out, string'(" Data: "));
        -- write(line_out, weights_out_array(i));
        -- writeline(output, line_out);

      end loop;


      return weights_out_array;
    end function;

end predict_package;

