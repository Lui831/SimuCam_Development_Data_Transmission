--------------------------------------------------------------------------------------------------------------------------------------
-- mailbox_top.vhd
-- Authors: Luiz H. A. Santos, Pedro A. W. Dian, João P. Fogetti, Rafaella C. Zeron.
-- Date: 30-04-2025
-- Description: this code is responsible for defining mailbox top HDL.
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

entity mail_mailbox is

    generic(
        -- Mailbox FIFO size
        c_MAIL_FIFO_SIZE : integer := 255
    );

    port(

        -- Input Signals --

        -- Reset and clock signals
        reset : in  std_logic;
        clock : in  std_logic;

        -- Recv Avalon MM Interface Input Signals
        mail_recv_avalon_mm_write_i : in std_logic;
        mail_recv_avalon_mm_read_i  : in std_logic;
        mail_recv_avalon_mm_address_i : in std_logic_vector(c_MAIL_AVALON_MM_ADDR_WIDTH - 1 downto 0);
        mail_recv_avalon_mm_write_data_i : in std_logic_vector(c_MAIL_AVALON_MM_DATA_WIDTH - 1 downto 0);

        -- Send Avalon MM Interface Input Signals
        mail_send_avalon_mm_write_i : in std_logic;
        mail_send_avalon_mm_read_i  : in std_logic;
        mail_send_avalon_mm_address_i : in std_logic_vector(c_MAIL_AVALON_MM_ADDR_WIDTH - 1 downto 0);
        mail_send_avalon_mm_write_data_i : in std_logic_vector(c_MAIL_AVALON_MM_DATA_WIDTH - 1 downto 0);

        -- Output Signals --

        -- Recv Avalon MM Output Interface
        mail_recv_avalon_mm_wait_request_o : out std_logic;
        mail_recv_avalon_mm_read_data_o : out std_logic_vector(c_MAIL_AVALON_MM_DATA_WIDTH - 1 downto 0);

        -- Send Avalon MM Output Interface
        mail_send_avalon_mm_wait_request_o : out std_logic;
        mail_send_avalon_mm_read_data_o : out std_logic_vector(c_MAIL_AVALON_MM_DATA_WIDTH - 1 downto 0);

        -- IRQ signal for receiving data
        mail_recv_irq_o : out std_logic

    );

end entity mail_mailbox;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of mail_mailbox is

    -- Signals for interconnecting the modules

    -- Signals for interconnecting the Avalon Interface to the Send Avalon MM Write Module
    signal s_mail_send_avalon_mm_write_to_interface : t_mail_send_write_avalon_mm_to_interface_o;
    signal s_mail_send_avalon_mm_write_from_interface : t_mail_send_write_avalon_mm_from_interface_i;

    -- Signals for interconnecting the Avalon Interface to the Send Avalon MM Read Module
    signal s_mail_send_avalon_mm_read_to_interface : t_mail_send_read_avalon_mm_to_inteface_o;
    signal s_mail_send_avalon_mm_read_from_interface : t_mail_send_read_avalon_mm_from_inteface_i;

    -- Signals for interconnecting the Avalon Interface to the Recv Avalon MM Write Module
    signal s_mail_recv_avalon_mm_write_to_interface : t_mail_recv_write_avalon_mm_to_interface_o;
    signal s_mail_recv_avalon_mm_write_from_interface : t_mail_recv_write_avalon_mm_from_interface_i;

    -- Signals for interconnecting the Avalon Interface to the Recv Avalon MM Read Module
    signal s_mail_recv_avalon_mm_read_to_interface : t_mail_recv_read_avalon_mm_to_inteface_o;
    signal s_mail_recv_avalon_mm_read_from_interface : t_mail_recv_read_avalon_mm_from_inteface_i;

    -- Signals for interconnecting the FIFO to the Avalon MM Modules
    signal s_mail_fifo_to_avalon_mm_read : t_mail_fifo_to_avalon_mm_read;
    signal s_mail_fifo_to_avalon_mm_write : t_mail_fifo_to_avalon_mm_write;
    signal s_mail_fifo_from_avalon_mm_read : t_mail_fifo_from_avalon_mm_read;
    signal s_mail_fifo_from_avalon_mm_write : t_mail_fifo_from_avalon_mm_write;

    -- Signal for interconnecting the cntrl register to the recv avalon mm write module
    signal s_mail_recv_cntrl_reg : t_mail_recv_write_avalon_mm_to_system_o;

    -- Signal for controlling the IRQ
    signal s_mail_recv_irq : std_logic := '0';

    -- Signal for acquiring the last status from the FIFO (regarding empty)
    signal s_mail_last_empty_fifo : std_logic := '0';

    -- Signal for the FIFO rst
    signal s_mail_fifo_rst : std_logic := '0';

begin

    -- Instantiates the Recv Avalon MM Write Module
    e_recv_avalon_mm_write : entity work.mail_recv_avalon_mm_write
        port map(
            clk_i            => clock,
            rst_i            => reset,
            mail_avalon_mm_i => s_mail_recv_avalon_mm_write_from_interface,
            mail_avalon_mm_o => s_mail_recv_avalon_mm_write_to_interface,
            mail_cntrl_reg_o => s_mail_recv_cntrl_reg
        );

    -- Instantiates the Recv Avalon MM Read Module
    e_recv_avalon_mm_read : entity work.mail_recv_avalon_mm_read
        port map(
            clk_i            => clock,
		    rst_i            => reset,
            mail_avalon_mm_i => s_mail_recv_avalon_mm_read_from_interface,
            mail_fifo_i      => s_mail_fifo_to_avalon_mm_read,
            mail_cntrl_reg_i => s_mail_recv_cntrl_reg,
            mail_fifo_o      => s_mail_fifo_from_avalon_mm_read,
            mail_avalon_mm_o => s_mail_recv_avalon_mm_read_to_interface
        );

    -- Instantiates the Send Avalon MM Write Module
    e_send_avalon_mm_write : entity work.mail_send_avalon_mm_write
        port map(
            clk_i            => clock,
            rst_i            => reset,
            mail_avalon_mm_i => s_mail_send_avalon_mm_write_from_interface,
            mail_fifo_i      => s_mail_fifo_to_avalon_mm_write,
            mail_avalon_mm_o => s_mail_send_avalon_mm_write_to_interface,
            mail_fifo_o      => s_mail_fifo_from_avalon_mm_write
        );
    
    -- Instantiates the Send Avalon MM Read Module
    e_send_avalon_mm_read : entity work.mail_send_avalon_mm_read
        port map(
        clk_i            => clock,
        rst_i            => reset,
        mail_avalon_mm_i => s_mail_send_avalon_mm_read_from_interface,
        mail_fifo_i      => s_mail_fifo_to_avalon_mm_read,
        mail_avalon_mm_o => s_mail_send_avalon_mm_read_to_interface
        );

    -- Instantiates the Mailbox FIFO Module
    e_mail_fifo : entity work.mail_fifo
        generic map(
            c_FIFO_DEPTH => c_MAIL_FIFO_SIZE
        )
        port map(
            clk_i                   => clock,
            rst_i                   => s_mail_fifo_rst,
            en_i                    => s_mail_recv_cntrl_reg.en,
            mail_avalon_mm_read_i   => s_mail_fifo_from_avalon_mm_read,
            mail_avalon_mm_write_i  => s_mail_fifo_from_avalon_mm_write,
            mail_avalon_mm_read_o   => s_mail_fifo_to_avalon_mm_read,
            mail_avalon_mm_write_o  => s_mail_fifo_to_avalon_mm_write
        );
    
    -- Process for controlling the IRQ signal
    p_mail_recv_irq : process(clock, reset) is
    begin
        if reset = '1' or s_mail_recv_cntrl_reg.proc_rst = '1' then
            s_mail_recv_irq <= '0';
            s_mail_last_empty_fifo <= '1';
        elsif rising_edge(clock) then

            -- Updates the last empty FIFO status
            s_mail_last_empty_fifo <= s_mail_fifo_to_avalon_mm_read.empty;

            if s_mail_recv_cntrl_reg.en_irq = '1' then
                -- Detect low edge transition of the FIFO empty signal
                if s_mail_fifo_to_avalon_mm_read.empty = '0' and s_mail_last_empty_fifo = '1' then
                    s_mail_recv_irq <= '1';
                end if;
                if s_mail_recv_irq = '1' and s_mail_recv_cntrl_reg.clr_irq = '1' then
                    s_mail_recv_irq <= '0';
                end if;
            else
                s_mail_recv_irq <= '0';
            end if;
        end if;
    end process p_mail_recv_irq;

    -- Interconnects the IRQ signal to the output port
    mail_recv_irq_o <= s_mail_recv_irq;

    -- Interconnects the FIFO rst signal to the output port
    s_mail_fifo_rst <= reset or s_mail_recv_cntrl_reg.proc_rst;

    -- Interconnects the Avalon MM Write signals to the relevant signals
    s_mail_send_avalon_mm_write_from_interface.write_data <= mail_send_avalon_mm_write_data_i;
    s_mail_send_avalon_mm_write_from_interface.address <= mail_send_avalon_mm_address_i;
    s_mail_send_avalon_mm_write_from_interface.write <= mail_send_avalon_mm_write_i;

    s_mail_recv_avalon_mm_write_from_interface.write_data <= mail_recv_avalon_mm_write_data_i;
    s_mail_recv_avalon_mm_write_from_interface.address <= mail_recv_avalon_mm_address_i;
    s_mail_recv_avalon_mm_write_from_interface.write <= mail_recv_avalon_mm_write_i;

    -- Interconnects the Avalon MM Read signals to the relevant signals
    s_mail_send_avalon_mm_read_from_interface.read <= mail_send_avalon_mm_read_i;
    s_mail_send_avalon_mm_read_from_interface.address <= mail_send_avalon_mm_address_i;
    
    mail_send_avalon_mm_read_data_o <= s_mail_send_avalon_mm_read_to_interface.read_data;

    s_mail_recv_avalon_mm_read_from_interface.read <= mail_recv_avalon_mm_read_i;
    s_mail_recv_avalon_mm_read_from_interface.address <= mail_recv_avalon_mm_address_i;

    mail_recv_avalon_mm_read_data_o <= s_mail_recv_avalon_mm_read_to_interface.read_data;

    -- Interconnects the Avalon MM Wait Request signals
    mail_recv_avalon_mm_wait_request_o <= s_mail_recv_avalon_mm_write_to_interface.wait_request or s_mail_recv_avalon_mm_read_to_interface.wait_request;
    mail_send_avalon_mm_wait_request_o <= s_mail_send_avalon_mm_write_to_interface.wait_request or s_mail_send_avalon_mm_read_to_interface.wait_request;

    


end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------