
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UC is
    Port(instr : in std_logic_vector(31 downto 0);
		RegDst : out std_logic;
		ExtOp: out std_logic;
		ALUSrc: out std_logic;
		Branch: out std_logic;
		ALUOp : out std_logic;
		RegWrite : out std_logic);
end UC;

architecture Behavioral of UC is
begin
    process(instr(31 downto 26))
        begin
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0';
        Branch <= '0';  RegWrite <= '0'; ALUOp <= '0';
          
            case instr(31 downto 26) is
            
            when "000000" =>-- R type
                    RegDst <= '1';
                    ALUOp <= '0';
                    RegWrite <= '1';
                    
--            when "000001"=>       
--                    ExtOp<='1';
--                    ALUSrc<='1';
--                    Branch<='1';
--                    AluOp<='1';
                    
            when others=>
                    RegDst<='0';
                    ExtOp<='0';
                    ALUSrc<='0';
                    Branch<='0';
                    RegWrite<='0';
                    ALUOp<='0';
            end case;
          end process;


end Behavioral;

