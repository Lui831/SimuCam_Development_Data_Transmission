--------------------------------------------------------------------------------------------------------------------------------------
-- mail_fifo.vhd
-- Authors: Luiz H. A. Santos, Pedro A. W. Dian, João P. Fogetti, Rafaella C. Zeron.
-- Date: 30/04/2025
-- Description: this code is responsible for defining the HDL of mailbox fifo module
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

entity mail_fifo is

    generic(
        -- FIFO size
        c_FIFO_DEPTH : integer := c_MAIL_FIFO_SIZE
    );

	port(

        -- Input Signals --

        -- Reset, clock and en signals
		clk_i                   : in  std_logic;
		rst_i                   : in  std_logic;
        en_i                    : in  std_logic;

        -- Input Signals from the Avalon MM Read Module
        mail_avalon_mm_read_i : in t_mail_fifo_from_avalon_mm_read;

        -- Input Signals from the Avalon MM Write Module
        mail_avalon_mm_write_i : in t_mail_fifo_from_avalon_mm_write;


        -- Output Signals --

        -- Output Signals to the Avalon MM Read Module
        mail_avalon_mm_read_o : out t_mail_fifo_to_avalon_mm_read;

        -- Output Signals to the Avalon MM Write Module
        mail_avalon_mm_write_o : out t_mail_fifo_to_avalon_mm_write

	);

end entity mail_fifo;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of mail_fifo is

    -- Signals for holding the pointers for guiding the FIFO and its size
	signal s_fifo_begin_ptr : natural range 0 to c_FIFO_DEPTH - 1;
    signal s_fifo_end_ptr   : natural range 0 to c_FIFO_DEPTH - 1;
    signal s_fifo_size     : natural range 0 to c_FIFO_DEPTH;

    -- Signals for holding the FIFO data
    signal s_fifo_data : t_mail_fifo_data_array := c_MAIL_FIFO_DATA_RST; -- FIFO data

    -- Signal for estabilishing a write and read valid
    signal s_fifo_write_done : std_logic := '0';
    signal s_fifo_read_done  : std_logic := '0';

begin

    -- FIFO main process
    p_fifo_main_process : process(clk_i, rst_i) is
    begin

        -- If a rising edge of clock is detected
        if rising_edge(clk_i) then

            -- If the rst is active
            if rst_i = '1' then

                -- Reset the FIFO pointers and its size
                s_fifo_begin_ptr <= 0;
                s_fifo_end_ptr   <= 0;
                s_fifo_size      <= 0;

                -- Resets the write and read done signals
                s_fifo_write_done <= '0';
                s_fifo_read_done  <= '0';

                -- Resets the FIFO data
                s_fifo_data <= c_MAIL_FIFO_DATA_RST;

            -- If the module is in its normal operation
            else

                -- Updates the FIFO current data
                mail_avalon_mm_read_o.rd_data <= s_fifo_data(s_fifo_begin_ptr);

                -- If a wr is detected and the FIFO is not full
                if ((mail_avalon_mm_write_i.wr_en = '1' and s_fifo_size < c_FIFO_DEPTH) and s_fifo_write_done = '0') and en_i = '1' then
                    
                    -- Write the data into the FIFO
                    s_fifo_data(s_fifo_end_ptr) <= mail_avalon_mm_write_i.write_data;

                    -- Update the FIFO pointers and its size
                    s_fifo_end_ptr <= (s_fifo_end_ptr + 1) mod c_FIFO_DEPTH;
                    s_fifo_size    <= s_fifo_size + 1;

                    -- Set the write done signal
                    s_fifo_write_done <= '1';

                else
                    
                    -- Reset the write done signal
                    s_fifo_write_done <= '0';

                end if;

                -- If a rd is detected and the FIFO is not empty
                if ((mail_avalon_mm_read_i.rd_en = '1' and s_fifo_size > 0) and s_fifo_read_done = '0') and en_i = '1' then

                    -- Read the data from the FIFO
                    mail_avalon_mm_read_o.rd_data <= s_fifo_data(s_fifo_begin_ptr);

                    -- Update the FIFO pointers and its size
                    s_fifo_begin_ptr <= (s_fifo_begin_ptr + 1) mod c_FIFO_DEPTH;
                    s_fifo_size      <= s_fifo_size - 1;

                    -- Set the read done signal
                    s_fifo_read_done <= '1';

                else

                    -- Reset the read done signal
                    s_fifo_read_done <= '0';

                end if;
            end if;
        end if;
    end process p_fifo_main_process;

    -- Output signals assignment
    mail_avalon_mm_read_o.empty <= '1' when s_fifo_size = 0 else '0';
    mail_avalon_mm_read_o.full  <= '1' when s_fifo_size = c_FIFO_DEPTH else '0';
    mail_avalon_mm_read_o.msg_num <= std_logic_vector(to_unsigned(s_fifo_size, c_MAIL_MESSAGE_NUM_WIDTH));
    mail_avalon_mm_read_o.rxvalid <= '1' when (not s_fifo_read_done = '1') and (s_fifo_size > 0) else '0';
    
    mail_avalon_mm_write_o.full <= '1' when s_fifo_size = c_FIFO_DEPTH else '0';
    mail_avalon_mm_write_o.txvalid <= '1' when (not s_fifo_write_done = '1') and (s_fifo_size < c_FIFO_DEPTH) else '0';

end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------