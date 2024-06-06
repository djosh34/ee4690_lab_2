library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_misc.ALL;

use std.textio.all;

use IEEE.math_real.all;
use work.predict_package.all;

entity lfsr_10 is
    port (
        CLK : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        
        lfsr_output : out std_logic_vector(10 downto 0)
    );
end lfsr_10;


architecture Behavioral of lfsr_10 is
    signal lfsr_output_var : std_logic_vector(10 downto 0);
begin

  lfsr_output <= lfsr_output_var;

  process (clk)
    variable feedback : std_logic;
  begin
      if rising_edge(clk) then
        if rst = '1' then
          lfsr_output_var <= "00000000001";
        else 
          if enable = '1' then
            feedback := lfsr_output_var(10) xor lfsr_output_var(6);
            lfsr_output_var(0) <= feedback;
            lfsr_output_var(1) <= lfsr_output_var(0);
            lfsr_output_var(2) <= lfsr_output_var(1);
            lfsr_output_var(3) <= lfsr_output_var(2);
            lfsr_output_var(4) <= lfsr_output_var(3);
            lfsr_output_var(5) <= lfsr_output_var(4);
            lfsr_output_var(6) <= lfsr_output_var(5);
            lfsr_output_var(7) <= lfsr_output_var(6);
            lfsr_output_var(8) <= lfsr_output_var(7);
            lfsr_output_var(9) <= lfsr_output_var(8);
            lfsr_output_var(10) <= lfsr_output_var(9);
          end if;

        end if;
      end if;
  end process;

end Behavioral;
