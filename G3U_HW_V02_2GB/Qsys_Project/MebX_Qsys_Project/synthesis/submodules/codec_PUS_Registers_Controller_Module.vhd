---------------------------------------------------------------------------------------------------------
-- codec_Register_Module_Control.vhd
-- Author: Luiz H. A. Santos and Thiago A. M. do Amaral
-- Date: 2025-05-21
-- Description: this file contains the main entity and behaviour definition of the Registers Controller Module.
---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
-- Libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.codec_PUS_main_pkg.all;

---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
-- Entity

entity codec_PUS_Registers_Controller_Module is

    port(

        -- Input Signals --

        -- Reset and clock signals
        clk_i                              : in std_logic;
        rst_sync_i                         : in std_logic;

        -- Input Header FIFO signals
        cPRCM_input_hdr_fifo_data_i         : in t_cPFi_FIFO_data;
        cPRCM_input_hdr_fifo_rxrdy_i        : in std_logic;
        cPRCM_input_hdr_fifo_empty_i        : in std_logic;
        cPRCM_input_hdr_fifo_almost_empty_i : in std_logic;

        -- Output Header FIFO signals
        cPRCM_output_hdr_fifo_txrdy_i       : in std_logic;
        cPRCM_output_hdr_fifo_full_i        : in std_logic;
        cPRCM_output_hdr_fifo_almost_full_i : in std_logic;

        -- Agent Write signals
        cPRCM_agent_write_wr_regs_i : in t_codec_PUS_wr_regs;
        cPRCM_agent_write_wr_flag_i : in std_logic;

        -- CCSDS out signals
        cPRCM_CCSDS_out_rst_i : in std_logic;


        -- Output Signals --

        -- Input Header FIFO signals
        cPRCM_input_hdr_fifo_rd_en_o : out std_logic;

        -- Output Header FIFO signals
        cPRCM_output_hdr_fifo_wr_en_o : out std_logic;
        cPRCM_output_hdr_fifo_data_o  : out t_cPFo_FIFO_data;

        -- Agent Read signals
        cPRCM_avalon_read_rd_regs_o : out t_codec_PUS_rd_regs;

        -- Agent Write signals
        cPRCM_agent_write_wr_regs_o : out t_codec_PUS_wr_regs;

        -- IRQ Controller signals
        cPRCM_IRQ_controller_wr_regs_o          : out t_codec_PUS_wr_regs;
        cPRCM_IRQ_controller_recv_IRQ_trigger_o : out std_logic;
        cPRCM_IRQ_controller_send_IRQ_trigger_o : out std_logic;

        -- CCSDS in signals
        cPRCM_CCSDS_in_rst_o        : out std_logic;
        cPRCM_CCSDS_in_rst_value_o  : out std_logic_vector(c_CPRCM_RST_VALUE_WIDTH - 1 downto 0);
        cPRCM_CCSDS_in_mem_offset_o : out std_logic_vector(c_CPRCM_MEM_OFFSET_WIDTH - 1 downto 0);
        cPRCM_CCSDS_in_fifo_size_o  : out std_logic_vector(c_CPRCM_FIFO_SIZE_WIDTH - 1 downto 0);

        -- CCSDS out signals
        cPRCM_CCSDS_out_mem_offset_o : out std_logic_vector(c_CPRCM_MEM_OFFSET_WIDTH - 1 downto 0);
        cPRCM_CCSDS_out_fifo_size_o  : out std_logic_vector(c_CPRCM_FIFO_SIZE_WIDTH - 1 downto 0);

        -- General reset signal for the inner parts of the Codec PUS
        cPRCM_gen_proc_rst_o         : out std_logic
                                    
       
    );

end entity codec_PUS_Registers_Controller_Module;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Architecture

architecture rtl of codec_PUS_Registers_Controller_Module is

    -- Initialize holding values for the wr and read registers
    signal s_rd_regs : t_codec_PUS_rd_regs;
    signal s_wr_regs : t_codec_PUS_wr_regs;

    -- Auxiliary signal for marking the data send for the output hdr fifo
    signal s_data_sent_to_output_hdr_fifo : std_logic := '0';

    -- Auxiliary signal for marking the data recv for the processor, and auxiliary signal for the rd regs information
    signal s_data_recv_from_input_hdr_fifo : std_logic := '0';
    signal s_aux_rd_regs : t_codec_PUS_rd_regs;

    -- Auxiliary memory signal for holding if the Input Header FIFO was empty
    signal s_input_hdr_fifo_was_empty : std_logic := '0';

    -- Auxiliary signals for holding the values of the wr_regs for each of the processes
    signal s_aux1_wr_regs : t_codec_PUS_wr_regs;
    signal s_aux2_wr_regs : t_codec_PUS_wr_regs;
    signal s_aux3_wr_regs : t_codec_PUS_wr_regs;


begin

-- Process to send informations to the output_hdr_fifo, based on the registers
p_info_to_output_hdr_fifo: process (clk_i, rst_sync_i) is 
    begin
        
        -- If a rising edge of clock is identified
        if rising_edge(clk_i) then

            -- If a reset signal is identified
            if rst_sync_i = '1' then

                -- Reset the wr and data signals to the output hdr fifo
                cPRCM_output_hdr_fifo_wr_en_o <= '0';
                cPRCM_output_hdr_fifo_data_o <= C_cPRTCo_inFIFO_data_in_reset;

                -- Resets the auxiliary signal
                s_data_sent_to_output_hdr_fifo <= '0';

                -- Resets the auxiliary wr regs
                s_aux1_wr_regs.handling.data_send_wr_flag <= '1';

            -- Normal module operation
            else

                -- If the processor sinalizes to write data to the module
                if s_wr_regs.handling.data_send_wr_flag = '1' and s_wr_regs.control_reg.en = '1' and s_wr_regs.control_reg.send_en = '1' then

                    -- Verify if the FIFO is ready to receive data
                    if cPRCM_output_hdr_fifo_txrdy_i = '1' and cPRCM_output_hdr_fifo_full_i = '0' and s_data_sent_to_output_hdr_fifo = '0' then

                        -- Set the wr enable signal to '1' to write data
                        cPRCM_output_hdr_fifo_wr_en_o <= '1';

                        -- Designate the register signals to the output data
                        cPRCM_output_hdr_fifo_data_o.PKG_PRIM_HDR.apid <= s_wr_regs.send_PKG_PRIM_HDR1.apid;
                        cPRCM_output_hdr_fifo_data_o.PKG_PRIM_HDR.pkg_data_len <= s_wr_regs.send_PKG_PRIM_HDR1.pkg_data_len;
                        cPRCM_output_hdr_fifo_data_o.PKG_PRIM_HDR.seq_count <= s_wr_regs.send_PKG_PRIM_HDR2.seq_count;
                        cPRCM_output_hdr_fifo_data_o.PKG_SEC_HDR.spacecraft_time_ref <= s_wr_regs.send_PKG_SEC_HDR1.spacecraft_time_ref;
                        cPRCM_output_hdr_fifo_data_o.PKG_SEC_HDR.service_id <= s_wr_regs.send_PKG_SEC_HDR1.service_id;
                        cPRCM_output_hdr_fifo_data_o.PKG_SEC_HDR.subservice_id <= s_wr_regs.send_PKG_SEC_HDR1.subservice_id;
                        cPRCM_output_hdr_fifo_data_o.PKG_SEC_HDR.msg_type_counter <= s_wr_regs.send_PKG_SEC_HDR2.msg_type_counter;
                        cPRCM_output_hdr_fifo_data_o.PKG_SEC_HDR.dest_id <= s_wr_regs.send_PKG_SEC_HDR2.dest_id;
                        cPRCM_output_hdr_fifo_data_o.PKG_SEC_HDR.time <= s_wr_regs.send_PKG_SEC_HDR3.time;
                        cPRCM_output_hdr_fifo_data_o.pkg_addr <= s_wr_regs.send_pkg_addr.pkg_addr;

                        -- Updates the send rdy flag to 0
                        s_aux1_wr_regs.handling.data_send_wr_flag <= '0';

                        -- Set the auxiliary signal to indicate data was sent
                        s_data_sent_to_output_hdr_fifo <= '1';

                    else

                        -- Deasserts the auxiliary signal
                        s_data_sent_to_output_hdr_fifo <= '0';

                        -- Deactivates the wr signal
                        cPRCM_output_hdr_fifo_wr_en_o <= '0';

                        -- If the FIFO is full, deasserts the wr enable signal
                        s_aux1_wr_regs.handling.data_send_wr_flag <= '1';

                    end if;

                -- If the processor doesn't sinalize a packet to be written
                else

                    -- Deasserts the auxiliary signal
                    s_data_sent_to_output_hdr_fifo <= '0';

                    -- Deactivates the wr signal
                    cPRCM_output_hdr_fifo_wr_en_o <= '0';

                    -- If the FIFO is full, deasserts the wr enable signal
                    s_aux1_wr_regs.handling.data_send_wr_flag <= '1';

                end if;
            end if;
        end if;

    end process p_info_to_output_hdr_fifo;
    
-- Process to store information into the registers, based on the input header FIFO
p_info_to_registers: process (clk_i, rst_sync_i) is 
    begin
        
        -- If a rising edge of clock is identified
        if rising_edge(clk_i) then

            -- If a rst signal is identified
            if rst_sync_i = '1' then

                -- Resets the auxiliary signals
                s_data_recv_from_input_hdr_fifo <= '0';

                -- Reset the aux rd regs
                s_aux_rd_regs <= c_CODEC_PUS_RD_REGS_RST;

                -- Asserts the rd flag
                s_aux2_wr_regs.handling.data_rcv_rd_flag <= '1';

            -- Normal operation
            else

                -- Always updates the data from the read registers based on the FIFO
                s_aux_rd_regs.recv_PKG_PRIM_HDR1.apid <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.apid;
                s_aux_rd_regs.recv_PKG_PRIM_HDR1.pkg_type <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.pkg_type;
                s_aux_rd_regs.recv_PKG_PRIM_HDR1.sec_hdr_flag <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.sec_hdr_flag;
                s_aux_rd_regs.recv_PKG_PRIM_HDR1.pkg_vernum <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.pkg_vernum;
                s_aux_rd_regs.recv_PKG_PRIM_HDR1.seq_count <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.seq_count;
                s_aux_rd_regs.recv_PKG_PRIM_HDR1.seq_flags <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.seq_flags;

                s_aux_rd_regs.recv_PKG_PRIM_HDR2.pkg_data_len <= cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.pkg_data_len;

                s_aux_rd_regs.recv_PKG_SEC_HDR1.ack_flags <= cPRCM_input_hdr_fifo_data_i.PKG_SEC_HDR.ack_flags;
                s_aux_rd_regs.recv_PKG_SEC_HDR1.pusvnum <= cPRCM_input_hdr_fifo_data_i.PKG_SEC_HDR.pusvnum;
                s_aux_rd_regs.recv_PKG_SEC_HDR1.service_id <= cPRCM_input_hdr_fifo_data_i.PKG_SEC_HDR.service_id;
                s_aux_rd_regs.recv_PKG_SEC_HDR1.subservice_id <= cPRCM_input_hdr_fifo_data_i.PKG_SEC_HDR.subservice_id;

                s_aux_rd_regs.recv_PKG_SEC_HDR2.source_id <= cPRCM_input_hdr_fifo_data_i.PKG_SEC_HDR.source_id;

                s_aux_rd_regs.recv_pkg_addr.pkg_addr <= cPRCM_input_hdr_fifo_data_i.pkg_addr;

                s_aux_rd_regs.recv_status.status_flags <= cPRCM_input_hdr_fifo_data_i.status_flags.ver_flags;

                -- If the rcv rdy flag is enabled and the receiving is enabled
                if s_wr_regs.handling.data_rcv_rd_flag = '1' and s_wr_regs.control_reg.en = '1' and s_wr_regs.control_reg.recv_en = '1' then

                    -- If the FIFO is not empty and ready to receive data
                    if cPRCM_input_hdr_fifo_empty_i = '0' and cPRCM_input_hdr_fifo_rxrdy_i = '1' and s_data_recv_from_input_hdr_fifo = '0' then

                        -- Set the rd enable signal to '1' to read data
                        cPRCM_input_hdr_fifo_rd_en_o <= '1';

                        -- Deasserts the rd flag
                        s_aux2_wr_regs.handling.data_rcv_rd_flag <= '0';

                        -- Set the auxiliary signal to indicate data was received
                        s_data_recv_from_input_hdr_fifo <= '1';

                    else

                        -- Deactivates the rd enable signal
                        cPRCM_input_hdr_fifo_rd_en_o <= '0';

                        -- Deasserts the auxiliary signal
                        s_data_recv_from_input_hdr_fifo <= '0';

                        -- asserts the rd flag
                        s_aux2_wr_regs.handling.data_rcv_rd_flag <= '1';

                    end if;

                -- If the processor doesn't sinalize receive operations
                else

                    -- Deactivates the rd enable signal
                    cPRCM_input_hdr_fifo_rd_en_o <= '0';

                    -- Deasserts the auxiliary signal
                    s_data_recv_from_input_hdr_fifo <= '0';

                    -- asserts the rd flag
                    s_aux2_wr_regs.handling.data_rcv_rd_flag <= '1';

                end if;
            end if;
        end if;
    end process p_info_to_registers;
     
-- Process to trigger the IRQ controller based on the registers and FIFOs
p_IRQ_trigger: process(clk_i, rst_sync_i) is
begin

    -- If a rising edge of clock is detected
    if rising_edge(clk_i) then

        -- If a reset signal is detected
        if rst_sync_i = '1' then

            -- Resets the IRQ controller trigger signals
            cPRCM_IRQ_controller_recv_IRQ_trigger_o <= '0';
            cPRCM_IRQ_controller_send_IRQ_trigger_o <= '0';

        -- Normal operation
        else

            -- Interconnnects the rst signal coming from the CCSDS Out module directly to send IRQ trigger
            cPRCM_IRQ_controller_send_IRQ_trigger_o <= cPRCM_CCSDS_out_rst_i;

            -- Initially resets the recv IRQ trigger
            cPRCM_IRQ_controller_recv_IRQ_trigger_o <= '0';

            -- Emmits a recv trigger if the FIFO was empty and now it is not
            if cPRCM_input_hdr_fifo_empty_i = '0' and s_input_hdr_fifo_was_empty = '1' then

                -- Sets the recv IRQ trigger signal
                cPRCM_IRQ_controller_recv_IRQ_trigger_o <= '1';

                -- Updates the auxiliary signal to indicate the FIFO is not empty anymore
                s_input_hdr_fifo_was_empty <= '0';

            -- If the FIFO is empty, updates the auxiliary signal
            elsif cPRCM_input_hdr_fifo_empty_i = '1' then

                -- Updates the auxiliary signal to indicate the FIFO is empty
                s_input_hdr_fifo_was_empty <= '1';

                -- Resets the recv IRQ trigger signal
                cPRCM_IRQ_controller_recv_IRQ_trigger_o <= '0';

            end if;
        end if;
    end if;
end process p_IRQ_trigger;


-- Process for determining the memory reset for the CCSDS In module
p_CCSDS_in_mem_rst: process(clk_i, rst_sync_i) is
begin

    -- If a risign edge of clock is detected
    if rising_edge(clk_i) then

        -- If a rst signal is detected
        if rst_sync_i = '1' then

            -- Resets the rst signal and value for the CCSDS In module
            cPRCM_CCSDS_in_rst_o <= '0';
            cPRCM_CCSDS_in_rst_value_o <= (others => '0');

        -- Normal operation
        else

            -- Normally resets the rst bit
            cPRCM_CCSDS_in_rst_o <= '0';

            -- If a rd signal is detected from the processor, rsts the mem value based on the PKG addr of the first item in the FIFO
            if s_wr_regs.handling.data_rcv_rd_flag = '1' and s_wr_regs.control_reg.en = '1' and s_wr_regs.control_reg.recv_en = '1'
            and cPRCM_input_hdr_fifo_empty_i = '0' and cPRCM_input_hdr_fifo_rxrdy_i = '1' and s_data_recv_from_input_hdr_fifo = '0' then

                -- Sets the rst value to the PKG addr of the first item in the FIFO
                cPRCM_CCSDS_in_rst_value_o <= std_logic_vector(to_unsigned((to_integer(unsigned(cPRCM_input_hdr_fifo_data_i.PKG_PRIM_HDR.pkg_data_len)) - 7), c_CPRCM_RST_VALUE_WIDTH));

                -- Sets the rst bit to '1' to indicate a reset is needed
                cPRCM_CCSDS_in_rst_o <= '1';

            else

                -- Sets the rst value to the default value
                cPRCM_CCSDS_in_rst_value_o <= (others => '0');

            end if;
    
        end if;
    end if;
end process p_CCSDS_in_mem_rst;


-- Process for determining the memory reset coming from the CCSDS out
p_CCSDS_out_mem_rst: process(clk_i, rst_sync_i) is
begin

    -- If a rising edge of clock is detected
    if rising_edge(clk_i) then

        -- If the rst signal is detected
        if rst_sync_i = '1' then

            -- Resets the success flags
            s_aux3_wr_regs.handling.data_send_success_flags <= x"00";

        -- Normal operation
        else

            -- If the CCSDS Out signal pulses something, increases the success flag counter on the registers
            if cPRCM_CCSDS_out_rst_i = '1' then

                -- Increments the success flag counter
                s_aux3_wr_regs.handling.data_send_success_flags <= std_logic_vector(unsigned(s_aux3_wr_regs.handling.data_send_success_flags) + 1);

                -- If the counter reaches the maximum value, resets it
                if s_wr_regs.handling.data_send_success_flags = x"FF" then
                    s_aux3_wr_regs.handling.data_send_success_flags <= x"00";
                end if;

            end if;
        end if;
    end if;

end process p_CCSDS_out_mem_rst;

-- Process to handle the agent write signals and update the registers accordingly
p_agent_write: process(clk_i, rst_sync_i) is
begin

    -- Verifies if there is a rising edge of the clock
    if rising_edge(clk_i) then

        -- If a reset signal is detected
        if rst_sync_i = '1' then

            -- Resets the wr registers
            s_wr_regs <= c_CODEC_PUS_WR_REGS_RST;

        -- Normal operation
        else

            -- Always sets the irq clr signals to '0'
            s_wr_regs.handling.irq_rcv_clr <= '0';
            s_wr_regs.handling.irq_send_clr <= '0';

            -- Updates the bits updates by the other processes
            s_wr_regs.handling.data_send_wr_flag <= s_aux1_wr_regs.handling.data_send_wr_flag and s_wr_regs.handling.data_send_wr_flag;
            s_wr_regs.handling.data_rcv_rd_flag <= s_aux2_wr_regs.handling.data_rcv_rd_flag and s_wr_regs.handling.data_rcv_rd_flag;
            s_wr_regs.handling.data_send_success_flags <= s_aux3_wr_regs.handling.data_send_success_flags;

            -- If the agent write signal is enabled
            if cPRCM_agent_write_wr_flag_i = '1' then

                -- Updates the wr registers with the data from the agent write input
                s_wr_regs <= cPRCM_agent_write_wr_regs_i;

            end if;

        end if;
    end if;
end process p_agent_write;

-- Process to set the informations and bits regarding the read registers
p_read_regs_handle: process(clk_i, rst_sync_i) is
begin

    -- Verifies if there is a rising edge of the clock
    if rising_edge(clk_i) then

        -- Verifies if a reset signal is detected
        if rst_sync_i = '1' then

            -- Resets the read registers
            s_rd_regs <= c_CODEC_PUS_RD_REGS_RST;

        -- Normal operation
        else

            -- Updates the info regs with the aux reg
            s_rd_regs.recv_PKG_PRIM_HDR1 <= s_aux_rd_regs.recv_PKG_PRIM_HDR1;
            s_rd_regs.recv_PKG_PRIM_HDR2 <= s_aux_rd_regs.recv_PKG_PRIM_HDR2;
            s_rd_regs.recv_PKG_SEC_HDR1 <= s_aux_rd_regs.recv_PKG_SEC_HDR1;
            s_rd_regs.recv_PKG_SEC_HDR2 <= s_aux_rd_regs.recv_PKG_SEC_HDR2;
            s_rd_regs.recv_pkg_addr <= s_aux_rd_regs.recv_pkg_addr;
            s_rd_regs.recv_status <= s_aux_rd_regs.recv_status;

            -- Updates the rd regs with the information from the wr regs
            s_rd_regs.control_reg <= s_wr_regs.control_reg;
            s_rd_regs.send_pkg_addr <= s_wr_regs.send_pkg_addr;
            s_rd_regs.send_PKG_PRIM_HDR1 <= s_wr_regs.send_PKG_PRIM_HDR1;
            s_rd_regs.send_PKG_PRIM_HDR2 <= s_wr_regs.send_PKG_PRIM_HDR2;
            s_rd_regs.send_PKG_SEC_HDR1 <= s_wr_regs.send_PKG_SEC_HDR1;
            s_rd_regs.send_PKG_SEC_HDR2 <= s_wr_regs.send_PKG_SEC_HDR2;
            s_rd_regs.send_PKG_SEC_HDR3 <= s_wr_regs.send_PKG_SEC_HDR3;
            s_rd_regs.handling <= s_wr_regs.handling;
            s_rd_regs.recv_mem_offset <= s_wr_regs.recv_mem_offset;
            s_rd_regs.recv_fifo_size <= s_wr_regs.recv_fifo_size;
            s_rd_regs.send_mem_offset <= s_wr_regs.send_mem_offset;
            s_rd_regs.send_fifo_size <= s_wr_regs.send_fifo_size;

            -- If the Input Header FIFO is not empty and data is ready to be received, sets the recv rdy flag
            if cPRCM_input_hdr_fifo_empty_i = '0' and cPRCM_input_hdr_fifo_rxrdy_i = '1' then
                -- Sets the recv rdy flag to '1'
                s_rd_regs.handling.data_rcv_rdy_flag <= '1';
            else
                -- Resets the recv rdy flag to '0'
                s_rd_regs.handling.data_rcv_rdy_flag <= '0';
            end if;

            -- If the Output Header FIFO is not full and data can be sent, sets the send rdy flag
            if cPRCM_output_hdr_fifo_full_i = '0' and cPRCM_output_hdr_fifo_txrdy_i = '1' then
                -- Sets the send rdy flag to '1'
                s_rd_regs.handling.data_send_rdy_flag <= '1';
            else
                -- Resets the send rdy flag to '0'
                s_rd_regs.handling.data_send_rdy_flag <= '0';
            end if;
            
        end if;
    end if;

end process p_read_regs_handle;

-- Assigns the read registers to the IRQ controller and Agent read
cPRCM_IRQ_controller_wr_regs_o <= s_wr_regs;
cPRCM_avalon_read_rd_regs_o <= s_rd_regs;

-- Assigns the wr registers to the Agent write
cPRCM_agent_write_wr_regs_o <= s_wr_regs;

-- Assigns the mem offset and fifo size to the CCSDS In and Out modules
cPRCM_CCSDS_in_mem_offset_o <= s_wr_regs.recv_mem_offset.mem_offset;
cPRCM_CCSDS_in_fifo_size_o <= s_wr_regs.recv_fifo_size.fifo_size;

cPRCM_CCSDS_out_mem_offset_o <= s_wr_regs.send_mem_offset.mem_offset;
cPRCM_CCSDS_out_fifo_size_o <= s_wr_regs.send_fifo_size.fifo_size;

-- Assigns the general processing reset signal
cPRCM_gen_proc_rst_o <= s_wr_regs.control_reg.proc_rst;

end architecture rtl;