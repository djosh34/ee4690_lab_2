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

    constant ADDRESS_WIDTH : integer := get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH);

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal address : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
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

            -- address bus for the weights/inputs (max size of log2(INPUT_SIZE) and log2(HIDDEN_SIZE))
            -- data bus for the weights/inputs 64 bits
            address : in std_logic_vector(get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH) - 1 downto 0);
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

        signal address : out std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        signal data_in : out std_logic_vector(BIT_WIDTH - 1 downto 0);
        signal set_weights_1 : out std_logic;

        n_inputs : integer
      ) is

      variable weights_line : line;
      variable weights_vector : std_logic_vector(INPUT_SIZE - 1 downto 0);

      variable hidden_i : integer := 0;
      variable line_out : line;

      variable address_var : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
      variable data_in_var : std_logic_vector(BIT_WIDTH - 1 downto 0);
    begin

      while not endfile(weights_file) loop

        readline(weights_file, weights_line);
        read(weights_line, weights_vector);



        for i in 0 to n_inputs - 1 loop
          write(line_out, string'("hidden_i: "));
          write(line_out, int_to_leading_zeros(hidden_i, 4));
          write(line_out, string'(" i: "));
          write(line_out, int_to_leading_zeros(i, 3));
          write(line_out, string'(" "));

          address_var := index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, hidden_i, i);
          address <= address_var;

          data_in_var := weights_vector(((i + 1) * BIT_WIDTH) - 1 downto i * BIT_WIDTH);
          data_in <= data_in_var;

          set_weights_1 <= '1';
          wait for 20 ns;
          set_weights_1 <= '0';

          
          write(line_out, string'("Address: "));
          write(line_out, address_var);
          write(line_out, string'(" Data: "));
          write(line_out, data_in_var);
          -- writeline(output, line_out);
        end loop;


        hidden_i := hidden_i + 1;

      end loop;
    end procedure read_and_populate_weights_1;





    -- read and print row from component
    procedure read_and_print_weights_1_row(
        hidden_size : integer;
        n_inputs : integer;

        signal address : out std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        signal enable_weights_1 : out std_logic

      ) is
        variable line_out : line;

        variable address_var : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);

    begin
      for hidden_i in 0 to hidden_size - 1 loop
        for i in 0 to n_inputs - 1 loop
          address_var := index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, hidden_i, i);
          address <= address_var;

          enable_weights_1 <= '1';
          wait for 20 ns;
          enable_weights_1 <= '0';

          write(line_out, string'("hidden_i: "));
          write(line_out, int_to_leading_zeros(hidden_i, 4));
          write(line_out, string'(" i: "));
          write(line_out, int_to_leading_zeros(i, 3));

          write(line_out, string'(" Address: "));
          write(line_out, address_var);
          write(line_out, string'(" Data: "));
          write(line_out, data_out);
          -- writeline(output, line_out);
        end loop;
      end loop;
    end procedure read_and_print_weights_1_row;





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

            address => address,
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

        file weights_1 : text open read_mode is "/pwd/predict/weights/fc1_weight_bin.txt";
        file weights_2 : text open read_mode is "/pwd/predict/weights/fc2_weight_bin.txt";

        variable line_in : line;
        variable line_out : line;
        variable null_line : line;
    begin
        wait for 20 ns;



        -- function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer;
        -- function to_nearest_multiple_of_2(x: integer) return integer;

        -- get_address_width test super simple and non covering
        -- input_size = 768
        -- hidden_size = 1024
        -- output_size = 10
        -- bit_width = 64
        -- output should be:
        -- 1024 + 12
        -- 2**10 + 2**4 = 14 bits

        write(line_out, string'("get_address_width test..."));
        writeline(output, line_out);
        if get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH) /= 14 then
            were_there_errors <= true;
            report "get_address_width failed expected 14 got " & to_string(get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH));
        end if;


        -- next multiple 2 test
        -- 12 -> 16, 24 -> 32, 32 -> 32
        write(line_out, string'("to_nearest_multiple_of_2 test..."));
        writeline(output, line_out);
        if to_nearest_multiple_of_2(12) /= 16 then
            were_there_errors <= true;
            report "to_nearest_multiple_of_2 failed expected 16 got " & to_string(to_nearest_multiple_of_2(12));
        end if;

        if to_nearest_multiple_of_2(24) /= 32 then
            were_there_errors <= true;
            report "to_nearest_multiple_of_2 failed expected 32 got " & to_string(to_nearest_multiple_of_2(24));
        end if;

        if to_nearest_multiple_of_2(32) /= 32 then
            were_there_errors <= true;
            report "to_nearest_multiple_of_2 failed expected 32 got " & to_string(to_nearest_multiple_of_2(32));
        end if;

        -- address weights 1 test
        -- addressing hidden_i = 0, input_i = 0 should be 0 x address_width

        write(line_out, string'("index_to_address for weights 1 test..."));
        writeline(output, line_out);
        if index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, 0, 0) /= "00000000000000" then
            were_there_errors <= true;
            report "index_to_address failed expected 00000000000000 got " & to_string(index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, 0, 0));
        end if;

        -- addressing hidden_i 763, input_i 11 should be:
        -- hidden_i into 10 bits = 763 -> 0b1011111011
        -- 11 into 4 bits = 11 -> 0b1011
        -- thus address = 0b1011111011  + 0b1011 = 0b10111110111011
        if index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, 763, 11) /= "10111110111011" then
            were_there_errors <= true;
            report "index_to_address failed expected 10111110111011 got " & to_string(index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, 763, 11));
        end if;



        -- addressing hidden_i 63, input_i 1 should be:
        -- hidden_i into 10 bits = 63 -> 0b0000111111
        -- 1 into 4 bits = 11 -> 0b0001
        -- thus address = 0b0000111111  + 0b0001 = 0b00001111110001

        if index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, 63, 1) /= "00001111110001" then
            were_there_errors <= true;
            report "index_to_address failed expected 00001111110001 got " & to_string(index_to_address(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, ADDRESS_WIDTH, 63, 1));
        end if;




        write(line_out, string'("index_to_address for weights 2 test..."));
        writeline(output, line_out);

        -- weights 2 are 10 x 1024 = 10 x 16 x 64 bits
        -- addressing is then 10 x 16
        -- 2**4 + 2**4 = 8 bits


        




        write(line_out, string'("Populating weights 1..."));
        writeline(output, line_out);
        read_and_populate_weights_1(weights_1, address, data_in, set_weights_1, INPUT_SIZE / BIT_WIDTH);

        write(line_out, string'("Reading weights 1..."));
        writeline(output, line_out);

        read_and_print_weights_1_row(HIDDEN_SIZE, INPUT_SIZE / BIT_WIDTH, address, enable_weights_1);




        wait for 20 ns;

        if were_there_errors then
            report "Test failed";
        else
            report "Test passed";
        end if;

        wait;
    end process;

end architecture testbench;

