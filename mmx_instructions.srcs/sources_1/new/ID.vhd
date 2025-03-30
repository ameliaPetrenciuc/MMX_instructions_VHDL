library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
   PORT( RegWrite: in std_logic;
    CLK: in std_logic;
    Instr: in std_logic_vector(31 downto 0);--aici
    RegDst: in std_logic;
    EN: in std_logic;
    ExtOp: in std_logic;
    RD1: out std_logic_vector(63 downto 0);
    RD2: out std_logic_vector(63 downto 0);
    WD: in std_logic_vector(63 downto 0);
    Ext_Imm: out std_logic_vector(63 downto 0);
    func: out std_logic_vector(5 downto 0);
    sa: out std_logic_vector(4 downto 0));
end ID;

architecture Behavioral of ID is

component RegisterFile is
    port (
    clk : in std_logic;
    ra1 : in std_logic_vector (4 downto 0);
    ra2 : in std_logic_vector (4 downto 0);
    wa : in std_logic_vector (4 downto 0);
    wd : in std_logic_vector (63 downto 0);
    regwr : in std_logic;
    en : in std_logic;
    rd1 : out std_logic_vector (63 downto 0);
    rd2 : out std_logic_vector (63 downto 0)
    );
end component;

signal wa: std_logic_vector(4 downto 0):=(others=>'0');
begin

regfile:  RegisterFile port map(clk=>clk,ra1=>Instr(25 downto 21), ra2=>Instr(20 downto 16), wa=>wa, wd=>wd, regwr=>RegWrite, en=>en,rd1=>rd1,rd2=> rd2);     
Ext_Imm(15 downto 0) <= Instr(15 downto 0); 
    with ExtOp select
        Ext_Imm(63 downto 16) <= (others => Instr(15)) when '1',
                                (others => '0') when '0',
                                (others => '0') when others; 
process(RegDst, Instr)
begin
case (RegDst) is
        when '0' => wa <= Instr(20 downto 16);
        when others => wa <= Instr(15 downto 11);
    end case;
end process; 
  
func<=Instr(5 downto 0);
sa<= Instr(10 downto 6);
		
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
entity RegisterFile is
    port ( clk : in std_logic;
ra1 : in std_logic_vector(4 downto 0);
ra2 : in std_logic_vector(4 downto 0);
wa : in std_logic_vector(4 downto 0);
wd : in std_logic_vector(63 downto 0);
regwr : in std_logic;
en: in std_logic;
rd1 : out std_logic_vector(63 downto 0);
rd2 : out std_logic_vector(63 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

type reg_array is array (0 to 7) of std_logic_vector(63 downto 0);
signal RegisterFile : reg_array :=(x"0000000000000000", -- 0
                     x"0000000000000111", -- 1
                     x"0000000000000100", -- 2
                     x"0000000000000100", -- 3
                     x"0000000000000111", -- 4
                     x"0000000000001010", -- 5
                     x"0000000000000701", -- 6
                     x"0000000000000001" -- 7
                                           );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en='1' and regwr = '1' then
                RegisterFile(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
    rd1 <=  RegisterFile(conv_integer(ra1));
    rd2 <=  RegisterFile(conv_integer(ra2)); 

end Behavioral;