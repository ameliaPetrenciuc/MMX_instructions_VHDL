library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port (enable: out STD_LOGIC;
          btn: in STD_LOGIC;
          clk: in STD_LOGIC);
end MPG;

architecture Behavioral of MPG is
signal tmp: STD_LOGIC_VECTOR(17 downto 0) :=(others=>'0');
signal Q1, Q2, Q3: STD_LOGIC;

begin

   enable<= Q2 and (not Q3);
   
   process(clk)
   begin
       if rising_edge(clk) then
        tmp<=tmp+1;
       end if;
     end process;
       
   process(clk)
     begin   
      if clk'event and clk='1' then
         if tmp(17 downto 0)="111111111111111111" then
               Q1<=btn;
          end if;
        end if;
      end process;
      
    process(clk)
    begin
      if clk'event and clk='1' then
         Q2<=Q1;
         Q3<=Q2;
      end if;
    end process;
    
end Behavioral;
