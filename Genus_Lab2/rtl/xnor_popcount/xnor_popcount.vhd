library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;
use work.predict_package.all;

use std.textio.all;


entity xnor_popcount is
    generic (
        N : integer := 768
    );
    port (
        CLK : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        is_valid : out std_logic;

        input_input : in std_logic_vector(0 to N-1);
        input_weights : in std_logic_vector(0 to N-1);

        is_sum_high : out std_logic;
        
        


        -- Debugging signals
        popcount_sum : out unsigned(clog2(N)-1 downto 0) := (others => '0')
    );
end xnor_popcount;

architecture Behavioral of xnor_popcount is
  constant levels : integer := 8;

  -- type top_array_logic_type is array (0 to N-1) of std_logic;
  -- type top_array_type is array (0 to N-1) of unsigned(0 downto 0);
  -- type level_1_array_type is array (0 to N/16-1) of unsigned(5 - 1 downto 0); -- 768/16 = 48
  -- type level_2_array_type is array (0 to N/(16 * 4)-1) of unsigned(7 - 1 downto 0); -- 768/64 = 12
  -- type level_3_array_type is array (0 to N/(16 * 4 * 4)-1) of unsigned(9 - 1 downto 0); -- 768/256 = 3


  signal top_array : std_logic_vector(0 to N-1);
  -- signal top_array : logic_array(0 to N-1);
  -- signal level_1_array : level_1_array_type;
  -- signal level_2_array : level_2_array_type;
  -- signal level_3_array : level_3_array_type;

  -- signal sum1 : unsigned(10 - 1 downto 0) := (others => '0');
  -- signal sum2 : unsigned(10 - 1 downto 0) := (others => '0');
  -- signal sum3 : unsigned(10 - 1 downto 0) := (others => '0');
  -- signal sum4 : unsigned(10 - 1 downto 0) := (others => '0');
  -- signal sum5 : unsigned(10 - 1 downto 0) := (others => '0');
  -- signal sum6 : unsigned(10 - 1 downto 0) := (others => '0');

  type level_1_array_type is array (0 to N/3-1) of integer range 0 to 3;
  type level_2_array_type is array (0 to N/6-1) of integer range 0 to 6;
  type level_3_array_type is array (0 to N/12-1) of integer range 0 to 12;
  type level_4_array_type is array (0 to N/24-1) of integer range 0 to 24;
  type level_5_array_type is array (0 to N/48-1) of integer range 0 to 48;
  type level_6_array_type is array (0 to N/96-1) of integer range 0 to 96;
  type level_7_array_type is array (0 to N/192-1) of integer range 0 to 192;
  type level_8_array_type is array (0 to N/384-1) of integer range 0 to 384;

  signal sum1 : level_1_array_type;
  signal sum2 : level_2_array_type;
  signal sum3 : level_3_array_type;
  signal sum4 : level_4_array_type;
  signal sum5 : level_5_array_type;
  signal sum6 : level_6_array_type;
  signal sum7 : level_7_array_type;
  signal sum8 : level_8_array_type;




  signal popcount_sum_internal : unsigned(clog2(N)-1 downto 0) := (others => '0');
begin

    -- constant top_array = input_input xnor input_weights;
    -- top_array_xnor_mapping : for i in 0 to N-1 generate
    -- begin
    --   top_array(i) <= input_input(i) xnor input_weights(i);
    -- end generate top_array_xnor_mapping;
    top_array <= input_input xnor input_weights;




    is_sum_high <= '1' when popcount_sum_internal >= 384 else '0';
    popcount_sum <= popcount_sum_internal;


    process(clk)
      variable will_be_valid : integer range 0 to levels := 0;

      -- variable top_array_var : unsigned_array(0 to N-1);
      -- variable level_1_array_var : level_1_array_type;
      -- variable level_2_array_var : level_2_array_type;
      -- variable level_3_array_var : level_3_array_type;
      -- variable final_sum_var : unsigned(10 - 1 downto 0);
      -- variable bit_add : unsigned(0 downto 0) := (others => '0');
      -- variable sum : unsigned(10 - 1 downto 0) := (others => '0');

      variable bit_add1 : integer range 0 to 1 := 0;
      variable bit_add2 : integer range 0 to 1 := 0;
      variable bit_add3 : integer range 0 to 1 := 0;
      variable bit_add4 : integer range 0 to 1 := 0;
      variable bit_add5 : integer range 0 to 1 := 0;
      variable bit_add6 : integer range 0 to 1 := 0;
      variable bit_add7 : integer range 0 to 1 := 0;
      variable bit_add8 : integer range 0 to 1 := 0;

      signal sum1_var : level_1_array_type;
      signal sum2_var : level_2_array_type;
      signal sum3_var : level_3_array_type;
      signal sum4_var : level_4_array_type;
      signal sum5_var : level_5_array_type;
      signal sum6_var : level_6_array_type;
      signal sum7_var : level_7_array_type;
      signal sum8_var : level_8_array_type;


      variable line_out : line;


    begin
        if rising_edge(clk) then
          if rst = '1' then

            is_valid <= '0';
            -- will_be_valid := 0;
            -- level_1_array <= (others => (others => '0'));
            -- level_2_array <= (others => (others => '0'));
            -- level_3_array <= (others => (others => '0'));
            bit_add := (others => '0');
            sum := (others => '0');

            sum1 <= (others => '0');
            sum2 <= (others => '0');
            sum3 <= (others => '0');
            sum4 <= (others => '0');
            sum5 <= (others => '0');
            sum6 <= (others => '0');

          else

            -- sum top_array_type -> level_1_array_type
            -- top_array_var := array_to_unsigned(top_array);

            -- for i in 0 to N/16-1 loop
            --   level_1_array_var(i) := (others => '0');
            --   for j in 0 to 15 loop
            --     level_1_array_var(i) := level_1_array_var(i) + unsigned(top_array_var(i*16 + j));
            --   end loop;
            -- end loop;

            -- level_1_array <= level_1_array_var;

            -- -- sum level_1_array_type -> level_2_array_type
            -- for i in 0 to N/(16 * 4)-1 loop
            --   level_2_array_var(i) := (others => '0');
            --   for j in 0 to 3 loop
            --     level_2_array_var(i) := level_2_array_var(i) + level_1_array(i*4 + j);
            --   end loop;
            -- end loop;

            -- level_2_array <= level_2_array_var;

            -- -- sum level_2_array_type -> level_3_array_type
            -- for i in 0 to N/(16 * 4 * 4)-1 loop
            --   level_3_array_var(i) := (others => '0');
            --   for j in 0 to 3 loop
            --     level_3_array_var(i) := level_3_array_var(i) + level_2_array(i*4 + j);
            --   end loop;
            -- end loop;

            -- level_3_array <= level_3_array_var;

            -- -- sum level_3_array_type -> final_sum_type
            -- final_sum_var := (others => '0');
            -- for i in 0 to N/(16 * 4 * 4)-1 loop
            --   final_sum_var := final_sum_var + level_3_array(i);
            -- end loop;

            -- popcount_sum_internal <= final_sum_var;

            -- alternative direct sum
            -- sum := (others => '0');
            -- for i in 0 to N-1 loop
            --   bit_add := ("" & top_array(i));
            --   sum := sum + bit_add;
            -- end loop;
            -- popcount_sum_internal <= sum;


            





            --- try tree

            for i in 0 to N/3-1 loop
              sum1_var(i) := 0;
              for j in 0 to 2 loop
                bit_add1 := top_array(i*3 + j);
                sum1_var(i) := sum1_var(i) + bit_add1;
              end loop;
              sum1(i) <= sum1_var(i);
            end loop;

            for i in 0 to N/6-1 loop
              sum2_var(i) := 0;
              for j in 0 to 1 loop
                bit_add2 := sum1(i*6 + j);
                sum2_var(i) := sum2_var(i) + bit_add2;
              end loop;
              sum2(i) <= sum2_var(i);
            end loop;

            for i in 0 to N/12-1 loop
              sum3_var(i) := 0;
              for j in 0 to 1 loop
                bit_add3 := sum2(i*12 + j);
                sum3_var(i) := sum3_var(i) + bit_add3;
              end loop;
              sum3(i) <= sum3_var(i);
            end loop;
            
            for i in 0 to N/24-1 loop
              sum4_var(i) := 0;
              for j in 0 to 1 loop
                bit_add4 := sum3(i*24 + j);
                sum4_var(i) := sum4_var(i) + bit_add4;
              end loop;
              sum4(i) <= sum4_var(i);
            end loop;

            for i in 0 to N/48-1 loop
              sum5_var(i) := 0;
              for j in 0 to 1 loop
                bit_add5 := sum4(i*48 + j);
                sum5_var(i) := sum5_var(i) + bit_add5;
              end loop;
              sum5(i) <= sum5_var(i);
            end loop;

            for i in 0 to N/96-1 loop
              sum6_var(i) := 0;
              for j in 0 to 1 loop
                bit_add6 := sum5(i*96 + j);
                sum6_var(i) := sum6_var(i) + bit_add6;
              end loop;
              sum6(i) <= sum6_var(i);
            end loop;

            for i in 0 to N/192-1 loop
              sum7_var(i) := 0;
              for j in 0 to 1 loop
                bit_add7 := sum6(i*192 + j);
                sum7_var(i) := sum7_var(i) + bit_add7;
              end loop;
              sum7(i) <= sum7_var(i);
            end loop;

            for i in 0 to N/384-1 loop
              sum8_var(i) := 0;
              for j in 0 to 1 loop
                bit_add8 := sum7(i*384 + j);
                sum8_var(i) := sum8_var(i) + bit_add8;
              end loop;
              sum8(i) <= sum8_var(i);
            end loop;


            popcount_sum_internal <= sum8(0) + sum8(1);





            if will_be_valid = levels then
              is_valid <= '1';
            else
              will_be_valid := will_be_valid + 1;
            end if;
        end if;
      end if;
    end process;








end Behavioral;

