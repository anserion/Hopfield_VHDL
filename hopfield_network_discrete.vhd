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
-- Description: vhdl description of discrete Hopfield network
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hopfield_network_discrete is
	 generic (n:integer range 0 to 15 := 4; bitwide:integer range 0 to 31:=9);
    Port ( 
		clk        : in std_logic;
      ask        : in std_logic;
      ready      : out std_logic;
		
		X: in std_logic_vector(n-1 downto 0);
		W: in std_logic_vector(n*bitwide*n-1 downto 0);
		Y: out std_logic_vector(n-1 downto 0)
	 );
end hopfield_network_discrete;

architecture Behavioral of hopfield_network_discrete is

component neuron_discrete is
	generic (n:integer range 0 to 15 := 4; bitwide:integer range 0 to 31:=8);
    Port ( 
		X: in std_logic_vector(n-1 downto 0);
		W: in std_logic_vector(bitwide*n-1 downto 0);
		A: out std_logic
	 );
end component;
signal neurons_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal neurons_A: std_logic_vector(n-1 downto 0):=(others=>'0');

begin

Y<=neurons_A;

neurons:
	for i in 0 to n-1 generate
	begin
		neuron_chip: neuron_discrete
		generic map (n,bitwide)
		port map (neurons_X,	W((i+1)*n*bitwide-1 downto i*n*bitwide), neurons_A(i) );
	end generate;

	process (clk)
	variable fsm: integer range 0 to 3:=0;
	begin
		if rising_edge(clk) then
		case fsm is
		when 0=> if ask='1' then ready<='0'; fsm:=1; end if;
		when 1=> neurons_X<=X; fsm:=2;
		when 2=> neurons_X<=neurons_A; fsm:=3;
		when 3=> ready<='1'; if ask='0' then fsm:=0; end if;
		when others=> null;
		end case;
		end if;
	end process;
end Behavioral;
