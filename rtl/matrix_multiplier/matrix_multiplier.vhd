library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;



entity matrix_multiplier is
    generic (
        N_INPUT : integer := 8;  -- Width of the input vectors and registers matrix_a and matrix_b
        N_OUTPUT : integer := 20; -- Width of the accumulator and registers matrix_c
        N_MATRIX_SIZE: integer := 8; -- Size of the square matrix
        -- N_ADDRESS_WIDTH: integer := integer(ceil(log2(real(N_MATRIX_SIZE*N_MATRIX_SIZE))))
        N_ADDRESS_WIDTH: integer := 6
    );
    port (
        CLK : in std_logic;
        rst : in std_logic;
        data_in : in std_logic_vector(N_INPUT-1 downto 0);
        data_out : out std_logic_vector(N_OUTPUT-1 downto 0);
        address_ab : in std_logic_vector(N_ADDRESS_WIDTH + 1 -1 downto 0);
        address_c : out std_logic_vector(N_ADDRESS_WIDTH -1 downto 0);
        start : in std_logic;
        read_input : in std_logic; -- Read from matrix_a or matrix_b
        write_input : in std_logic; -- Write to matrix_a or matrix_b
        read_output : in std_logic; -- Read from matrix_c

        --- start debugging
        matrix_state : out std_logic_vector(3 downto 0);
        i : out unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
        j : out unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
        k : out unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
        A_value : out unsigned(N_OUTPUT/2 - 1 downto 0);
        B_value : out unsigned(N_OUTPUT/2 - 1 downto 0);
        Temp : out unsigned(N_OUTPUT - 1 downto 0);
        multiplication : out unsigned(N_OUTPUT - 1 downto 0);
        ---

        done : out std_logic
    );
end matrix_multiplier;


architecture Behavioral of matrix_multiplier is
    signal matrix_select : std_logic;  -- '0' for matrix_a, '1' for matrix_b

    signal internal_data_in : std_logic_vector(N_INPUT-1 downto 0);
    signal internal_data_out : std_logic_vector(N_OUTPUT-1 downto 0);

    type matrix_type is array (0 to N_MATRIX_SIZE * N_MATRIX_SIZE -1) of std_logic_vector(N_INPUT-1 downto 0);
    type matrix_type_c is array (0 to N_MATRIX_SIZE * N_MATRIX_SIZE -1) of std_logic_vector(N_OUTPUT-1 downto 0);

    signal matrix_a : matrix_type;
    signal matrix_b : matrix_type;
    signal matrix_c : matrix_type_c;

    -- constant U_N_MATRIX_SIZE : unsigned := to_unsigned(N_ADDRESS_WIDTH/2);



    type MATRIX_STATEMACHINE is (
        IDLE,
        OUTER_LOOP,
        MIDDLE_LOOP,
        INNER_LOOP_READING,
        INNER_LOOP_MULTIPLICATION,
        INNER_LOOP_ADDING,
        INNER_LOOP_END,
        MIDDLE_LOOP_END,
        OUTER_LOOP_END,
        FINISHING
    );

    signal matrix_state_inner: MATRIX_STATEMACHINE;

    function State_To_Bits(state : MATRIX_STATEMACHINE) return std_logic_vector is
    begin
        case state is
            when IDLE     => return "0000";
            when OUTER_LOOP => return "0001";
            when MIDDLE_LOOP => return "0010";
            when INNER_LOOP_READING => return "0011";
            when INNER_LOOP_MULTIPLICATION => return "0100";
            when INNER_LOOP_ADDING => return "0101";
            when INNER_LOOP_END => return "0110";
            when MIDDLE_LOOP_END => return "0111";
            when OUTER_LOOP_END => return "1000";
            when FINISHING => return "1001";
            when others => return "1111";
        end case;
    end function;


    
    signal matrix_multiplying : std_logic;
    -- signal i : unsigned(N_ADDRESS_WIDTH/2 downto 0);
    -- signal j : unsigned(N_ADDRESS_WIDTH/2 downto 0);
    -- signal k : unsigned(N_ADDRESS_WIDTH/2 - 1 downto 0);

    -- signal A_value : unsigned(N_OUTPUT/2 - 1 downto 0);
    -- signal B_value : unsigned(N_OUTPUT/2 - 1 downto 0);
    -- signal Temp : unsigned(N_OUTPUT - 1 downto 0);
    -- signal multiplication : unsigned(N_OUTPUT - 1 downto 0);







begin


  process(CLK)
  begin
      if rising_edge(CLK) then
          if rst = '1' then
              internal_data_in <= (others => '0');
              internal_data_out <= (others => '0');

              matrix_a <= (others => (others => '0'));
              matrix_b <= (others => (others => '0'));
              matrix_c <= (others => (others => '0'));

              matrix_state_inner <= IDLE;
              matrix_multiplying <= '0';

              i <= (others => '0');
              j <= (others => '0');
              k <= (others => '0');

              A_value <= (others => '0');
              B_value <= (others => '0');

              Temp <= (others => '0');
              multiplication <= (others => '0');

              done <= '1';
          else
              if start = '1' then
                  done <= '0';
                  matrix_multiplying <= '1';
              end if;

              if matrix_multiplying = '0' then
                matrix_state_inner <= IDLE;
                -- Handle matrix A or B
                if write_input = '1' and read_input = '0' and read_output = '0' then
                    if address_ab(address_ab'high) = '0' then
                        matrix_a(to_integer(unsigned(address_ab(N_ADDRESS_WIDTH - 1 downto 0)))) <= data_in;
                    else
                        matrix_b(to_integer(unsigned(address_ab(N_ADDRESS_WIDTH - 1 downto 0)))) <= data_in;
                    end if;
                -- Handle reads from matrices A and B
                elsif read_input = '1' and write_input = '0' and read_output = '0' then
                    if address_ab(address_ab'high) = '0' then
                        data_out <= (others => '0');
                        data_out(N_INPUT-1 downto 0) <= matrix_a(to_integer(unsigned(address_ab(N_ADDRESS_WIDTH -1 downto 0))));
                    else
                        data_out <= (others => '0');
                        data_out(N_INPUT-1 downto 0) <= matrix_b(to_integer(unsigned(address_ab(N_ADDRESS_WIDTH -1 downto 0))));
                    end if;
                -- Handle matrix C
                elsif read_output = '1' and write_input = '0' and read_input = '0' then
                    data_out <= matrix_c(to_integer(unsigned(address_c)));
                end if;


              -- Handle matrix multiplication
              else
                if done = '0' then
                  case matrix_state_inner is
                      when IDLE =>
                          i <= (others => '0');
                          matrix_state_inner <= OUTER_LOOP;

                      when OUTER_LOOP =>
                          j <= (others => '0');
                          matrix_state_inner <= MIDDLE_LOOP;

                      when MIDDLE_LOOP =>
                          Temp <= (others => '0');
                          k <= (others => '0');
                          matrix_state_inner <= INNER_LOOP_READING;

                      when INNER_LOOP_READING =>
                          A_value <= resize(unsigned(matrix_a(to_integer(i & k))), N_OUTPUT/2);
                          B_value <= resize(unsigned(matrix_b(to_integer(k & j))), N_OUTPUT/2);
                          matrix_state_inner <= INNER_LOOP_MULTIPLICATION;

                      when INNER_LOOP_MULTIPLICATION =>
                          multiplication <= A_value * B_value;
                          matrix_state_inner <= INNER_LOOP_ADDING;

                      when INNER_LOOP_ADDING =>
                          Temp <= Temp + multiplication;
                          matrix_state_inner <= INNER_LOOP_END;

                      when INNER_LOOP_END =>
                          if k = N_MATRIX_SIZE - 1 then 
                              k <= (others => '0');
                              matrix_state_inner <= MIDDLE_LOOP_END;
                          else
                              k <= k + 1;
                              matrix_state_inner <= INNER_LOOP_READING;
                          end if;

                      when MIDDLE_LOOP_END =>
                          matrix_c(to_integer(unsigned(i(N_ADDRESS_WIDTH/2 - 1 downto 0) & j(N_ADDRESS_WIDTH/2 - 1 downto 0)))) <= std_logic_vector(Temp);
                          if j = N_MATRIX_SIZE - 1 then -- update takes a cycle
                              j <= (others => '0');
                              matrix_state_inner <= OUTER_LOOP_END;
                          else
                              j <= j + 1;
                              matrix_state_inner <= MIDDLE_LOOP;
                          end if;
                          
                      when OUTER_LOOP_END =>
                          if i = N_MATRIX_SIZE - 1 then -- update takes a cycle
                              i <= (others => '0');
                              matrix_state_inner <= FINISHING;
                          else
                              i <= i + 1;
                              matrix_state_inner <= OUTER_LOOP;
                          end if;

                      when FINISHING =>
                          matrix_state_inner <= IDLE;
                          done <= '1';

                      when others =>
                          matrix_state_inner <= IDLE;

                  end case;
                else
                  matrix_state_inner <= IDLE;
                  matrix_multiplying <= '0';
                end if;

                matrix_state <= State_To_Bits(matrix_state_inner);
              end if;
          end if;
      end if;
  end process;


-- IDLE
-- 	int i = 0;
-- 	GOTO OUTER_LOOP

-- OUTER_LOOP
-- 	int j = 0
-- 	GOTO MIDDLE_LOOP

-- MIDDLE_LOOP
-- 	Temp = 0
-- 	int k = 0;
-- 	GOTO INNER_LOOP_MULTIPLICATION

-- INNER_LOOP_MULTIPLICATION
-- 	address_a = i bits concat k bits
-- 	address_b = k bits concat j bits
-- 	A_value = A(address_a) <- convert here to N_OUTPUT bits
-- 	B_value = B(address_b) <- convert here to N_OUTPUT bits
-- 	Multiplication = A_value * B_value
-- 	GOTO INNER_LOOP_ADDING
	
-- INNER_LOOP_ADDING
-- 	Temp = Temp + Multiplication
-- 	k = k + 1 (wrapping add so 8 (for 3 bits) == 0)
-- 	if (k /= 0) GOTO INNER_LOOP_MULTIPLICATION
-- 	GOTO MIDDLE_LOOP_END

-- MIDDLE_LOOP_END
-- 	address_c = i bits concat j bits
-- 	C[i][j] = Temp;
-- 	j = j + 1 (wrapping add so 8 == 0)
-- 	if (j /= 0) GOTO MIDDLE_LOOP
-- 	GOTO OUTER_LOOP_END

-- OUTER_LOOP_END
-- 	i = i + 1 (wrapping add so 8 == 0)
-- 	if (i /= 0) GOTO OUTER_LOOP
-- 	GOTO FINISHING

-- FINISHING
-- 	done <= 1
-- 	GOTO IDLE



end Behavioral;
