library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;

use std.textio.all;

library work;
use work.predict_package.all;

entity predict is
    generic (
        INPUT_SIZE : integer := 768;
        HIDDEN_SIZE : integer := 1024;
        OUTPUT_SIZE : integer := 10;
        weights_1_filename : string;
        weights_2_filename : string
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        done : out std_logic
    );
end predict;

architecture Behavioral of predict is
    -- - [ ] Matrix weights_1 1024 * 768 bits = 1024 * 12 * 64 bits
    -- - [ ] Matrix  weights_2 10 * 1024 bits = 10 * 16 * 64 bits


    file weights_1_file : text open read_mode is weights_1_filename;
    file weights_2_file : text open read_mode is weights_2_filename;


    constant weights_1 : weights_1_type := read_and_populate_weights_1(weights_1_file);
    constant weights_2 : weights_2_type := read_and_populate_weights_2(weights_2_file);

    signal input : std_logic_vector(0 to INPUT_SIZE - 1);
    

begin



    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then

            elsif rst = '0' then
            end if;


        end if;
    end process;

end Behavioral;

