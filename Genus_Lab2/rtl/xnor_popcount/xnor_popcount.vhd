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

        is_sum_high : out std_logic
        
        


        -- Debugging signals
        -- popcount_sum : out integer range 0 to 768
    );
end xnor_popcount;

architecture Behavioral of xnor_popcount is
  constant levels : integer := 4;

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

  -- type level_1_array_type is array (0 to N/3-1) of integer range 0 to 3;
  -- type level_2_array_type is array (0 to N/6-1) of integer range 0 to 6;
  -- type level_3_array_type is array (0 to N/12-1) of integer range 0 to 12;
  -- type level_4_array_type is array (0 to N/24-1) of integer range 0 to 24;
  -- type level_5_array_type is array (0 to N/48-1) of integer range 0 to 48;
  -- type level_6_array_type is array (0 to N/96-1) of integer range 0 to 96;
  -- type level_7_array_type is array (0 to N/192-1) of integer range 0 to 192;
  -- type level_8_array_type is array (0 to N/384-1) of integer range 0 to 384;

  -- signal sum1 : level_1_array_type;
  -- signal sum2 : level_2_array_type;
  -- signal sum3 : level_3_array_type;
  -- signal sum4 : level_4_array_type;
  -- signal sum5 : level_5_array_type;
  -- signal sum6 : level_6_array_type;
  -- signal sum7 : level_7_array_type;
  -- signal sum8 : level_8_array_type;

  -- type level_0_array_type is array (0 to N/4-1) of integer range 0 to 4;
  type level_1_array_type is array (0 to N/16-1) of integer range 0 to 16;
  -- type level_2_array_type is array (0 to N/64-1) of integer range 0 to 64;
  type level_3_array_type is array (0 to N/256-1) of integer range 0 to 256;

  -- signal sum0 : level_0_array_type;
  -- signal sum1 : level_1_array_type;
  signal sum2 : level_1_array_type;
  signal sum3 : level_3_array_type;



  -- signal popcount_sum_internal : integer range 0 to 768;
begin

    -- constant top_array = input_input xnor input_weights;
    -- top_array_xnor_mapping : for i in 0 to N-1 generate
    -- begin
    --   top_array(i) <= input_input(i) xnor input_weights(i);
    -- end generate top_array_xnor_mapping;
    -- top_array <= input_input xnor input_weights;




    -- is_sum_high <= '1' when popcount_sum_internal >= 384 else '0';
    -- popcount_sum <= to_unsigned(popcount_sum_internal, clog2(N));


    process(clk)
      variable will_be_valid : integer range 0 to levels := 0;

      -- variable top_array_var : unsigned_array(0 to N-1);
      -- variable level_1_array_var : level_1_array_type;
      -- variable level_2_array_var : level_2_array_type;
      -- variable level_3_array_var : level_3_array_type;
      -- variable final_sum_var : unsigned(10 - 1 downto 0);
      -- variable bit_add : integer range 0 to 1 := 0;
      -- variable sum : integer range 0 to 768 := 0;

      -- variable bit_add1 : integer range 0 to 3 := 0;
      -- variable bit_add2 : integer range 0 to 6 := 0;
      -- variable bit_add3 : integer range 0 to 12 := 0;
      -- variable bit_add4 : integer range 0 to 24 := 0;
      -- variable bit_add5 : integer range 0 to 48 := 0;
      -- variable bit_add6 : integer range 0 to 96 := 0;
      -- variable bit_add7 : integer range 0 to 192 := 0;
      -- variable bit_add8 : integer range 0 to 384 := 0;

      -- variable sum1_var : level_1_array_type;
      -- variable sum2_var : level_2_array_type;
      -- variable sum3_var : level_3_array_type;
      -- variable sum4_var : level_4_array_type;
      -- variable sum5_var : level_5_array_type;
      -- variable sum6_var : level_6_array_type;
      -- variable sum7_var : level_7_array_type;
      -- variable sum8_var : level_8_array_type;

      -- variable bit_add0 : integer range 0 to 4 := 0;
      -- variable bit_add1 : integer range 0 to 16 := 0;
      variable bit_add2 : integer range 0 to 1 := 0;
      variable bit_add3 : integer range 0 to 256 := 0;

      -- variable sum0_var : level_0_array_type;
      -- variable sum1_var : level_1_array_type;
      variable sum2_var : level_1_array_type;
      variable sum3_var : level_3_array_type;
      variable end_sum  : integer range 0 to 768 := 0;


      variable line_out : line;


    begin
        if rising_edge(clk) then
          if rst = '1' then

            is_valid <= '0';
            -- will_be_valid := 0;
            -- level_1_array <= (others => (others => '0'));
            -- level_2_array <= (others => (others => '0'));
            -- level_3_array <= (others => (others => '0'));
            -- bit_add := 0;
            -- sum := 0;

            -- sum1 <= (others => 0);
            -- sum2 <= (others => 0);
            -- sum3 <= (others => 0);
            -- sum4 <= (others => 0);
            -- sum5 <= (others => 0);
            -- sum6 <= (others => 0);
            -- sum7 <= (others => 0);
            -- sum8 <= (others => 0);

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
            -- sum := 0;
            -- for i in 0 to N-1 loop
            --   if top_array(i) = '1' then
            --     bit_add := 1;
            --   else
            --     bit_add := 0;
            --   end if;
            --   sum := sum + bit_add;
            -- end loop;
            -- -- popcount_sum_internal <= sum;

            -- if sum >= 384 then
            --   is_sum_high <= '1';
            -- else
            --   is_sum_high <= '0';
            -- end if;


            
            -- is_valid <= '1';



            --- try tree 2
            -- for i in 0 to N/4-1 loop
            --   sum0_var(i) := 0;
            --   for j in 0 to 3 loop
            --     if top_array(i*4 + j) = '1' then
            --       bit_add0 := 1;
            --     else
            --       bit_add0 := 0;
            --     end if;
            --     sum0_var(i) := sum0_var(i) + bit_add0;
            --   end loop;
            --   sum0(i) <= sum0_var(i);
            -- end loop;

            -- for i in 0 to N/16-1 loop
            --   sum1_var(i) := 0;
            --   for j in 0 to 3 loop
            --     bit_add1 := sum0(i*4 + j);
            --     sum1_var(i) := sum1_var(i) + bit_add1;
            --   end loop;
            --   sum1(i) <= sum1_var(i);
            -- end loop;

            -- for i in 0 to N/64-1 loop
            --   sum2_var(i) := 0;
            --   for j in 0 to 3 loop
            --     bit_add2 := sum1(i*4 + j);
            --     sum2_var(i) := sum2_var(i) + bit_add2;
            --   end loop;
            --   sum2(i) <= sum2_var(i);
            -- end loop;



--             for i in 0 to N/64-1 loop
--               sum2_var(i) := 0;
--               write(line_out, string'(" "));
--               for j in 0 to 63 loop
--                 if input_input(i*64 + j) = input_weights(i*64 + j) then
--                   bit_add2 := 1;
--                   write(line_out, string'("1"));
--                 else
--                   bit_add2 := 0;
--                   write(line_out, string'("0"));
--                 end if;
--                 sum2_var(i) := sum2_var(i) + bit_add2;
--               end loop;
--               sum2(i) <= sum2_var(i);

--               write(line_out, string'(" sum2("));
--               write(line_out, i);
--               write(line_out, string'(") = "));
--               write(line_out, sum2_var(i));
--               -- writeline(output, line_out);
--             end loop;
--             -- writeline(output, line_out);

--             for i in 0 to N/256-1 loop
--               sum3_var(i) := 0;
--               for j in 0 to 3 loop
--                 bit_add3 := sum2(i*4 + j);
--                 sum3_var(i) := sum3_var(i) + bit_add3;
--               end loop;
--               sum3(i) <= sum3_var(i);

--               write(line_out, string'("sum3("));
--               write(line_out, i);
--               write(line_out, string'(") = "));
--               write(line_out, sum3_var(i));
--               -- writeline(output, line_out);
--             end loop;
--             -- writeline(output, line_out);



            for i in 0 to N/16-1 loop
              sum2_var(i) := 0;
              write(line_out, string'(" "));
              for j in 0 to 15 loop
                if input_input(i*16 + j) = input_weights(i*16 + j) then
                  bit_add2 := 1;
                  write(line_out, string'("1"));
                else
                  bit_add2 := 0;
                  write(line_out, string'("0"));
                end if;
                sum2_var(i) := sum2_var(i) + bit_add2;
              end loop;
              sum2(i) <= sum2_var(i);

              write(line_out, string'(" sum2("));
              write(line_out, i);
              write(line_out, string'(") = "));
              write(line_out, sum2_var(i));
              -- writeline(output, line_out);
            end loop;
            -- writeline(output, line_out);

            for i in 0 to N/256-1 loop
              sum3_var(i) := 0;
              for j in 0 to 15 loop
                bit_add3 := sum2(i*16 + j);
                sum3_var(i) := sum3_var(i) + bit_add3;
              end loop;
              sum3(i) <= sum3_var(i);

              write(line_out, string'("sum3("));
              write(line_out, i);
              write(line_out, string'(") = "));
              write(line_out, sum3_var(i));
              -- writeline(output, line_out);
            end loop;
            -- writeline(output, line_out);


            end_sum := 0;
            for j in 0 to 2 loop
              end_sum := end_sum + sum3(j);
            end loop;

            write(line_out, string'("end_sum = "));
            write(line_out, end_sum);
            -- writeline(output, line_out);
            -- writeline(output, line_out);

            -- popcount_sum <= end_sum;

            if end_sum >= 384 then
              is_sum_high <= '1';
            else
              is_sum_high <= '0';
            end if;


            --- try tree
            -- for i in 0 to N/3-1 loop
            --   sum1_var(i) := 0;
            --   for j in 0 to 2 loop
            --     if top_array(i*3 + j) = '1' then
            --       bit_add1 := 1;
            --     else
            --       bit_add1 := 0;
            --     end if;
            --     sum1_var(i) := sum1_var(i) + bit_add1;
            --   end loop;
            --   sum1(i) <= sum1_var(i);
            -- end loop;

            -- for i in 0 to N/6-1 loop
            --   sum2_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add2 := sum1(i*2 + j);
            --     sum2_var(i) := sum2_var(i) + bit_add2;
            --   end loop;
            --   sum2(i) <= sum2_var(i);
            -- end loop;

            -- for i in 0 to N/12-1 loop
            --   sum3_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add3 := sum2(i*2 + j);
            --     sum3_var(i) := sum3_var(i) + bit_add3;
            --   end loop;
            --   sum3(i) <= sum3_var(i);
            -- end loop;
            
            -- for i in 0 to N/24-1 loop
            --   sum4_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add4 := sum3(i*2 + j);
            --     sum4_var(i) := sum4_var(i) + bit_add4;
            --   end loop;
            --   sum4(i) <= sum4_var(i);
            -- end loop;

            -- for i in 0 to N/48-1 loop
            --   sum5_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add5 := sum4(i*2 + j);
            --     sum5_var(i) := sum5_var(i) + bit_add5;
            --   end loop;
            --   sum5(i) <= sum5_var(i);
            -- end loop;

            -- for i in 0 to N/96-1 loop
            --   sum6_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add6 := sum5(i*2 + j);
            --     sum6_var(i) := sum6_var(i) + bit_add6;
            --   end loop;
            --   sum6(i) <= sum6_var(i);
            -- end loop;

            -- for i in 0 to N/192-1 loop
            --   sum7_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add7 := sum6(i*2 + j);
            --     sum7_var(i) := sum7_var(i) + bit_add7;
            --   end loop;
            --   sum7(i) <= sum7_var(i);
            -- end loop;

            -- for i in 0 to N/384-1 loop
            --   sum8_var(i) := 0;
            --   for j in 0 to 1 loop
            --     bit_add8 := sum7(i*2 + j);
            --     sum8_var(i) := sum8_var(i) + bit_add8;
            --   end loop;
            --   sum8(i) <= sum8_var(i);
            -- end loop;


            -- popcount_sum_internal <= sum8(0) + sum8(1);





            if will_be_valid = levels then
              is_valid <= '1';
            else
              will_be_valid := will_be_valid + 1;
            end if;
        end if;
      end if;
    end process;








end Behavioral;

