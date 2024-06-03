library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

library work;
use work.apc_package.all;



entity apc is
    generic (
        -- BIT_WIDTH : integer := 64;
        INPUT_SIZE : integer := 768
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        total_reset : in std_logic;


        parallel_input_counter : in std_logic_vector(15 downto 0);

        -- debugging signals
        total : out natural;
        -- end debugging signals


        done : out std_logic
    );

end apc;

architecture Behavioral of apc is
    -- signal LS_00 : unsigned(0 downto 0);
    -- signal LS_01 : unsigned(0 downto 0);
    -- signal LS_02 : unsigned(0 downto 0);
    -- signal LS_03 : unsigned(0 downto 0);
    -- signal LS_04 : unsigned(0 downto 0);
    -- signal LS_05 : unsigned(0 downto 0);
    -- signal LS_06 : unsigned(0 downto 0);
    -- signal LS_07 : unsigned(0 downto 0);
    -- signal LS_08 : unsigned(0 downto 0);
    -- signal LS_09 : unsigned(0 downto 0);
    -- signal LS_10 : unsigned(0 downto 0);
    -- signal LS_11 : unsigned(0 downto 0);
    -- signal LS_12 : unsigned(0 downto 0);
    -- signal LS_13 : unsigned(0 downto 0);
    -- signal LS_14 : unsigned(0 downto 0);
    -- signal LS_15 : unsigned(0 downto 0);

    -- signal LS_00 : natural;
    -- signal LS_01 : natural;
    -- signal LS_02 : natural;
    -- signal LS_03 : natural;
    -- signal LS_04 : natural;
    -- signal LS_05 : natural;
    -- signal LS_06 : natural;
    -- signal LS_07 : natural;
    -- signal LS_08 : natural;
    -- signal LS_09 : natural;
    -- signal LS_10 : natural;
    -- signal LS_11 : natural;
    -- signal LS_12 : natural;
    -- signal LS_13 : natural;
    -- signal LS_14 : natural;
    -- signal LS_15 : natural;

    type parallel_input_latch_array is array(0 to 15) of natural;
    signal parallel_input_latch : parallel_input_latch_array;

    -- signal L_0_00 : unsigned(0 downto 0);
    -- signal L_0_01 : unsigned(0 downto 0);
    -- signal L_0_02 : unsigned(0 downto 0);
    -- signal L_0_03 : unsigned(0 downto 0);

    -- signal L_1_00 : unsigned(0 downto 0);
    -- signal L_1_01 : unsigned(0 downto 0);
    -- signal L_1_02 : unsigned(0 downto 0);
    -- signal L_1_03 : unsigned(0 downto 0);
    -- signal L_1_04 : unsigned(0 downto 0);
    -- signal L_1_05 : unsigned(0 downto 0);
    -- signal L_1_06 : unsigned(0 downto 0);
    -- signal L_1_07 : unsigned(0 downto 0);
    -- signal L_1_08 : unsigned(0 downto 0);
    -- signal L_1_09 : unsigned(0 downto 0);
    -- signal L_1_10 : unsigned(0 downto 0);
    -- signal L_1_11 : unsigned(0 downto 0);

    -- signal L_2_00 : unsigned(0 downto 0);
    -- signal L_2_01 : unsigned(0 downto 0);
    -- signal L_2_02 : unsigned(0 downto 0);
    -- signal L_2_03 : unsigned(0 downto 0);

    -- signal L_3_00 : unsigned(0 downto 0);
    -- signal L_3_01 : unsigned(0 downto 0);
    -- signal L_3_02 : unsigned(0 downto 0);
    -- signal L_3_03 : unsigned(0 downto 0);
    -- signal L_3_04 : unsigned(0 downto 0);
    -- signal L_3_05 : unsigned(0 downto 0);
    -- signal L_3_06 : unsigned(0 downto 0);
    -- signal L_3_07 : unsigned(0 downto 0);

    -- signal L_4_00 : unsigned(0 downto 0);
    -- signal L_4_01 : unsigned(0 downto 0);



    -- -- LATCHING FOR RIPPLING CARRY
    -- signal L_5_00 : unsigned(0 downto 0);
    -- signal L_5_01 : unsigned(0 downto 0);

    -- signal L_6_00 : unsigned(0 downto 0);
    -- signal L_6_01 : unsigned(0 downto 0);
    -- signal L_6_02 : unsigned(0 downto 0);

    -- signal L_7_00 : unsigned(0 downto 0);
    -- signal L_7_01 : unsigned(0 downto 0);
    -- signal L_7_02 : unsigned(0 downto 0);
    -- signal L_7_03 : unsigned(0 downto 0);
    -- signal L_7_04 : unsigned(0 downto 0);

    -- -- BETWEEN FULL ADDERS

    -- signal L_8_00 : unsigned(0 downto 0);
    -- signal L_8_01 : unsigned(0 downto 0);
    -- signal L_8_02 : unsigned(0 downto 0);
    -- signal L_8_03 : unsigned(0 downto 0);
    -- signal L_8_04 : unsigned(0 downto 0);

    -- -- LATCH OUTPUT OF RIPPILING ADDER

    -- signal L_9_00 : unsigned(0 downto 0);
    -- signal L_9_01 : unsigned(0 downto 0);
    -- signal L_9_02 : unsigned(0 downto 0);
    -- signal L_9_03 : unsigned(0 downto 0);
    -- signal L_9_04 : unsigned(0 downto 0);
    -- signal L_9_05 : unsigned(0 downto 0);




    -- type temp_level_0 is array(0 to 7) of unsigned(1 downto 0);
    -- type temp_level_1 is array(0 to 3) of unsigned(2 downto 0);
    -- type temp_level_2 is array(0 to 1) of unsigned(3 downto 0);
    type temp_level_0 is array(0 to 7) of natural;
    type temp_level_1 is array(0 to 3) of natural;
    type temp_level_2 is array(0 to 1) of natural;

    signal level_0 : temp_level_0;
    signal level_1 : temp_level_1;
    signal level_2 : temp_level_2;

    type total_rst_type is array(0 to 2) of std_logic;
    signal total_rst : total_rst_type;





begin



    process(clk)
      -- variable temp_0 : unsigned(1 downto 0);
      -- variable temp_1 : unsigned(1 downto 0);
      -- variable temp_2 : unsigned(1 downto 0);
      -- variable temp_3 : unsigned(1 downto 0);
      -- variable temp_4 : unsigned(1 downto 0);
      -- variable temp_5 : unsigned(1 downto 0);

      -- variable level_0_temp_0 : unsigned(3 downto 0);
      -- variable level_0_temp_1 : unsigned(3 downto 0);

      -- reduce 16 to 8 temps then 8 to 4 then 4 to 2 then 2 to 1

      variable temp_total : natural;





    begin
        if rising_edge(clk) then
            if rst = '1' then
              -- all latch signals to 0
              -- L_0_00 <= (others => '0');
              -- L_0_01 <= (others => '0');
              -- L_0_02 <= (others => '0');
              -- L_0_03 <= (others => '0');
              -- L_1_00 <= (others => '0');
              -- L_1_01 <= (others => '0');
              -- L_1_02 <= (others => '0');
              -- L_1_03 <= (others => '0');
              -- L_1_04 <= (others => '0');
              -- L_1_05 <= (others => '0');
              -- L_1_06 <= (others => '0');
              -- L_1_07 <= (others => '0');
              -- L_1_08 <= (others => '0');
              -- L_1_09 <= (others => '0');
              -- L_1_10 <= (others => '0');
              -- L_1_11 <= (others => '0');
              -- L_2_00 <= (others => '0');
              -- L_2_01 <= (others => '0');
              -- L_2_02 <= (others => '0');
              -- L_2_03 <= (others => '0');
              -- L_3_00 <= (others => '0');
              -- L_3_01 <= (others => '0');
              -- L_3_02 <= (others => '0');
              -- L_3_03 <= (others => '0');
              -- L_3_04 <= (others => '0');
              -- L_3_05 <= (others => '0');
              -- L_3_06 <= (others => '0');
              -- L_3_07 <= (others => '0');
              -- L_4_00 <= (others => '0');
              -- L_4_01 <= (others => '0');
              -- L_5_00 <= (others => '0');
              -- L_5_01 <= (others => '0');
              -- L_6_00 <= (others => '0');
              -- L_6_01 <= (others => '0');
              -- L_6_02 <= (others => '0');
              -- L_7_00 <= (others => '0');
              -- L_7_01 <= (others => '0');
              -- L_7_02 <= (others => '0');
              -- L_7_03 <= (others => '0');
              -- L_7_04 <= (others => '0');
              -- L_8_00 <= (others => '0');
              -- L_8_01 <= (others => '0');
              -- L_8_02 <= (others => '0');
              -- L_8_03 <= (others => '0');
              -- L_8_04 <= (others => '0');
              -- L_9_00 <= (others => '0');
              -- L_9_01 <= (others => '0');
              -- L_9_02 <= (others => '0');
              -- L_9_03 <= (others => '0');
              -- L_9_04 <= (others => '0');
              -- L_9_05 <= (others => '0');

--               LS_00 <= (others => '0');
--               LS_01 <= (others => '0');
--               LS_02 <= (others => '0');
--               LS_03 <= (others => '0');
--               LS_04 <= (others => '0');
--               LS_05 <= (others => '0');
--               LS_06 <= (others => '0');
--               LS_07 <= (others => '0');
--               LS_08 <= (others => '0');
--               LS_09 <= (others => '0');
--               LS_10 <= (others => '0');
--               LS_11 <= (others => '0');
--               LS_12 <= (others => '0');
--               LS_13 <= (others => '0');
--               LS_14 <= (others => '0');
--               LS_15 <= (others => '0');

--               LS_00 <= 0;
--               LS_01 <= 0;
--               LS_02 <= 0;
--               LS_03 <= 0;
--               LS_04 <= 0;
--               LS_05 <= 0;
--               LS_06 <= 0;
--               LS_07 <= 0;
--               LS_08 <= 0;
--               LS_09 <= 0;
--               LS_10 <= 0;
--               LS_11 <= 0;
--               LS_12 <= 0;
--               LS_13 <= 0;
--               LS_14 <= 0;
--               LS_15 <= 0;
              parallel_input_latch <= (others => 0);

              done <= '0';

              -- level_0 <= (others => (others => '0'));
              -- level_1 <= (others => (others => '0'));
              -- level_2 <= (others => (others => '0'));
              level_0 <= (others => 0);
              level_1 <= (others => 0);
              level_2 <= (others => 0);

              total_rst <= (others => '0');

              total <= 0;
              done <= '0';
            elsif rst = '0' then
              for i in 0 to 15 loop 
                parallel_input_latch(i) <= to_integer(unsigned(parallel_input_counter(i downto i)));
              end loop;





              -- --- L0 -> L1
              -- --- block from x15 to x9
              -- -- full adder x15, x14, x13 -> cout to L_0_03, sum to L_1_09
              -- temp_0 := ('0' & LS_15) + ('0' & LS_14) + ('0' & LS_13);
              -- L_0_03 <= temp_0(1 downto 1);
              -- L_1_09 <= temp_0(0 downto 0);
 
              -- -- full adder x12, x11, x10 -> cout to L_0_02, sum to L_1_08
              -- temp_1 := ('0' & LS_12) + ('0' & LS_11) + ('0' & LS_10);
              -- L_0_02 <= temp_1(1 downto 1);
              -- L_1_08 <= temp_1(0 downto 0);

              -- -- propagate latch L0 to L1
              -- L_1_11 <= L_0_03;
              -- L_1_10 <= L_0_02;

              -- -- x9 -> L_1_07
              -- L_1_07 <= LS_09;

              -- -- same block from x8 to x2 on same level
              -- -- full adder x8, x7, x6 -> cout to L_0_01, sum to L_1_04
              -- temp_2 := ('0' & LS_08) + ('0' & LS_07) + ('0' & LS_06);
              -- L_0_01 <= temp_2(1 downto 1);
              -- L_1_04 <= temp_2(0 downto 0);

              -- -- full adder x5, x4, x3 -> cout to L_0_00, sum to L_1_03
              -- temp_3 := ('0' & LS_05) + ('0' & LS_04) + ('0' & LS_03);
              -- L_0_00 <= temp_3(1 downto 1);
              -- L_1_03 <= temp_3(0 downto 0);

              -- -- propagate latch L0 to L1
              -- L_1_06 <= L_0_01;
              -- L_1_05 <= L_0_00;

              -- -- x2, x1, x0 propagate to L1
              -- L_1_02 <= LS_02;
              -- L_1_01 <= LS_01;
              -- L_1_00 <= LS_00;


              --- L1 -> L2
              -- (L_1_11, L_1_10, L_2_02) -> cout to L_2_03, sum to L_3_05
              -- (L_1_09, L_1_08, L_1_07) -> cout to L_2_02, sum to L_3_03
              -- (L_1_06, L_1_05, L_2_00) -> cout to L_2_01, sum to L_3_01

              -- level_0_temp_0 <= ("00" & LS_07) + ("00" & LS_06) + ("00" & LS_05) + ("00" & LS_04) + ("00" & LS_03) + ("00" & LS_02) + ("00" & LS_01) + ("00" & LS_00);
              -- level_0_temp_1 := ("00" & LS_15) + ("00" & LS_14) + ("00" & LS_13) + ("00" & LS_12) + ("00" & LS_11) + ("00" & LS_10) + ("00" & LS_09) + ("00" & LS_08);



              -- level_0_temp_0 := ("000" & LS_07) +
              --                   ("000" & LS_06) + 
              --                   ("000" & LS_05) + 
              --                   ("000" & LS_04) + 
              --                   ("000" & LS_03) + 
              --                   ("000" & LS_02) + 
              --                   ("000" & LS_01) + 
              --                   ("000" & LS_00);

              -- level_0_temp_1 := ("000" & LS_15) + 
              --                   ("000" & LS_14) + 
              --                   ("000" & LS_13) + 
              --                   ("000" & LS_12) + 
              --                   ("000" & LS_11) + 
              --                   ("000" & LS_10) + 
              --                   ("000" & LS_09) + 
              --                   ("000" & LS_08);

              -- total <= ("0000" & "00" & level_0_temp_1) + ("0000" & "00" & level_0_temp_0) + total;


              total_rst(0) <= total_reset;
              total_rst(1) <= total_rst(0);
              total_rst(2) <= total_rst(1);



              -- level_0(7) <= ("0" & LS_15) + ("0" & LS_14);
              -- level_0(6) <= ("0" & LS_13) + ("0" & LS_12);
              -- level_0(5) <= ("0" & LS_11) + ("0" & LS_10);
              -- level_0(4) <= ("0" & LS_09) + ("0" & LS_08);
              -- level_0(3) <= ("0" & LS_07) + ("0" & LS_06);
              -- level_0(2) <= ("0" & LS_05) + ("0" & LS_04);
              -- level_0(1) <= ("0" & LS_03) + ("0" & LS_02);
              -- level_0(0) <= ("0" & LS_01) + ("0" & LS_00);

              -- level_1(3) <= ("0" & level_0(7)) + ("0" & level_0(6));
              -- level_1(2) <= ("0" & level_0(5)) + ("0" & level_0(4));
              -- level_1(1) <= ("0" & level_0(3)) + ("0" & level_0(2));
              -- level_1(0) <= ("0" & level_0(1)) + ("0" & level_0(0));

              -- level_2(1) <= ("0" & level_1(3)) + ("0" & level_1(2));
              -- level_2(0) <= ("0" & level_1(1)) + ("0" & level_1(0));

              -- total <= ("0" & level_2(1)) + ("0" & level_2(0)) + ((not total_rst(2)) * total);

              -- level_0(7) <= LS_15 + LS_14;
              -- level_0(6) <= LS_13 + LS_12;
              -- level_0(5) <= LS_11 + LS_10;
              -- level_0(4) <= LS_09 + LS_08;
              -- level_0(3) <= LS_07 + LS_06;
              -- level_0(2) <= LS_05 + LS_04;
              -- level_0(1) <= LS_03 + LS_02;
              -- level_0(0) <= LS_01 + LS_00;

              -- level_1(3) <= level_0(7) + level_0(6);
              -- level_1(2) <= level_0(5) + level_0(4);
              -- level_1(1) <= level_0(3) + level_0(2);
              -- level_1(0) <= level_0(1) + level_0(0);

              -- level_2(1) <= level_1(3) + level_1(2);
              -- level_2(0) <= level_1(1) + level_1(0);

              -- if total_rst(2) = '0' then
              --   total <= level_2(1) + level_2(0) + total;
              -- else
              --   total <= level_2(1) + level_2(0);
              -- end if;

              temp_total := parallel_input_latch(15) + parallel_input_latch(14) + parallel_input_latch(13) + parallel_input_latch(12) + 
                       parallel_input_latch(11) + parallel_input_latch(10) + parallel_input_latch(09) + parallel_input_latch(08) + 
                       parallel_input_latch(07) + parallel_input_latch(06) + parallel_input_latch(05) + parallel_input_latch(04) + 
                       parallel_input_latch(03) + parallel_input_latch(02) + parallel_input_latch(01) + parallel_input_latch(00);

              if total_rst(2) = '0' then
                total <= total + temp_total;
              else
                total <= temp_total;
              end if;


















            end if;



        end if;
    end process;

end Behavioral;

