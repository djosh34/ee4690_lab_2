library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;
use std.env.all;

library work;
use work.predict_package.all;

entity predict_testbench is
end predict_testbench;

architecture testbench of predict_testbench is

    constant INPUT_SIZE : integer := 768;
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;
    constant clk_period : time := 20 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal done : std_logic;


    constant weights_1_filename : string := "/pwd/predict/weights/fc1_weight_bin.txt";
    constant weights_2_filename : string := "/pwd/predict/weights/fc2_weight_bin.txt";




begin
    uut: entity work.predict
        generic map (
            INPUT_SIZE => INPUT_SIZE,
            HIDDEN_SIZE => HIDDEN_SIZE,
            OUTPUT_SIZE => OUTPUT_SIZE,
            weights_1_filename => weights_1_filename,
            weights_2_filename => weights_2_filename 
        )
        port map (
            clk => clk,
            rst => rst,

            done => done
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test process
    process
        file testdata : text open read_mode is  "/pwd/predict/examples/1_test_data_bin.txt";
        file labeldata : text open read_mode is "/pwd/predict/examples/1_test_labels_bin.txt";


        variable line_in : line;
        variable line_out : line;
        variable null_line : line;

        variable i_loop_stopper : integer := 0;
        variable were_there_errors : boolean := false;
    begin
        wait for 20 ns;






        while done /= '1' loop

            wait for 20 ns;




            i_loop_stopper := i_loop_stopper + 1;

            if i_loop_stopper > 100 then
                report "Test failed";
                finish;
            end if;
        end loop;




        write(line_out, string'("Test is finished..."));
        writeline(output, line_out);



        wait for 20 ns;

        if were_there_errors then
            report "Test failed";
            finish;
        else
            report "Test passed";
            finish;
        end if;

        wait;
    end process;

end architecture testbench;

