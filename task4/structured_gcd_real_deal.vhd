library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  -- control signals to/from the datapath and external control interface.
  port (
    clk, reset : in std_logic;
    
    Req : in std_logic;
    Ack : out std_logic;
    
    Z, N : in std_logic;

    LDA : out std_logic;
    LDB : out std_logic;
    
    FN : out std_logic_vector(1 downto 0);

    ABorALU : out std_logic
  );
end fsm;

architecture states of fsm is
-- standard behavioral processes for state transitions and control outputs.
  type state_type is (state_idle, state_1, state_2, state_3, state_4, state_5, state_6, state_output);
  
  signal state, next_state : state_type;

begin
  cl : process (state, Req, Z, N)
  begin
    next_state <= state;
    Ack <= '0';
    LDA <= '0';
    LDB <= '0';

    case (state) is
      when state_idle =>
        Ack <= '0';
        if Req = '1' then
          next_state <= state_1;
        end if;

      when state_1 =>
        ABorALU <= '1'; -- load data_in2 (left side of mux like in drawing).
        LDA <= '1';
        Ack <= '1';
        next_state <= state_2;

      when state_2 =>
        Ack <= '1';
        if Req = '0' then
          next_state <= state_3;
        end if;

      when state_3 =>
        Ack <= '0';
        if Req = '1' then
          next_state <= state_4;
        end if;
          
      when state_4 =>
        ABorALU <= '1'; -- load data_in2 (left side of mux like in drawing).
        LDA <= '0';
        LDB <= '1';
        Ack <= '0';
        next_state <= state_5;

      when state_5 =>
        Ack <= '0';
        FN <= "00"; -- A - B.
        if Z = '1' AND N = '0' then -- A - B (A = B).
          next_state <= state_output;
        elsif Z = '0' AND N = '0' then -- A - B (A > B).
          ABorALU <= '0';
          LDA <= '1'; -- load reg a because reg a = reg a - reg b.
          next_state <= state_5;
        else -- B - A (A < B).
          next_state <= state_6;
        end if;

      when state_6 =>
        FN <= "01"; -- B - A (A < B).
        ABorALU <= '0';
        LDB <= '1'; -- load reg b because reg b = reg b - reg a.
        next_state <= state_5;

      when state_output =>
        LDB <= '0';
        FN <= "10"; -- ALUout yields just reg a.
        Ack <= '1';
        if Req = '0' then
          next_state <= state_idle;
        end if;
      end case;
   end process cl;
   
   seq : process (clk, reset)
   begin
    if reset = '1' then
        state <= state_idle;
    elsif rising_edge(clk) then
        state <= next_state;
    end if;
   end process seq;
end states;

-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port (
    clk : in std_logic;
    reset : in std_logic;
    AB : in unsigned(15 downto 0);
    C : out unsigned(15 downto 0);
    Z, N : out std_logic;
    LDA, LDB : in std_logic;
    FN : in std_logic_vector(1 downto 0);
    ABorALU : in std_logic
  );
end datapath;

architecture structural of datapath is
  signal reg_a_out, reg_b_out : unsigned(15 downto 0);

  signal mux_out : unsigned(15 downto 0);

  signal ALU_out : unsigned(15 downto 0);

begin

  U_BUF : entity work.buf
    port map (
      data_in => reg_a_out,
      data_out => C
    );

  U_MUX : entity work.mux
    port map (
      data_in1 => ALU_out,
      data_in2 => AB,
      s => ABorALU,
      data_out => mux_out
    );
  
  U_REG_A : entity work.reg
    port map (
      clk => clk,
      en => LDA,
      data_in => mux_out,
      data_out => reg_a_out
    );

  U_REG_B : entity work.reg
    port map (
      clk => clk,
      en => LDB,
      data_in => mux_out,
      data_out => reg_b_out
    );

  U_ALU : entity work.alu
    port map (
      A => reg_a_out,
      B => reg_b_out,
      fn => FN,
      C => ALU_out,
      Z => Z,
      N => N
    );

end structural;

-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
  port (clk : in std_logic;
        reset : in std_logic;
        req: in std_logic;
        AB: in unsigned(15 downto 0);
        ack: out std_logic;
        C: out unsigned(15 downto 0));
end gcd;

architecture structural of gcd is
  -- connects fsm and datapath.

  signal LDA, LDB, ABorALU : std_logic;
  signal FN : std_logic_vector(1 downto 0);
  signal Z, N : std_logic;

begin

  U_FSM: entity work.fsm
    port map (
      clk => clk,
      reset => reset,
      Req => Req,
      Ack => Ack,
      Z => Z,
      N => N,
      LDA => LDA,
      LDB => LDB,
      FN => FN,
      ABorALU => ABorALU
    );

  U_DP: entity work.datapath
    port map (
      clk => clk,
      reset => reset,
      AB => AB,
      C => C,
      Z => Z,
      N => N,
      LDA => LDA,
      LDB => LDB,
      FN => FN,
      ABorALU => ABorALU
    );


end structural;

