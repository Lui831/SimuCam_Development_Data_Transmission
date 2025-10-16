--------------------------------------------------------------------------------------------------------------------------------------
-- mail_send_avalon_mm_write.vhd
-- Authors: Luiz H. A. Santos, Pedro A. W. Dian, João P. Fogetti, Rafaella C. Zeron.
-- Date: 30-04-2025
-- Description: this code is responsible for defining the HDL of the Send Avalon MM Write module.
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

entity mail_send_avalon_mm_write is

	port(

        -- Input Signals --

        -- Reset and clock signals
		clk_i                   : in  std_logic;
		rst_i                   : in  std_logic;

        -- Avalon MM Interface Input Signals
		mail_avalon_mm_i : in t_mail_send_write_avalon_mm_from_interface_i;

        -- Input Signals from the FIFO
        mail_fifo_i : in t_mail_send_write_avalon_mm_from_fifo_i;

        -- Output Signals --

        -- Output Signals to the Avalon MM Interface
		mail_avalon_mm_o : out t_mail_send_write_avalon_mm_to_interface_o;

        -- Output signals to the FIFO
		mail_fifo_o   : out t_mail_send_write_avalon_mm_to_fifo_o

	);

end entity mail_send_avalon_mm_write;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of mail_send_avalon_mm_write is

	signal s_data_acquired : std_logic;
    signal s_int_wait_request : std_logic;

begin

    -- Process for receiving write requests and writing data
	p_avalon_mm_write : process(clk_i, rst_i) is

        -- Procedure for resetting the data to the FIFO
        procedure p_reset_fifo is
        begin
            -- Resets the FIFO data
            mail_fifo_o.write_data <= (others => '0');
            mail_fifo_o.wr_en <= '0';
        end procedure p_reset_fifo;
     
        -- Procedure for writing data to the FIFO
		procedure p_write_wr_fifo is
		begin
            -- Writes the message data to the FIFO
            mail_fifo_o.write_data <= mail_avalon_mm_i.write_data;
            mail_fifo_o.wr_en <= '1';
            
		end procedure p_write_wr_fifo;

	begin
		if (rst_i = '1') then
			s_int_wait_request <= '1';
			s_data_acquired                     <= '0';
            p_reset_fifo;
		elsif (rising_edge(clk_i)) then
			s_int_wait_request <= '1';
			s_data_acquired                     <= '0';

            -- If the Avalon MM interface indicates a write request, process the write operation and asserts the write flag
            if s_data_acquired = '0' then
                if (mail_avalon_mm_i.write = '1') then
                    -- If the FIFO is prepared to receive data
                    if (mail_fifo_i.full = '0' and mail_fifo_i.txvalid = '1') then
                        -- Write the data to the FIFO
                        p_write_wr_fifo;
                        s_int_wait_request <= '0';
                        s_data_acquired    <= '1';
                    -- If the FIFO is full, just not executes the write operation
                    elsif (mail_fifo_i.full = '1') then
                        p_reset_fifo;
                        s_data_acquired    <= '1';
                        s_int_wait_request <= '0';
                    else
                        -- If the FIFO is not ready, reset the write request signal
                        p_reset_fifo;
                        s_int_wait_request <= '1';
                    end if;
                end if;
            else
                -- If the data has been acquired, reset the wait request signal
                s_int_wait_request <= '1';
                s_data_acquired    <= '0';
                p_reset_fifo;
            end if;
		end if;
	end process p_avalon_mm_write;

    -- Assign the output wait request signal
    mail_avalon_mm_o.wait_request <= s_int_wait_request and mail_avalon_mm_i.write;

end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------