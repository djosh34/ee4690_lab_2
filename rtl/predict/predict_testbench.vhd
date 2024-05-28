library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;

library work;
use work.predict_package.all;

entity predict_testbench is
end predict_testbench;

architecture testbench of predict_testbench is

    function log2ceil(val : integer) return integer is
        variable result : integer := 0;
        variable v : integer := val-1;
    begin
        while v > 0 loop
            v := v / 2;
            result := result + 1;
        end loop;
        return result;
    end function;


    constant BIT_WIDTH : integer := 64;
    constant INPUT_SIZE : integer := 768;
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal input_or_output_i : natural;
    signal hidden_i : natural;
    signal data_in : std_logic_vector(BIT_WIDTH - 1 downto 0);
    signal data_out : std_logic_vector(BIT_WIDTH - 1 downto 0);


    signal set_weights_1 : std_logic;
    signal set_weights_2 : std_logic;
    signal set_input : std_logic;

    signal enable_input : std_logic;
    signal enable_weights_1 : std_logic;
    signal enable_weights_2 : std_logic;

    signal prediction : std_logic_vector(OUTPUT_SIZE - 1 downto 0);

    component predict
        generic (
            BIT_WIDTH : integer;
            INPUT_SIZE : integer;
            HIDDEN_SIZE : integer;
            OUTPUT_SIZE : integer
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;

            input_or_output_i : in natural;
            hidden_i : in natural;
            data_in : in std_logic_vector(BIT_WIDTH - 1 downto 0);
            data_out : out std_logic_vector(BIT_WIDTH - 1 downto 0);

            -- set weights 1
            -- set weights 2
            -- set input
            -- enable (read) input
            -- enable (read) weights 1
            -- enable (read) weights 2
            set_weights_1 : in std_logic;
            set_weights_2 : in std_logic;
            set_input : in std_logic;

            enable_input : in std_logic;
            enable_weights_1 : in std_logic;
            enable_weights_2 : in std_logic;



            -- output bus for the prediction
            prediction : out std_logic_vector(OUTPUT_SIZE - 1 downto 0);


            -- debugging signals

            -- end debugging signals


            done : out std_logic
        );
    end component;

    signal were_there_errors : boolean := false;
    signal cycle_count : integer := 0;


    -- populate the weights_1 array
    procedure read_and_populate_weights_1(
        file weights_file : text;

        signal input_or_output_i : out natural;
        signal hidden_i : out natural;

        signal data_in : out std_logic_vector(BIT_WIDTH - 1 downto 0);
        signal set_weights : out std_logic;

        n_inputs : integer
      ) is

      variable weights_line : line;
      variable weights_vector : std_logic_vector(INPUT_SIZE - 1 downto 0);

      variable hidden_i_internal : integer := 0;
      variable line_out : line;

      variable data_in_var : std_logic_vector(BIT_WIDTH - 1 downto 0);
    begin

      while not endfile(weights_file) loop

        readline(weights_file, weights_line);
        read(weights_line, weights_vector);



        for i in 0 to n_inputs - 1 loop

          input_or_output_i <= i;
          hidden_i <= hidden_i_internal;

          data_in_var := weights_vector(((i + 1) * BIT_WIDTH) - 1 downto i * BIT_WIDTH);
          data_in <= data_in_var;

          set_weights <= '1';
          wait for 20 ns;
          set_weights <= '0';

          
          write(line_out, string'("hidden_i: "));
          write(line_out, int_to_leading_zeros(hidden_i_internal, 4));
          write(line_out, string'(" i: "));
          write(line_out, int_to_leading_zeros(i, 3));
          write(line_out, string'(" "));
          write(line_out, string'(" Data: "));
          write(line_out, data_in_var);
          writeline(output, line_out);
        end loop;


        hidden_i_internal := hidden_i_internal + 1;

      end loop;
    end procedure read_and_populate_weights_1;







    -- read and print row from component
    procedure read_and_print_weights_1(
        hidden_size : integer;
        n_inputs : integer;

        signal input_or_output_i : out natural;
        signal hidden_i : out natural;
        signal enable_weights_1 : out std_logic

      ) is
        variable line_out : line;


    begin
      for hidden_i_internal in 0 to hidden_size - 1 loop
        for i in 0 to n_inputs - 1 loop

          input_or_output_i <= i;
          hidden_i <= hidden_i_internal;

          enable_weights_1 <= '1';
          wait for 20 ns;
          enable_weights_1 <= '0';

          write(line_out, string'("hidden_i: "));
          write(line_out, int_to_leading_zeros(hidden_i_internal, 4));
          write(line_out, string'(" i: "));
          write(line_out, int_to_leading_zeros(i, 3));

          write(line_out, string'(" Data: "));
          write(line_out, data_out);
          writeline(output, line_out);
        end loop;
      end loop;
    end procedure read_and_print_weights_1;





begin
    uut: predict
        generic map (
            BIT_WIDTH => BIT_WIDTH,
            INPUT_SIZE => INPUT_SIZE,
            HIDDEN_SIZE => HIDDEN_SIZE,
            OUTPUT_SIZE => OUTPUT_SIZE
        )
        port map (
            clk => clk,
            rst => rst,
            start => start,

            input_or_output_i => input_or_output_i,
            hidden_i => hidden_i,
            data_in => data_in,
            data_out => data_out,

            set_weights_1 => set_weights_1,
            set_weights_2 => set_weights_2,
            set_input => set_input,

            enable_input => enable_input,
            enable_weights_1 => enable_weights_1,
            enable_weights_2 => enable_weights_2,

            prediction => prediction,

            done => done
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Test process
    process
        file testdata : text open read_mode is  "/pwd/predict/examples/1_test_data_bin.txt";
        file labeldata : text open read_mode is "/pwd/predict/examples/1_test_labels_bin.txt";

        file weights_1_file : text open read_mode is "/pwd/predict/weights/fc1_weight_bin.txt";
        file weights_2_file : text open read_mode is "/pwd/predict/weights/fc2_weight_bin.txt";

        variable line_in : line;
        variable line_out : line;
        variable null_line : line;
    begin
        wait for 20 ns;



        write(line_out, string'("Populating weights 1..."));
        writeline(output, line_out);
        read_and_populate_weights_1(weights_1_file, input_or_output_i, hidden_i, data_in, set_weights_1, INPUT_SIZE / BIT_WIDTH);

        write(line_out, string'("Reading weights 1..."));
        writeline(output, line_out);
        read_and_print_weights_1(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, input_or_output_i, hidden_i, enable_weights_1);


        -- write(line_out, string'("Populating weights 2..."));
        -- writeline(output, line_out);
        -- read_and_populate_weights(weights_2_file, hidden_i, input_or_output_i, data_in, set_weights_2, HIDDEN_SIZE / BIT_WIDTH);

        -- write(line_out, string'("Reading weights 2..."));
        -- writeline(output, line_out);
        -- read_and_print_weights(OUTPUT_SIZE, HIDDEN_SIZE / BIT_WIDTH, hidden_i, input_or_output_i, enable_weights_2);




        wait for 20 ns;

        if were_there_errors then
            report "Test failed";
        else
            report "Test passed";
        end if;

        wait;
    end process;

end architecture testbench;

