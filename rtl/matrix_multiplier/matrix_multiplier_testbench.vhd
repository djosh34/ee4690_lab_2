library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use std.textio.all;

entity matrix_multiplier_testbench is
  port (
    -- Clock
    CLK_out : out std_logic;
    -- Reset
    rst_out : out std_logic;
    -- Start signal
    start_out : out std_logic;
    -- Done signal
    done_out : out std_logic
  );
end entity matrix_multiplier_testbench;

architecture test of matrix_multiplier_testbench is

    constant N_INPUT_BITS : integer := 8;
    constant N_OUTPUT_BITS : integer := 20;
    constant MATRIX_SIZE : integer := 8;
    constant MATRIX_ELEMENTS : integer := MATRIX_SIZE * MATRIX_SIZE;

    -- generate test vectors
    type vector_array is array (0 to (MATRIX_ELEMENTS -1)) of std_logic_vector(N_INPUT_BITS-1 downto 0);
    type vector_out_array is array (0 to (MATRIX_ELEMENTS -1)) of std_logic_vector(N_OUTPUT_BITS-1 downto 0);

    constant matrix_a_values : vector_array := (
      std_logic_vector(to_unsigned(244, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(79,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(122, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(27,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(165, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(11,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(146, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(60,  N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(219, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(114, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(95,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(245, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(49,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(56,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(155, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(124, N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(142, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(192, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(187, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(60,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(125, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(82,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(79,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(244, N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(233, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(74,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(101, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(19,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(163, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(91,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(183, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(212, N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(127, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(94,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(34,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(60,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(2,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(29,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(148, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(246, N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(164, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(244, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(207, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(66,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(62,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(9,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(162, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(169, N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(25,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(187, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(25,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(96,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(43,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(126, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(65,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(51,  N_INPUT_BITS)),
       
      std_logic_vector(to_unsigned(7,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(101, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(208, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(116, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(196, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(156, N_INPUT_BITS)),
      std_logic_vector(to_unsigned(37,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(6,    N_INPUT_BITS))
    );

  constant matrix_b_values : vector_array := (
      std_logic_vector(to_unsigned(13,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(192,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(234,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(12,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(176,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(242,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(214,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(155,  N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(114,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(52,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(80,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(180,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(128,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(248,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(67,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(68,   N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(39,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(196,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(80,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(193,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(66,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(166,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(238,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(44,   N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(152,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(87,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(148,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(28,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(141,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(124,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(251,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(189,  N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(6,    N_INPUT_BITS)),
      std_logic_vector(to_unsigned(200,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(132,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(199,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(251,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(129,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(95,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(58,   N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(252,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(51,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(134,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(112,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(229,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(62,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(167,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(110,  N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(70,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(53,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(108,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(210,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(44,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(84,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(83,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(171,  N_INPUT_BITS)),
                                        
      std_logic_vector(to_unsigned(254,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(159,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(237,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(221,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(100,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(253,  N_INPUT_BITS)),
      std_logic_vector(to_unsigned(95,   N_INPUT_BITS)),
      std_logic_vector(to_unsigned(75,   N_INPUT_BITS))
    );

    constant matrix_c_values : vector_out_array := (
		  std_logic_vector(to_unsigned(50262, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(128056, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(130414, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(119437, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(121273, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(151651, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(128652, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(93909, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(113540, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(128498, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(164326, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(124320, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(138294, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(181605, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(177261, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(136989, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(129067, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(151285, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(166276, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(178608, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(148399, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(210039, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(158124, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(102713, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(108860, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(150681, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(175052, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(164052, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(150829, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(189537, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(149638, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(115839, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(102977, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(89993, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(127274, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(115778, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(83343, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(143856, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(97315, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(85977, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(104959, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(138806, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(151163, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(172402, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(124715, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(207667, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(154170, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(108557, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(86724, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(54356, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(78685, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(89063, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(91129, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(100202, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(83292, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(67129, N_OUTPUT_BITS)),

      std_logic_vector(to_unsigned(81951, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(107527, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(95720, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(127228, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(131392, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(115236, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(135198, N_OUTPUT_BITS)),
      std_logic_vector(to_unsigned(74334, N_OUTPUT_BITS))
    );


    -- Clock period constant
    constant CLK_period : time := 10 ns;
    constant N_ADDRESS_WIDTH : integer := integer(ceil(log2(real(MATRIX_SIZE*MATRIX_SIZE))));

    signal CLK : std_logic := '0';
    signal rst : std_logic := '0';
    signal data_in : std_logic_vector(N_INPUT_BITS-1 downto 0);
    signal data_out : std_logic_vector(N_OUTPUT_BITS-1 downto 0);
    signal address_ab : std_logic_vector(N_ADDRESS_WIDTH + 1 -1 downto 0);
    signal address_c : std_logic_vector(N_ADDRESS_WIDTH -1 downto 0);
    signal start : std_logic := '0';
    signal read_input : std_logic := '0';
    signal write_input : std_logic := '0';
    signal read_output : std_logic := '0';
    signal done : std_logic := '0';

    --- debugging signals
    signal matrix_state : std_logic_vector(3 downto 0);
    signal i : unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
    signal j : unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
    signal k : unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
    signal A_value : unsigned(N_OUTPUT_BITS/2 - 1 downto 0);
    signal B_value : unsigned(N_OUTPUT_BITS/2 - 1 downto 0);
    signal Temp : unsigned(N_OUTPUT_BITS - 1 downto 0);
    signal multiplication : unsigned(N_OUTPUT_BITS - 1 downto 0);
    --- 




    component matrix_multiplier
        generic (
          N_INPUT : integer := N_INPUT_BITS;
          N_OUTPUT : integer := N_OUTPUT_BITS;
          N_MATRIX_SIZE : integer := MATRIX_SIZE;
          N_ADDRESS_WIDTH : integer := N_ADDRESS_WIDTH
        );
        port (
          CLK : in std_logic;
          rst : in std_logic;
          data_in : in std_logic_vector(N_INPUT_BITS-1 downto 0);
          data_out : out std_logic_vector(N_OUTPUT_BITS-1 downto 0);
          address_ab : in std_logic_vector(N_ADDRESS_WIDTH + 1 -1 downto 0);
          address_c : out std_logic_vector(N_ADDRESS_WIDTH -1 downto 0);
          start : in std_logic;
          read_input : in std_logic;
          write_input : in std_logic;
          read_output : in std_logic;


          --- start debugging
          matrix_state : out std_logic_vector(3 downto 0);
          i : out unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
          j : out unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
          k : out unsigned(N_ADDRESS_WIDTH/2 -1 downto 0);
          A_value : out unsigned(N_OUTPUT_BITS/2 - 1 downto 0);
          B_value : out unsigned(N_OUTPUT_BITS/2 - 1 downto 0);
          Temp : out unsigned(N_OUTPUT_BITS - 1 downto 0);
          multiplication : out unsigned(N_OUTPUT_BITS - 1 downto 0);
          ---

          done : out std_logic
        );
    end component;



    function bits_to_string(matrix_state : std_logic_vector) return string is
    begin
        case matrix_state is
            when "0000" => return string'("IDLE");
            when "0001" => return string'("OUTER_LOOP");
            when "0010" => return string'("MIDDLE_LOOP");
            when "0011" => return string'("INNER_LOOP_READING");
            when "0100" => return string'("INNER_LOOP_MULTIPLICATION");
            when "0101" => return string'("INNER_LOOP_ADDING");
            when "0110" => return string'("INNER_LOOP_END");
            when "0111" => return string'("MIDDLE_LOOP_END");
            when "1000" => return string'("OUTER_LOOP_END");
            when "1001" => return string'("FINISHING");
            when others => return string'("UNKNOWN");
        end case;
    end function;


    signal were_there_errors : boolean := false;
    signal cycle_count : integer := 0;
    signal test_start_cycle_count : integer := 0;
    signal test_end_cycle_count : integer := 0;


begin
    -- bind ports to the top level signals
    CLK_out <= CLK;
    rst_out <= rst;
    start_out <= start;
    done_out <= done;

    -- Instantiate the matrix_multiplier module
    uut: matrix_multiplier
        generic map (
          N_INPUT => N_INPUT_BITS,
          N_OUTPUT => N_OUTPUT_BITS,
          N_MATRIX_SIZE => MATRIX_SIZE,
          N_ADDRESS_WIDTH => N_ADDRESS_WIDTH
        )
        port map (
          CLK => CLK,
          rst => rst,
          data_in => data_in,
          data_out => data_out,
          address_ab => address_ab,
          address_c => address_c,
          start => start,
          read_input => read_input,
          write_input => write_input,
          read_output => read_output,

          ---- start debugging
          matrix_state => matrix_state,
          i => i,
          j => j,
          k => k,
          A_value => A_value,
          B_value => B_value,
          Temp => Temp,
          multiplication => multiplication,
          ----

          done => done
        );


    -- Clock process
    CLK_process: process
    begin
        CLK <= '0';
        wait for CLK_period / 2;
        CLK <= '1';
        wait for CLK_period / 2;

        cycle_count <= cycle_count + 1;
    end process;

    -- Test stimulus process
    stimulus_process: process
        variable l : line;
        variable expected_value : integer := 0;
    begin
        start <= '0';
        for iteration in 0 to 0 loop
          -- Apply reset
          rst <= '1';
          wait for CLK_period;
          wait for CLK_period;
          wait for CLK_period;
          wait for CLK_period;
          rst <= '0';
          wait for CLK_period;
          wait for CLK_period;
          wait for CLK_period;

          -- write matrix_a and matrix_b
          for item in 0 to (MATRIX_ELEMENTS -1) loop
              read_input <= '0'; -- Disable reading
              read_output <= '0'; -- Disable reading

              -- Writing to matrix_a at address item
              address_ab <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH + 1));
              data_in <= matrix_a_values(item);
              write_input <= '1'; -- Enable writing

              wait for CLK_period;

              write_input <= '0'; -- Disable writing
              wait for CLK_period;

              -- Writing to matrix_b at address item
              address_ab <= std_logic_vector(to_unsigned(item + MATRIX_ELEMENTS, N_ADDRESS_WIDTH + 1)); -- + MATRIX_ELEMENTS to make first bit 1
              data_in <= matrix_b_values(item);
              write_input <= '1'; -- Enable writing

              wait for CLK_period;

              write_input <= '0'; -- Disable writing

              wait for CLK_period;





          end loop;




          -- print the whole of matrix a, b and c
          for item in 0 to (MATRIX_ELEMENTS -1) loop
              -- Reading from matrix_a at address 0
              address_ab <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH + 1));
              read_input <= '1'; -- Enable reading
              wait for CLK_period;

              write(l, string'("   ") & to_hstring(address_ab) & string'(": 0x") & to_hstring(data_out));
              -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              read_input <= '0'; -- Disable reading
              wait for 2 * CLK_period;

              -- Reading from matrix_b at address 0
              address_ab <= std_logic_vector(to_unsigned(item + MATRIX_ELEMENTS, N_ADDRESS_WIDTH + 1));
              read_input <= '1'; -- Enable reading
              wait for 2 * CLK_period;

              write(l, string'("   ") & to_hstring(data_out));
              -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              read_input <= '0'; -- Disable reading

              wait for 2 * CLK_period;
              -- Reading from matrix_c at address 0
              address_c <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH));
              read_output <= '1'; -- Enable reading

              wait for 2 * CLK_period;

              write(l, string'("   ") & to_hstring(data_out));
              -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));

              read_output <= '0'; -- Disable reading

              wait for 2 * CLK_period;
              writeline(output, l);
          end loop;




          -- start the multiplication
          test_start_cycle_count <= cycle_count;
          start <= '1';
          wait for CLK_period;
          start <= '0';


          -- for matrix_i in 0 to 2400 loop
          -- for matrix_i in 0 to 40 loop
          --     write(l, string'("matrix_i: ") & integer'image(matrix_i));
          --     writeline(output, l);
          while done = '0' loop

              write(l, string'("i: ") & integer'image(to_integer(i)));
              writeline(output, l);
              write(l, string'("j: ") & integer'image(to_integer(j)));
              writeline(output, l);
              write(l, string'("k: ") & integer'image(to_integer(k)));
              writeline(output, l);
              write(l, string'("A: ") & integer'image(to_integer(A_value)));
              writeline(output, l);
              write(l, string'("B: ") & integer'image(to_integer(B_value)));
              writeline(output, l);
              write(l, string'("multiplication: ") & integer'image(to_integer(multiplication)));
              writeline(output, l);
              write(l, string'("Temp: ") & integer'image(to_integer(Temp)));
              writeline(output, l);
              write(l, string'("State: ") & bits_to_string(matrix_state));
              writeline(output, l);
              writeline(output, l);


              if done = '1' then
                  write(l, string'("Multiplication completed."));
                  writeline(output, l);
                  writeline(output, l);
                  exit;
              else 
                wait for CLK_period;
              end if;
              



          end loop;

          -- if done = '0' then
          --   wait until done = '1';
          --   test_end_cycle_count <= cycle_count;
          -- end if;





          -- wait until done = '1';


          test_end_cycle_count <= cycle_count;
          write(l, string'("Multiplication completed."));
          writeline(output, l);
          writeline(output, l);

          wait for CLK_period;
          -- print the whole of matrix a, b and c
          for item in 0 to (MATRIX_ELEMENTS -1) loop
          -- for item in 0 to 2 loop
              -- Reading from matrix_a at address 0
              address_ab <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH + 1));
              read_input <= '1'; -- Enable reading
              wait for CLK_period;

              write(l, string'("   ") & to_hstring(address_ab) & string'(": 0x") & to_hstring(data_out));
              -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              read_input <= '0'; -- Disable reading
              wait for 2 * CLK_period;

              -- Reading from matrix_b at address 0
              address_ab <= std_logic_vector(to_unsigned(item + MATRIX_ELEMENTS, N_ADDRESS_WIDTH + 1));
              read_input <= '1'; -- Enable reading
              wait for 2 * CLK_period;

              write(l, string'("   ") & to_hstring(data_out));
              -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              read_input <= '0'; -- Disable reading

              wait for 2 * CLK_period;
              -- Reading from matrix_c at address 0
              address_c <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH));
              read_output <= '1'; -- Enable reading

              wait for 2 * CLK_period;

              write(l, string'("   ") & to_hstring(data_out));
              write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));

              -- check if data_out is equal to expected value
              if data_out /= matrix_c_values(item) then
                  were_there_errors <= true;
                  write(l, string'("  -- Expected: ") & integer'image(to_integer(unsigned(matrix_c_values(item)))));
              end if;

              read_output <= '0'; -- Disable reading

              wait for 2 * CLK_period;
              writeline(output, l);
          end loop;


          -- check matrix_c
          for item in 0 to (MATRIX_ELEMENTS -1) loop
              address_c <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH));
              read_output <= '1'; -- Enable reading

              wait for 2 * CLK_period;

              -- check if data_out is equal to expected value
              if data_out /= matrix_c_values(item) then
                  were_there_errors <= true;
                  write(l, string'("  -- Expected: ") & to_hstring(matrix_c_values(item)));
                  writeline(output, l);
              end if;

              read_output <= '0'; -- Disable reading

              wait for 2 * CLK_period;
          end loop;

          -- End of testing

          if were_there_errors then
              writeline(output, l);
              write(l, string'("Test ") & integer'image(iteration) & string'(" failed and took ") & integer'image(test_end_cycle_count - test_start_cycle_count) & string'(" cycles."));
              writeline(output, l);
          else
              writeline(output, l);
              write(l, string'("Test ") & integer'image(iteration) & string'(" passed and took ") & integer'image(test_end_cycle_count - test_start_cycle_count) & string'(" cycles."));
              writeline(output, l);
          end if;
          
          wait for 2 * CLK_period;


          -- Apply reset
          rst <= '1';
          wait for CLK_period;
          wait for CLK_period;
          wait for CLK_period;
          wait for CLK_period;
          rst <= '0';
          wait for CLK_period;
          wait for CLK_period;
          wait for CLK_period;

          writeline(output, l);
          writeline(output, l);
          write(l, string'("Zero Test:"));
          writeline(output, l);

          -- start the second zero multiplication
          test_start_cycle_count <= cycle_count;
          start <= '1';
          wait for CLK_period;
          start <= '0';

          if done = '0' then
            wait until done = '1';
            test_end_cycle_count <= cycle_count;
          end if;

          wait for 2 * CLK_period;




          for item in 0 to (MATRIX_ELEMENTS -1) loop
              -- -- Reading from matrix_a at address 0
              -- address_ab <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH + 1));
              -- read_input <= '1'; -- Enable reading
              -- wait for CLK_period;

              -- write(l, string'("   ") & to_hstring(address_ab) & string'(": 0x") & to_hstring(data_out));
              -- -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              -- read_input <= '0'; -- Disable reading
              -- wait for 2 * CLK_period;

              -- -- Reading from matrix_b at address 0
              -- address_ab <= std_logic_vector(to_unsigned(item + MATRIX_ELEMENTS, N_ADDRESS_WIDTH + 1));
              -- read_input <= '1'; -- Enable reading
              -- wait for 2 * CLK_period;

              -- write(l, string'("   ") & to_hstring(data_out));
              -- -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              -- read_input <= '0'; -- Disable reading

              -- wait for 2 * CLK_period;
              -- -- Reading from matrix_c at address 0
              -- address_c <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH));
              -- read_output <= '1'; -- Enable reading

              -- wait for 2 * CLK_period;

              -- write(l, string'("   ") & to_hstring(data_out));
              -- write(l, string'("|") & integer'image(to_integer(unsigned(data_out))));
              address_c <= std_logic_vector(to_unsigned(item, N_ADDRESS_WIDTH));
              read_output <= '1'; -- Enable reading

              wait for 2 * CLK_period;

              -- check if data_out is equal to expected value
              if data_out /= X"00000" then
                  were_there_errors <= true;
                  write(l, string'("  -- Expected: ") & to_hstring(matrix_c_values(item)));
              end if;

              read_output <= '0'; -- Disable reading

              wait for 2 * CLK_period;
              -- writeline(output, l);
          end loop;

          if were_there_errors then
              writeline(output, l);
              write(l, string'("Zero Test ") & integer'image(iteration) & string'(" failed and took ") & integer'image(test_end_cycle_count - test_start_cycle_count) & string'(" cycles."));
              writeline(output, l);
          else
              writeline(output, l);
              write(l, string'("Zero Test ") & integer'image(iteration) & string'(" passed and took ") & integer'image(test_end_cycle_count - test_start_cycle_count) & string'(" cycles."));
              writeline(output, l);
          end if;
          

          
          wait for 2 * CLK_period;
        end loop;

        wait;

    end process;


end architecture test;


