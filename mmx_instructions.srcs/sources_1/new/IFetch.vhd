library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
Port (clk : in STD_LOGIC;
      reset: in std_logic;
      en : in STD_LOGIC;
      PCSrc: in std_logic;
      branch_adress: in STD_LOGIC_VECTOR (31 downto 0);
      instruction : out STD_LOGIC_VECTOR (31 downto 0);
      PCNext: out STD_LOGIC_VECTOR (31 downto 0)
      );
end IFetch;

architecture Behavioral of IFetch is
    signal mux1: std_logic_vector(31 downto 0):=(others=>'0');
    signal Q:std_logic_vector(31 downto 0):=(others=>'0');
   -- signal mux2: std_logic_vector(31 downto 0):=(others=>'0');
    signal add: STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
   -- signal dmuxunu: std_logic_vector(31 downto 0);
    type ROM is array (0 to 31) of STD_LOGIC_VECTOR (31 downto 0);
    signal ROM_ARRAY: ROM  :=(B"000000_00001_00010_00011_00000_000000",   -- 1800 r3=r1+r2=111+100=211
                       B"000000_00100_00010_00101_00000_000001", --  2801 r5=r4-r2=111-100=011
                       B"000000_00010_00011_00100_00000_000101", --  2005 r2 andn r3 = 100 nand 211 ==ffff=r4
                       B"000000_00010_00001_00100_00000_000100", --  2004 pxor r4=r2 xor r1, 100 xor 111= 011
                       B"000000_00000_00110_00011_00001_000010", --  1842 psrld r3=r6>>1 ,701>>1=380 in reg3
                       B"000000_00000_00110_00101_00001_000011", --  2843 pslld r5=r6<<1 ,701<<1=eo2 in reg5
                       others => X"00000000"
);

begin
    process(PCSrc,branch_adress,add)
    begin
    if PCSrc = '1' then
        mux1 <= branch_adress;
        else
        mux1 <= add;
    end if;
    end process;
    
    --add<=Q+x"00000004";
    --
   
    
   process(clk, reset, en)
    begin
        if reset = '1' then
            Q <= X"00000000";
       elsif rising_edge(clk) then
            if en='1' then 
                Q<=mux1;
            end if;
        end if;
    end process;

 
    instruction<=ROM_ARRAY(conv_integer(Q(4 downto 0)));
    --add<=Q+1;
    add<=Q+x"00000001";
    PCNext<=add;
 
end Behavioral;
