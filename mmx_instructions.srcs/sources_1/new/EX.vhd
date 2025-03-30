library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity EX is
 Port ( RD1: in STD_LOGIC_VECTOR (63 downto 0);
        ALUSrc: in STD_LOGIC;
        RD2: in STD_LOGIC_VECTOR (63 downto 0);
        Ext_Imm: in STD_LOGIC_VECTOR (63 downto 0);
        sa: in STD_LOGIC_VECTOR(4 downto 0);
        func: in STD_LOGIC_VECTOR (5 downto 0);
        ALUOp: in STD_LOGIC;
        ALURes: out STD_LOGIC_VECTOR (63 downto 0);
        PCNext: in STD_LOGIC_VECTOR (31 downto 0);
        Zero: out STD_LOGIC;
        BranchAddr: out STD_LOGIC_VECTOR (31 downto 0)
);
end EX;

architecture Behavioral of EX is

  signal ALUCtrl: STD_LOGIC_VECTOR(2 downto 0):= (others => '0');
  signal ALUIn2: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
 -- signal Shift: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
  signal C: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
  signal C_33:STD_LOGIC_VECTOR(32 downto 0):= (others => '0');
  signal carry:STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
  signal C_31_0:STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
  signal C_31_1:STD_LOGIC_VECTOR(31 downto 0):= (others => '0');

begin
 
 process(AluOp,func)
 begin
    case AluOp is 
        when '0'=> --R
            case func is
                when "000000"=>ALUCtrl<="000"; --add
                when "000001"=>ALUCtrl<="001";--sub
                when "000101"=>ALUCtrl<="010";--andn
                when "000010"=>ALUCtrl<="011";--psrld >>
                when "000011"=>ALUCtrl<="100";--pslld <<
                when "000100"=>ALUCtrl<="101";--xor
                when others => ALUCtrl <= (others => '0');
            end case;
        when others => ALUCtrl <= (others => '0');
    end case;
 end process;
 
  with  ALUSrc select ALUIn2 <= Rd2 when '0',
                            Ext_Imm when '1',
                           (others => '0') when others;
 
 -- ALU
    process(RD1, ALUIn2, ALUCtrl, sa)
    begin
        case ALUCtrl is
            when "000" => C_33<= ('0' & RD1(31 downto 0)) + ('0' & ALUIn2(31 downto 0)); --add
                       C(63 downto 32)<=RD1(63 downto 32)+ALUIn2(63 downto 32)+C_33(32);
                       C(31 downto 0)<=C_33(31 downto 0);
           when "001" =>  C_31_0<=RD1(31 downto 0)-ALUIn2(31 downto 0);
                          carry<=not RD1(31 downto 0) and ALUIn2(31 downto 0);
                          C_31_1<=RD1(63 downto 32) xor ALUIn2(63 downto 32) xor carry;
                          C<=C_31_1 & C_31_0;
           when "010" => C <= RD1 nand ALUIn2; --nand
           when "011" =>     --psrld
              case sa is
                  when "00001" => C(63 downto 32)<="0" & ALUIn2(63 downto 33);
                                  C(31 downto 0)<=ALUIn2(32) & ALUIn2(31 downto 1);
                  when "00010" => C(63 downto 32)<="00" & ALUIn2(63 downto 34);
                                  C(31 downto 0)<=ALUIn2(33 downto 32) & ALUIn2(31 downto 2);
                  when "00011" => C(63 downto 32)<="000" & ALUIn2(63 downto 35);
                                  C(31 downto 0)<=ALUIn2(34 downto 32) & ALUIn2(31 downto 3);
                  when others => C <= (others => '0');
              end case;
           when "100" =>   --pslld
               case sa is
                   when "00001" => C(63 downto 32)<=  ALUIn2(62 downto 31);
                                    C(31 downto 0)<=( ALUIn2(30 downto 0) &"0");
                   when "00010" => C(63 downto 32)<=  ALUIn2(61 downto 30);
                                     C(31 downto 0)<=( ALUIn2(29 downto 0) &"00");
                   when "00011" => C(63 downto 32)<=  ALUIn2(60 downto 29);
                                     C(31 downto 0)<=( ALUIn2(28 downto 0) &"000");
                    when others => C <= (others => '0');
                end case;
                           
         when "101" => C <= RD1 xor ALUIn2; 
           
        when others => C <= (others => '0');
     end case;
    end process;
    
     with C select Zero <= '1'  when X"0000000000000000",
                           '0' when others;

  ALURes<=C;
  BranchAddr<=Ext_Imm(31 downto 0)+PCNext;
        
end Behavioral;