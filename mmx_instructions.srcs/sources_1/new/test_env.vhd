library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
-------------semnale IF--------------------------------
signal en: std_logic;
signal reset: std_logic;
signal pcsrc: std_logic;
signal branch_address: std_logic_vector(31 downto 0):=(others=>'0');
signal instruction: std_logic_vector(31 downto 0):=(others=>'0');
signal pcNext: std_logic_vector(31 downto 0):=(others=>'0');

------------ semnale UC ------------
signal regDst:   STD_LOGIC := '0';
signal extOp:    STD_LOGIC := '0';
signal aluSrc:   STD_LOGIC := '0';
signal branch:   STD_LOGIC := '0';
signal regWrite: STD_LOGIC := '0';

signal aluOp: STD_LOGIC; 
-------------------------------------------
------------ semnale ID ------------
signal rd1:  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal rd2:  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal wd:   STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal funct:    STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
signal ext_Imm:  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal sa: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

------------------semnale EX---------------------
signal aluRes:  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal zero: STD_LOGIC:= '0';


signal aux: std_logic_vector(27 downto 0):=(others=>'0');
signal digits: STD_LOGIC_VECTOR(63 downto 0);
signal out_ssd: STD_LOGIC_VECTOR (63 downto 0);

component MPG 
   Port (enable: out STD_LOGIC;
          btn: in STD_LOGIC;
          clk: in STD_LOGIC);
end component ;

component SSD
   PORT( clk : in STD_LOGIC;
       digits : in STD_LOGIC_VECTOR(15 downto 0);
       an : out STD_LOGIC_VECTOR(3 downto 0);
       cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch is
Port (clk : in STD_LOGIC;
      reset: in std_logic;
      en : in STD_LOGIC;
      PCSrc: in std_logic;
      branch_adress: in STD_LOGIC_VECTOR (31 downto 0);
      instruction : out STD_LOGIC_VECTOR (31 downto 0);
      PCNext: out STD_LOGIC_VECTOR (31 downto 0)
      );
end component;

component UC
    Port(instr : in std_logic_vector(31 downto 0);
		RegDst : out std_logic;
		ExtOp: out std_logic;
		ALUSrc: out std_logic;
		Branch: out std_logic;
		ALUOp : out std_logic;
		RegWrite : out std_logic);
end component;

component ID is
    Port( RegWrite: in std_logic;
    CLK: in std_logic;
    Instr: in std_logic_vector(31 downto 0);
    RegDst: in std_logic;
    EN: in std_logic;
    ExtOp: in std_logic;
    RD1: out std_logic_vector(63 downto 0);
    RD2: out std_logic_vector(63 downto 0);
    WD: in std_logic_vector(63 downto 0);
    Ext_Imm: out std_logic_vector(63 downto 0);
    func: out std_logic_vector(5 downto 0);
    sa: out std_logic_vector(4 downto 0));
end component;

component EX
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
   end component;
   
begin

pcsrc <= (branch and zero);

process(sw(7 downto 5),instruction,pcnext,rd1,rd2,ext_Imm,aluRes,wd)
begin 
    case sw(7 downto 5) is
        when "000"=>digits(31 downto 0)<=instruction;
        when "001"=>digits(31 downto 0)<=pcnext;
        when "010"=>digits<=rd1;
        when "011"=>digits<=rd2;
        when "100"=>digits<=ext_Imm;
        when "101"=>digits<=aluRes;
        when "110"=>digits<=wd;
        when others => digits <= (others => '0');
        
     end case;
end process;
                                    
  wd<=aluRes;
    
    led(5 downto 0)<= aluOp&regDst&extOp&aluSrc&branch&regWrite;

    MPG1: MPG port map(enable => en, btn => btn(0), clk => clk);
    IFetch1: IFetch port map(clk=>clk, reset=>btn(1),en=>en,PCSrc=>pcsrc,
                             branch_adress=>branch_address,instruction=>instruction,PCNext=>pcNext );
    UC1: UC port map(instr=>instruction, RegDst=>regDst, ExtOp=>extOp, ALUSrc=>aluSrc, Branch=>branch, 
                     ALUOp=>aluOp, RegWrite=>regWrite);
    ID1: ID port map(RegWrite => regWrite,CLK=>clk,Instr=>instruction, RegDst=>regDst, EN=>en, ExtOp=>extOp,
                     RD1=>rd1, RD2=>rd2, WD=>wd , Ext_Imm=>ext_Imm, func=>funct, sa=>sa);
    EX1: EX port map(RD1=>rd1, ALUSrc=>aluSrc, RD2=>rd2, Ext_Imm=>ext_Imm, sa=>sa, func=>funct, ALUOp=>aluOp, ALURes=>aluRes, 
                     PCNext=>pcNext, Zero=>zero, BranchAddr=>branch_address);
--    MEM1: MEM port map(MemWrite=>memWrite, AluResIn=>aluResin, RD2=>rd2, CLK=>clk, EN=>en, MemData=> memData,AluResOut=>aluResout );
    SSD1: SSD port map(clk => clk, digits => digits(15 downto 0), an => an, cat => cat);
    
end Behavioral;
