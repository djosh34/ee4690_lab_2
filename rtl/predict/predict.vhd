library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;

library work;
use work.predict_package.all;

entity predict is
    generic (
        BIT_WIDTH : integer := 64;
        INPUT_SIZE : integer := 768;
        HIDDEN_SIZE : integer := 1024;
        OUTPUT_SIZE : integer := 10
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;

        address : in std_logic_vector(get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH) - 1 downto 0);
        data : in std_logic_vector(BIT_WIDTH - 1 downto 0);

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
end predict;

architecture Behavioral of predict is
    -- - [ ] Matrix weights_1 1024 * 768 bits = 1024 * 12 * 64 bits
    -- - [ ] Matrix  weights_2 10 * 1024 bits = 10 * 16 * 64 bits
    constant N_INPUTS : integer := INPUT_SIZE / BIT_WIDTH;
    constant N_HIDDEN : integer := HIDDEN_SIZE / BIT_WIDTH;

    type weights_1_type is array(0 to HIDDEN_SIZE - 1, 0 to N_INPUTS - 1) of std_logic_vector(BIT_WIDTH - 1 downto 0);
    type weights_2_type is array(0 to OUTPUT_SIZE - 1, 0 to N_HIDDEN - 1) of std_logic_vector(BIT_WIDTH - 1 downto 0);
    type input_type is array(0 to N_INPUTS - 1) of std_logic_vector(BIT_WIDTH - 1 downto 0);


    signal weights_1 : weights_1_type;
    signal weights_2 : weights_2_type;
    signal input : input_type;
    

begin



    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then

            elsif start = '1' then
            end if;
        end if;
    end process;

end Behavioral;

