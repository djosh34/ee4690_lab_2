library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;
use work.predict_package.all;


entity xnor_popcount is
    generic (
        N : integer := 768
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        is_valid : out std_logic;

        input_input : in std_logic_vector(N-1 downto 0);
        input_weights : in std_logic_vector(N-1 downto 0);

        is_sum_high : out std_logic;
        
        


        -- Debugging signals
        popcount_sum : out unsigned(clog2(N)-1 downto 0)
    );

end xnor_popcount;

architecture Behavioral of xnor_popcount is
begin

    process(clk)
      variable will_start : integer := 0;
    begin
        if rising_edge(clk) and  rst = '1' then
          is_valid <= '0';
          is_sum_high <= '0';
          popcount_sum <= to_unsigned(0, popcount_sum'length);
          will_start := 0;
        elsif rising_edge(clk) and enable = '1' then
          will_start := will_start + 1;
          
          if will_start > 4 then
            is_valid <= '1';
            popcount_sum <= popcount_sum + to_unsigned(1, popcount_sum'length);
          end if;



        end if;
    end process;

end Behavioral;

