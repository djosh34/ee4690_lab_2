library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;


entity xnor_popcount is
    generic (
        N : integer := 64  -- Width of the input vectors
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        done : out std_logic;
        weights_vector : in std_logic_vector(N-1 downto 0);
        input_vector : in std_logic_vector(N-1 downto 0);
        popcount : out unsigned(integer(ceil(log2(real(N))))-1 downto 0);
        
        -- Debugging signals
        xnor_result : out std_logic_vector(N-1 downto 0);
        step : out unsigned(integer(ceil(log2(real(N)))) downto 0)
    );
end xnor_popcount;

architecture Behavioral of xnor_popcount is
    type state_type is (XNOR_IDLE, XNOR_CALCULATING, XNOR_DONE);

    signal state : state_type := XNOR_IDLE;
    signal internal_xnor_result : std_logic_vector(N-1 downto 0);
    signal internal_count : unsigned(integer(ceil(log2(real(N))))-1 downto 0);
begin
    -- xnor_result <= weights_vector xnor input_vector;
    xnor_result <= internal_xnor_result;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                internal_xnor_result <= (others => '0');
                internal_count <= (others => '0');
                done <= '0';
                step <= (others => '0');

            elsif start = '1' or state /= XNOR_IDLE then
                case state is
                    when XNOR_IDLE =>
                        state <= XNOR_CALCULATING;
                        done <= '0';
                        step <= (others => '0');
                        internal_xnor_result <= weights_vector xnor input_vector;
                        internal_count <= (others => '0');

                    when XNOR_CALCULATING =>
                        if step = N then
                            state <= XNOR_DONE;
                            internal_xnor_result <= weights_vector xnor input_vector;
                            done <= '1';
                        else
                            step <= step + 1;
                            if internal_xnor_result(N-1) = '1' then
                                internal_count <= internal_count + 1;
                            end if;
                            -- just a shift to the right
                            internal_xnor_result <= internal_xnor_result(N-2 downto 0) & '0';
                        end if;

                    when XNOR_DONE =>
                        state <= XNOR_IDLE;
                        done <= '0';
                        step <= (others => '0');
                end case;
                -- internal_xnor_result <= weights_vector xnor input_vector;
                -- internal_count <= (others => '0');
                
                -- for i in 0 to N-1 loop
                --     if internal_xnor_result(i) = '1' then
                --         internal_count <= internal_count + 1;
                --     end if;
                -- end loop;
                
                -- calculation_done <= '1';
            end if;
        end if;
    end process;

    popcount <= internal_count;
end Behavioral;

