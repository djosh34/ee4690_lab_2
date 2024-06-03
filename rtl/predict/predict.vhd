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
        temp_sum_popcount : out natural;
        hidden_i_internal_index : out natural;
        input_i_internal_index : out natural;
        state : out state_type := PREDICT_IDLE;

        -- end debugging signals


        done : out std_logic
    );
end predict;

architecture Behavioral of predict is
    -- - [ ] Matrix weights_1 1024 * 768 bits = 1024 * 12 * 64 bits
    -- - [ ] Matrix  weights_2 10 * 1024 bits = 10 * 16 * 64 bits



    signal weights_1 : weights_1_type;
    signal weights_2 : weights_2_type;
    signal input : input_type;
    

begin



    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
              -- reset the weights
              for i in 0 to HIDDEN_SIZE - 1 loop
                for j in 0 to N_INPUTS - 1 loop
                  weights_1(i, j) <= (others => '0');
                end loop;
              end loop;

              for i in 0 to N_HIDDEN - 1 loop
                weights_2(i) <= (others => '0');
              end loop;

              -- reset the input
              for i in 0 to N_INPUTS - 1 loop
                input(i) <= (others => '0');
              end loop;

              done <= '0';
              data_out <= (others => '0');
              prediction <= (others => '0');

              temp_sum_popcount <= 0;
              hidden_i_internal_index <= 0;
              input_i_internal_index <= 0;
              state <= PREDICT_IDLE;

            elsif rst = '0' then


              case state is
                when PREDICT_IDLE =>
                  if start = '0' then
                    if set_weights_1 = '1' then
                      weights_1(hidden_i, input_or_output_i) <= data_in;
                    end if;

                    if set_weights_2 = '1' then
                      weights_2(hidden_i) <= data_in(OUTPUT_SIZE - 1 downto 0);
                    end if;

                    if set_input = '1' then
                      input(input_or_output_i) <= data_in;
                    end if;

                    if enable_input = '1' then
                      data_out <= input(input_or_output_i);
                    end if;

                    if enable_weights_1 = '1' then
                      data_out <= weights_1(hidden_i, input_or_output_i);
                    end if;

                    if enable_weights_2 = '1' then
                      data_out <= (others => '0');
                      data_out(OUTPUT_SIZE - 1 downto 0) <= weights_2(hidden_i);
                    end if;

                  elsif start = '1' then
                    state <= PREDICT_RUNNING;
                  end if;
                when PREDICT_RUNNING =>
                  state <= PREDICT_DONE;
                  -- state <= PREDICT_INPUT;
                -- when PREDICT_INPUT =>
                  -- state <= PREDICT_HIDDEN;
                -- when PREDICT_HIDDEN =>
                  -- state <= PREDICT_OUTPUT;
                -- when PREDICT_OUTPUT =>
                  -- state <= PREDICT_DONE;
                when PREDICT_DONE =>
                  state <= PREDICT_IDLE;
                  done <= '1';
                when others =>
                  state <= PREDICT_IDLE;
              end case;

            end if;



        end if;
    end process;

end Behavioral;

