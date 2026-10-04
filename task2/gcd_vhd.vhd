-- -----------------------------------------------------------------------------
--
--  Title      :  FSMD implementation of GCD
--             :
--  Developers :  Jens Sparsø, Rasmus Bo Sørensen and Mathias Møller Bruhn
--           :
--  Purpose    :  This is a FSMD (finite state machine with datapath) 
--             :  implementation the GCD circuit
--             :
--  Revision   :  02203 fall 2019 v.5.0
--
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is

  port (clk : in std_logic;             -- The clock signal.
    reset : in  std_logic;              -- Reset the module.
    req   : in  std_logic;              -- Input operand / start computation.
    AB    : in  unsigned(15 downto 0);  -- The two operands.
    ack   : out std_logic;              -- Computation is complete.
    C     : out unsigned(15 downto 0)); -- The result.
end gcd;

architecture fsmd of gcd is

  type state_type is (state_idle, state_1, state_2, state_3, state_4, state_5, state_6, state_output); -- Input your own state names

  signal reg_a, next_reg_a, next_reg_b, reg_b : unsigned(15 downto 0);

  signal state, next_state : state_type;


begin

  -- Combinatoriel logic

  cl : process (req,ab,state,reg_a,reg_b)
  begin

    -- Default values:
    next_state <= state;
    next_reg_a <= reg_a;
    next_reg_b <= reg_b;
    ack        <= '0';
    C          <= reg_a;

    case (state) is
      when state_idle =>
        ack <= '0';
        if req = '1' then
          next_state <= state_1;
        end if;

      when state_1 =>
        next_reg_a <= AB;
        ack <= '1';
        next_state <= state_2;

      when state_2 =>
        ack <= '1';
        if req = '0' then
          next_state <= state_3;
        end if;

      when state_3 =>
        ack <= '0';
        if req = '1' then
          next_state <= state_4;
        end if;

      when state_4 =>
        next_reg_b <= AB; 
        ack <= '0';
        next_state <= state_5;

      when state_5 =>
        ack <= '0';
        if reg_a = reg_b then
          next_state <= state_output;
        elsif reg_a > reg_b then
          next_reg_a <= reg_a - reg_b;
          next_state <= state_5;
        else
          next_state <= state_6;
        end if;

      when state_6 =>
        next_reg_b <= reg_b - reg_a;
        next_state <= state_5;

      when state_output =>
        C <= reg_a;
        ack <= '1';
        if req = '0' then
          next_state <= state_idle;
        end if;

    end case;
  end process cl;

  -- Registers

  seq : process (clk, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state <= state_idle;
        reg_a <= (others => '0');
        reg_b <= (others => '0');
      else
        state <= next_state;
        reg_a <= next_reg_a;
        reg_b <= next_reg_b;
      end if;
    end if;
          
  end process seq;

end fsmd;
