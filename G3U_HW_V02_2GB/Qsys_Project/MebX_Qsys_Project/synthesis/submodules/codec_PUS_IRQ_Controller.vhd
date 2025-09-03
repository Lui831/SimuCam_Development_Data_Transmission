---------------------------------------------------------------------------------------------------------
-- codec_PUS_IRQ_Controller.vhd
-- Author: Luiz H. A. Santos and Thiago A. M. Amaral
-- Date: 23-05-2025
-- Description: this document addresses the development of the FIFO out module of the codec Pus
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.codec_PUS_main_pkg.all;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Entity instantiation

entity codec_PUS_IRQ_Controller is

    port(

        -- Input Signals --
        clk_i      : in std_logic;
        rst_sync_i : in std_logic;

        -- Input Signals from the Controller
        cPIC_controller_wr_regs_i          : in t_codec_PUS_wr_regs;
        cPIC_controller_recv_IRQ_trigger_i : in std_logic;
        cPIC_controller_send_IRQ_trigger_i : in std_logic;

        -- Output Signals --

        -- Output IRQ Signals to the Avalon IRQ interface
        cPIC_avalon_IRQ_recv_IRQ_o : out std_logic;
        cPIC_avalon_IRQ_send_IRQ_o : out std_logic

    );

end entity codec_PUS_IRQ_Controller;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of codec_PUS_IRQ_Controller is

    -- Signals for storing the status of each of the IRQs
    signal s_IRQ_recv : std_logic := '0';
    signal s_IRQ_send : std_logic := '0';

begin

    -- Main process for the IRQ Controller
    p_IRQ_Controller : process(clk_i, rst_sync_i) is
    begin

        -- If a rising edge of clock is detected
        if rising_edge(clk_i) then

            -- If a rst sync is detected or if the IRQs are disabled
            if rst_sync_i = '1' or cPIC_controller_wr_regs_i.control_reg.irq_en = '0' then

                -- Resets all the signals
                s_IRQ_recv <= '0';
                s_IRQ_send <= '0';

            -- If the module is in it's normal operation and the IRQs are enabled
            else

                -- If the recv IRQ is enabled
                if cPIC_controller_wr_regs_i.control_reg.recv_irq_en = '1' then

                    -- If the recv IRQ trigger is set and the signal is not set
                    if cPIC_controller_recv_IRQ_trigger_i = '1' and s_IRQ_recv = '0' then

                        -- Set the recv IRQ signal
                        s_IRQ_recv <= '1';

                    end if;

                    -- If the IRQ signal is set and the processor sets the irq clr, resets it
                    if s_IRQ_recv = '1' and cPIC_controller_wr_regs_i.handling.irq_rcv_clr = '1' then

                        -- Reset the recv IRQ signal
                        s_IRQ_recv <= '0';

                    end if;

                end if;

                -- If the send IRQ is enabled
                if cPIC_controller_wr_regs_i.control_reg.send_irq_en = '1' then

                    -- If the send IRQ trigger is set and the signal is not set
                    if cPIC_controller_send_IRQ_trigger_i = '1' and s_IRQ_send = '0' then

                        -- Set the send IRQ signal
                        s_IRQ_send <= '1';

                    end if;

                    -- If the IRQ signal is set and the processor sets the irq clr, resets it
                    if s_IRQ_send = '1' and cPIC_controller_wr_regs_i.handling.irq_send_clr = '1' then

                        -- Reset the send IRQ signal
                        s_IRQ_send <= '0';

                    end if;

                end if;
            end if;
        end if;

    end process p_IRQ_Controller;

    -- Assigns values to the output signals
    cPIC_avalon_IRQ_recv_IRQ_o <= s_IRQ_recv;
    cPIC_avalon_IRQ_send_IRQ_o <= s_IRQ_send;

end architecture rtl;

---------------------------------------------------------------------------------------------------------