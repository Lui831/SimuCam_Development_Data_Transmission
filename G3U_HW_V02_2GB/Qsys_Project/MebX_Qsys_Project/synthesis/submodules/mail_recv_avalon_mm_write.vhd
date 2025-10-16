--------------------------------------------------------------------------------------------------------------------------------------
-- mail_recv_avalon_mm_write.vhd
-- Authors: Luiz H. A. Santos, Pedro A. W. Dian, João P. Fogetti, Rafaella C. Zeron.
-- Date: 30-04-2025
-- Description: this code is responsible for defining the HDL of the Recv Avalon MM Write module.
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

entity mail_recv_avalon_mm_write is

	port(

        -- Input Signals --

        -- Reset and clock signals
		clk_i                   : in  std_logic;
		rst_i                   : in  std_logic;

        -- Avalon MM Interface Input Signals
		mail_avalon_mm_i : in t_mail_recv_write_avalon_mm_from_interface_i;

        -- Output Signals --

        -- Output Signals to the Avalon MM Interface
		mail_avalon_mm_o : out t_mail_recv_write_avalon_mm_to_interface_o;

        -- Output Control Reg for the system
        mail_cntrl_reg_o : out t_mail_recv_write_avalon_mm_to_system_o

	);

end entity mail_recv_avalon_mm_write;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of mail_recv_avalon_mm_write is

	signal s_data_acquired : std_logic;
    signal s_int_wait_request : std_logic;

begin

    -- Process for receiving write requests and writing data
	p_avalon_mm_write : process(clk_i, rst_i) is

        -- Procedure for resetting the regs
        procedure p_reset_reg is
        begin
            -- Resets the control register
            mail_cntrl_reg_o <= c_MAIL_RECV_WRITE_AVALON_MM_CNTRL_REG_RST;
        end procedure p_reset_reg;

        -- Procedure for resetting the data to the FIFO
        procedure p_write_cntrl_regs is
        begin
            -- Writes to the control register
            mail_cntrl_reg_o.proc_rst <= mail_avalon_mm_i.write_data(0);
            mail_cntrl_reg_o.en <= mail_avalon_mm_i.write_data(1);
            mail_cntrl_reg_o.en_irq <= mail_avalon_mm_i.write_data(2);
            mail_cntrl_reg_o.clr_irq <= mail_avalon_mm_i.write_data(3);
        end procedure p_write_cntrl_regs;
     
	begin
		if (rst_i = '1') then
			s_int_wait_request <= '1';
			s_data_acquired                     <= '0';
            p_reset_reg;
		elsif (rising_edge(clk_i)) then

            -- Before every cycle, clears the irq
            mail_cntrl_reg_o.clr_irq <= '0';

			s_int_wait_request <= '1';
			s_data_acquired                     <= '0';

            -- If the Avalon MM interface indicates a write request, process the write operation and asserts the write flag
            if s_data_acquired = '0' then
                if (mail_avalon_mm_i.write = '1') then
                    -- Writes the control register
                    p_write_cntrl_regs;
                    -- Deassert the wait request signal
                    s_int_wait_request <= '0';
                    -- Set the data acquired signal
                    s_data_acquired <= '1';
                end if;
            else
                -- If the data has been acquired, reset the wait request signal
                s_int_wait_request <= '1';
                s_data_acquired    <= '0';
            end if;
		end if;
	end process p_avalon_mm_write;

    -- Assign the output wait request signal
    mail_avalon_mm_o.wait_request <= s_int_wait_request and mail_avalon_mm_i.write;

end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------