library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity full_adder is
    port (
        a : in unsigned(0 downto 0);
        b : in unsigned(0 downto 0);
        c : in unsigned(0 downto 0);

        sum : out unsigned(0 downto 0);
        cout : out unsigned(0 downto 0)
    );
end full_adder;

architecture Behavioral of full_adder is
  signal temp : unsigned(1 downto 0);
begin
  temp <= a + b + c;
  sum <= temp(0 downto 0);
  cout <= temp(1 downto 1);
end Behavioral;


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
        start : in std_logic;


        parallel_input_counter : in std_logic_vector(15 downto 0);

        -- debugging signals
        -- end debugging signals


        done : out std_logic
    );

end apc;

architecture Behavioral of apc is
    signal LS_00 : unsigned(0 downto 0);
    signal LS_01 : unsigned(0 downto 0);
    signal LS_02 : unsigned(0 downto 0);
    signal LS_03 : unsigned(0 downto 0);
    signal LS_04 : unsigned(0 downto 0);
    signal LS_05 : unsigned(0 downto 0);
    signal LS_06 : unsigned(0 downto 0);
    signal LS_07 : unsigned(0 downto 0);
    signal LS_08 : unsigned(0 downto 0);
    signal LS_09 : unsigned(0 downto 0);
    signal LS_10 : unsigned(0 downto 0);
    signal LS_11 : unsigned(0 downto 0);
    signal LS_12 : unsigned(0 downto 0);
    signal LS_13 : unsigned(0 downto 0);
    signal LS_14 : unsigned(0 downto 0);
    signal LS_15 : unsigned(0 downto 0);


    signal L_0_00 : unsigned(0 downto 0);
    signal L_0_01 : unsigned(0 downto 0);
    signal L_0_02 : unsigned(0 downto 0);
    signal L_0_03 : unsigned(0 downto 0);

    signal L_1_00 : unsigned(0 downto 0);
    signal L_1_01 : unsigned(0 downto 0);
    signal L_1_02 : unsigned(0 downto 0);
    signal L_1_03 : unsigned(0 downto 0);
    signal L_1_04 : unsigned(0 downto 0);
    signal L_1_05 : unsigned(0 downto 0);
    signal L_1_06 : unsigned(0 downto 0);
    signal L_1_07 : unsigned(0 downto 0);
    signal L_1_08 : unsigned(0 downto 0);
    signal L_1_09 : unsigned(0 downto 0);
    signal L_1_10 : unsigned(0 downto 0);
    signal L_1_11 : unsigned(0 downto 0);

    signal L_2_00 : unsigned(0 downto 0);
    signal L_2_01 : unsigned(0 downto 0);
    signal L_2_02 : unsigned(0 downto 0);
    signal L_2_03 : unsigned(0 downto 0);

    signal L_3_00 : unsigned(0 downto 0);
    signal L_3_01 : unsigned(0 downto 0);
    signal L_3_02 : unsigned(0 downto 0);
    signal L_3_03 : unsigned(0 downto 0);
    signal L_3_04 : unsigned(0 downto 0);
    signal L_3_05 : unsigned(0 downto 0);
    signal L_3_06 : unsigned(0 downto 0);
    signal L_3_07 : unsigned(0 downto 0);

    signal L_4_00 : unsigned(0 downto 0);
    signal L_4_01 : unsigned(0 downto 0);



    -- LATCHING FOR RIPPLING CARRY
    signal L_5_00 : unsigned(0 downto 0);
    signal L_5_01 : unsigned(0 downto 0);

    signal L_6_00 : unsigned(0 downto 0);
    signal L_6_01 : unsigned(0 downto 0);
    signal L_6_02 : unsigned(0 downto 0);

    signal L_7_00 : unsigned(0 downto 0);
    signal L_7_01 : unsigned(0 downto 0);
    signal L_7_02 : unsigned(0 downto 0);
    signal L_7_03 : unsigned(0 downto 0);
    signal L_7_04 : unsigned(0 downto 0);

    -- BETWEEN FULL ADDERS

    signal L_8_00 : unsigned(0 downto 0);
    signal L_8_01 : unsigned(0 downto 0);
    signal L_8_02 : unsigned(0 downto 0);
    signal L_8_03 : unsigned(0 downto 0);
    signal L_8_04 : unsigned(0 downto 0);

    -- LATCH OUTPUT OF RIPPILING ADDER

    signal L_9_00 : unsigned(0 downto 0);
    signal L_9_01 : unsigned(0 downto 0);
    signal L_9_02 : unsigned(0 downto 0);
    signal L_9_03 : unsigned(0 downto 0);
    signal L_9_04 : unsigned(0 downto 0);
    signal L_9_05 : unsigned(0 downto 0);







begin



    process(clk)
      variable temp_0 : unsigned(1 downto 0);
      variable temp_1 : unsigned(1 downto 0);
      variable temp_2 : unsigned(1 downto 0);
      variable temp_3 : unsigned(1 downto 0);
      variable temp_4 : unsigned(1 downto 0);
      variable temp_5 : unsigned(1 downto 0);



    begin
        if rising_edge(clk) then
            if rst = '1' then
              -- all latch signals to 0
              L_0_00 <= (others => '0');
              L_0_01 <= (others => '0');
              L_0_02 <= (others => '0');
              L_0_03 <= (others => '0');
              L_1_00 <= (others => '0');
              L_1_01 <= (others => '0');
              L_1_02 <= (others => '0');
              L_1_03 <= (others => '0');
              L_1_04 <= (others => '0');
              L_1_05 <= (others => '0');
              L_1_06 <= (others => '0');
              L_1_07 <= (others => '0');
              L_1_08 <= (others => '0');
              L_1_09 <= (others => '0');
              L_1_10 <= (others => '0');
              L_1_11 <= (others => '0');
              L_2_00 <= (others => '0');
              L_2_01 <= (others => '0');
              L_2_02 <= (others => '0');
              L_2_03 <= (others => '0');
              L_3_00 <= (others => '0');
              L_3_01 <= (others => '0');
              L_3_02 <= (others => '0');
              L_3_03 <= (others => '0');
              L_3_04 <= (others => '0');
              L_3_05 <= (others => '0');
              L_3_06 <= (others => '0');
              L_3_07 <= (others => '0');
              L_4_00 <= (others => '0');
              L_4_01 <= (others => '0');
              L_5_00 <= (others => '0');
              L_5_01 <= (others => '0');
              L_6_00 <= (others => '0');
              L_6_01 <= (others => '0');
              L_6_02 <= (others => '0');
              L_7_00 <= (others => '0');
              L_7_01 <= (others => '0');
              L_7_02 <= (others => '0');
              L_7_03 <= (others => '0');
              L_7_04 <= (others => '0');
              L_8_00 <= (others => '0');
              L_8_01 <= (others => '0');
              L_8_02 <= (others => '0');
              L_8_03 <= (others => '0');
              L_8_04 <= (others => '0');
              L_9_00 <= (others => '0');
              L_9_01 <= (others => '0');
              L_9_02 <= (others => '0');
              L_9_03 <= (others => '0');
              L_9_04 <= (others => '0');
              L_9_05 <= (others => '0');
            elsif rst = '0' then
              -- parallel_input_counter -> LS_00, LS_01, LS_02, LS_03, LS_04, LS_05, LS_06, LS_07, LS_08, LS_09, LS_10, LS_11, LS_12, LS_13, LS_14, LS_15
              LS_00 <= unsigned(parallel_input_counter(0 downto 0));
              LS_01 <= unsigned(parallel_input_counter(1 downto 1));
              LS_02 <= unsigned(parallel_input_counter(2 downto 2));
              LS_03 <= unsigned(parallel_input_counter(3 downto 3));
              LS_04 <= unsigned(parallel_input_counter(4 downto 4));
              LS_05 <= unsigned(parallel_input_counter(5 downto 5));
              LS_06 <= unsigned(parallel_input_counter(6 downto 6));
              LS_07 <= unsigned(parallel_input_counter(7 downto 7));
              LS_08 <= unsigned(parallel_input_counter(8 downto 8));
              LS_09 <= unsigned(parallel_input_counter(9 downto 9));
              LS_10 <= unsigned(parallel_input_counter(10 downto 10));
              LS_11 <= unsigned(parallel_input_counter(11 downto 11));
              LS_12 <= unsigned(parallel_input_counter(12 downto 12));
              LS_13 <= unsigned(parallel_input_counter(13 downto 13));
              LS_14 <= unsigned(parallel_input_counter(14 downto 14));
              LS_15 <= unsigned(parallel_input_counter(15 downto 15));


              --- L0 -> L1
              --- block from x15 to x9
              -- full adder x15, x14, x13 -> cout to L_0_03, sum to L_1_09
              temp_0 := ('0' & LS_15) + ('0' & LS_14) + ('0' & LS_13);
              L_0_03 <= temp_0(1 downto 1);
              L_1_09 <= temp_0(0 downto 0);
 
              -- full adder x12, x11, x10 -> cout to L_0_02, sum to L_1_08
              temp_1 := ('0' & LS_12) + ('0' & LS_11) + ('0' & LS_10);
              L_0_02 <= temp_1(1 downto 1);
              L_1_08 <= temp_1(0 downto 0);

              -- propagate latch L0 to L1
              L_1_11 <= L_0_03;
              L_1_10 <= L_0_02;

              -- x9 -> L_1_07
              L_1_07 <= LS_09;

              -- same block from x8 to x2 on same level
              -- full adder x8, x7, x6 -> cout to L_0_01, sum to L_1_04
              temp_2 := ('0' & LS_08) + ('0' & LS_07) + ('0' & LS_06);
              L_0_01 <= temp_2(1 downto 1);
              L_1_04 <= temp_2(0 downto 0);

              -- full adder x5, x4, x3 -> cout to L_0_00, sum to L_1_03
              temp_3 := ('0' & LS_05) + ('0' & LS_04) + ('0' & LS_03);
              L_0_00 <= temp_3(1 downto 1);
              L_1_03 <= temp_3(0 downto 0);

              -- propagate latch L0 to L1
              L_1_06 <= L_0_01;
              L_1_05 <= L_0_00;

              -- x2, x1, x0 propagate to L1
              L_1_02 <= LS_02;
              L_1_01 <= LS_01;
              L_1_00 <= LS_00;


              --- L1 -> L2
              -- (L_1_11, L_1_10, L_2_02) -> cout to L_2_03, sum to L_3_05
              -- (L_1_09, L_1_08, L_1_07) -> cout to L_2_02, sum to L_3_03
              -- (L_1_06, L_1_05, L_2_00) -> cout to L_2_01, sum to L_3_01






            end if;



        end if;
    end process;

end Behavioral;

