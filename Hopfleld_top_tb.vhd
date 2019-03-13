------------------------------------------------------------------
--Copyright 2019 Andrey S. Ionisyan (anserion@gmail.com)
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--    http://www.apache.org/licenses/LICENSE-2.0
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.
------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description: investigation of continues and discrete Hopfield neural networks
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_signed.all;

entity Hopfield_top_tb is
end Hopfield_top_tb;

architecture Behavioral of Hopfield_top_tb is

constant n: integer range 0 to 15:=4;
constant cont_bitwide: integer range 0 to 31:=31;
constant discrete_bitwide: integer range 0 to 15:=8;

component hopfield_network_cont is
	generic (n:integer range 0 to 15 := 4; bitwide:integer range 0 to 31:=31);
    Port ( 
		clk        : in std_logic;
      ask        : in std_logic;
      ready      : out std_logic;

		X: in std_logic_vector(n-1 downto 0);
		W: in std_logic_vector(n*bitwide*n-1 downto 0);
		Y: out std_logic_vector(n-1 downto 0)
	);
end component;

component hopfield_network_discrete is
	generic (n:integer range 0 to 15 := 4; bitwide:integer range 0 to 31:=8);
    Port ( 
		clk        : in std_logic;
      ask        : in std_logic;
      ready      : out std_logic;

		X: in std_logic_vector(n-1 downto 0);
		W: in std_logic_vector(n*bitwide*n-1 downto 0);
		Y: out std_logic_vector(n-1 downto 0)		
	 );
end component;

signal hopfield_cont_ask: std_logic:='0';
signal hopfield_cont_ready: std_logic:='0';
signal hopfield_cont_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal hopfield_cont_W: std_logic_vector(n*cont_bitwide*n-1 downto 0):=(others=>'0');
signal hopfield_cont_Y: std_logic_vector(n-1 downto 0):=(others=>'0');

signal hopfield_discrete_ask: std_logic:='0';
signal hopfield_discrete_ready: std_logic:='0';
signal hopfield_discrete_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal hopfield_discrete_W: std_logic_vector(n*discrete_bitwide*n-1 downto 0):=(others=>'0');
signal hopfield_discrete_Y: std_logic_vector(n-1 downto 0):=(others=>'0');

constant clk_period : time := 100 ns;
signal clk: std_logic:='0';

begin
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	hopfield_network_discrete_chip: hopfield_network_discrete
		generic map (n,discrete_bitwide)
		port map (
			clk, hopfield_discrete_ask, hopfield_discrete_ready,
			hopfield_discrete_X, hopfield_discrete_W, hopfield_discrete_Y
		);

	hopfield_network_cont_chip: hopfield_network_cont
		generic map (n,cont_bitwide)
		port map (
			clk, hopfield_cont_ask, hopfield_cont_ready,
			hopfield_cont_X, hopfield_cont_W, hopfield_cont_Y
		);
		
	process (clk)
	variable fsm: integer range 0 to 7:=0;
	begin
		if rising_edge(clk) then
		case fsm is
		when 0=>
			hopfield_cont_ask<='1';
			hopfield_discrete_ask<='1';
			fsm:=1;
		when 1=>
			if (hopfield_cont_ready and hopfield_discrete_ready)='1'
			then hopfield_cont_ask<='0'; hopfield_discrete_ask<='0'; fsm:=2;
			end if;
		when 2=> fsm:=0;
		when others=> null;
		end case;
		end if;
	end process;

end Behavioral;
