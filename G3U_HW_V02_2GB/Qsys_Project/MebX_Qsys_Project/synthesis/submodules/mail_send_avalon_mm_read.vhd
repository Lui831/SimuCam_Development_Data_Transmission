--------------------------------------------------------------------------------------------------------------------------------------
-- mail_avalon_mm_read.vhd
-- Authors: Luiz H. A. Santos, Pedro A. W. Dian, João P. Fogetti, Rafaella C. Zeron.
-- Date: 30-04-2025
-- Description: this code is responsible for defining the HDL of the Avalon MM Read module.
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Important libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mail_main_pkg.all;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Entity declaration

entity mail_send_avalon_mm_read is

	port(

        -- Input Signals --

        -- Reset and clock signals
		clk_i                   : in  std_logic;
		rst_i                   : in  std_logic;

        -- Avalon MM Interface Input Signals
		mail_avalon_mm_i : in t_mail_send_read_avalon_mm_from_inteface_i;

		-- Input signals from the FIFO
		mail_fifo_i : in t_mail_send_read_avalon_mm_from_fifo_i;

        -- Output Signals --

        -- Avalon MM Interface Output Signals
		mail_avalon_mm_o : out t_mail_send_read_avalon_mm_to_inteface_o

	);

end entity mail_send_avalon_mm_read;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of mail_send_avalon_mm_read is

	signal s_data_acquired : std_logic;
	signal s_int_wait_request : std_logic;

begin

    -- Process for receiving write requests and writing data
	p_avalon_mm_read : process(clk_i, rst_i) is

		procedure p_read_all_registers is
		begin
            -- Puts the empty and full flags
			mail_avalon_mm_o.read_data(0) <= mail_fifo_i.empty;
			mail_avalon_mm_o.read_data(1) <= mail_fifo_i.full;
			-- 16 bits para o message num
			mail_avalon_mm_o.read_data(17 downto 2) <= mail_fifo_i.msg_num;
		end procedure p_read_all_registers;

	begin
		if (rst_i = '1') then
			mail_avalon_mm_o.read_data    <= (others => '0');
			s_int_wait_request <= '1';
			s_data_acquired <= '0';

		elsif (rising_edge(clk_i)) then
			mail_avalon_mm_o.read_data    <= (others => '0');
			s_data_acquired <= '0';
			s_int_wait_request <= '1';

			if s_data_acquired = '0' then
				
				if (mail_avalon_mm_i.read = '1') then
					s_int_wait_request <= '0';
					s_data_acquired <= '1';
					p_read_all_registers;
				end if;

			else

				s_int_wait_request <= '1';
				s_data_acquired <= '0';

			end if;
			
		end if;
	end process p_avalon_mm_read;

	-- Assign the wait request signal, based on the internal wait request and the read signal
	mail_avalon_mm_o.wait_request <= s_int_wait_request and mail_avalon_mm_i.read;

end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------