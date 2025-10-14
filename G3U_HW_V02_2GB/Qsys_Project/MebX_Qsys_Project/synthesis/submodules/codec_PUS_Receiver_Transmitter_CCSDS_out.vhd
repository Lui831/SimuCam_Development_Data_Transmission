---------------------------------------------------------------------------------------------------------
-- codec_PUS_Receiver_Transmitter_CCSDS_out.vhd
-- Author: Thiago Alves Mendes do Amaral and Luiz Henrique Antoniassi Santos
-- Date: 2024-10-23
-- Description: this document addresses the development of the CCSDS Out module of the PUS Codec, which
-- receives the data from the module and sends it to an output FIFO.
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.codec_PUS_main_pkg.all;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Main module's entity 

entity codec_PUS_Receiver_Transmitter_CCSDS_Out is
    generic (
    
        -- Generic de identificação do canal
        C_PUS_CHANNEL_ID         : integer  := C_CODEC_PUS_NUM_CHANNELS

    );
    port(
    
        -- Input signals --

        -- Clock and rst signals
        clk_i                   : in std_logic;
        rst_sync_i              : in std_logic;

        -- Output FIFO flags
        cPRTCo_outFIFO_full_i        : in std_logic;
        cPRTCo_outFIFO_almost_full_i : in std_logic;
        cPRTCo_outFIFO_txrdy_i       : in std_logic;

        -- Input FIFO data and flags
        cPRTCo_inFIFO_empty_i        : in std_logic;
        cPRTCo_inFIFO_almost_empty_i : in std_logic;
        cPRTCo_inFIFO_rxvalid_i      : in std_logic;
        cPRTCo_inFIFO_data_i         : in t_cPRTCo_inFIFO_data_in;

        -- CRC16CITT module input signals
        cPRTCo_CRC16_crc_i        : in std_logic_vector(c_cPRTCo_CRC16_CRC_WIDTH - 1 downto 0);

        -- Avalon MM input flag and data signals
        cPRTCo_Avalon_MM_wait_request_i : in std_logic;
        cPRTCo_Avalon_MM_response_i     : in std_logic_vector(1 downto 0);
        cPRTCo_Avalon_MM_read_data_i    : in std_logic_vector(c_cPRTCo_AVALON_MM_DATA_WIDTH - 1 downto 0);

        -- Avalon MM DMA configuration signals
        cPRTCo_DMA_start_addr_i   : in std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
        cPRTCo_DMA_num_bytes_i    : in std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
        -- TODO: Ver se esses sinais são necessários em uma implementação futura.

        
        -- Output signals --

        -- Output FIFO data and wr flag
        cPRTCo_outFIFO_data_o  : out std_logic_vector(c_cPRTCo_SPW_DATA_WIDTH - 1 downto 0);
        cPRTCo_outFIFO_flag_o  : out std_logic;
        cPRTCo_outFIFO_wr_en_o : out std_logic;

        -- Input FIFO rd en flag
        cPRTCo_inFIFO_rd_en_o  : out std_logic;

        -- CPR16CITT module output signals
        cPRTCo_CRC16_en_o       : out std_logic;
        cPRTCo_CRC16_rst_sync_o : out std_logic;
        cPRTCo_CRC16_data_o     : out std_logic_vector(c_cPRTCo_CRC16_DATA_WIDTH - 1 downto 0);

        -- Avalon MM output read signals
        cPRTCo_Avalon_MM_addr_o : out std_logic_vector(c_cPRTCo_AVALON_MM_ADDR_WIDTH - 1 downto 0);
        cPRTCo_Avalon_MM_read_o : out std_logic;

        -- CCSDS MEM RST signals
        cPRTCo_CCSDS_rst_o         : out std_logic;
        cPRTCo_CCSDS_rst_value_o   : out std_logic_vector(c_cPRTCo_CCSDS_RST_VALUE_WIDTH - 1 downto 0)

    );

end entity codec_PUS_Receiver_Transmitter_CCSDS_Out;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Module's Architecture

architecture rtl of codec_PUS_Receiver_Transmitter_CCSDS_out is

    -- Register for holding the data received from the Avalon BUS
    signal s_data_reg : std_logic_vector(c_cPRTCo_AVALON_MM_DATA_WIDTH - 1 downto 0) := (others => '0');

    -- Signal for holding the states of the module's state machine
    signal s_cPRTCo_state : t_cPRTCo_states := RESET;

    -- Signal for counting the number of bytes transmitted at each state
    signal s_cPRTCo_state_bytes_count : natural := 0;

    -- Signal for counting the number of app bytes 
    signal s_cPRTCo_Avalon_MM_bytes_count : natural := 0;

    -- Auxiliar byte for verifying if a byte has been transmitted or not
    signal s_byte_transmitted : std_logic := '0';

    -- Signals for verifying if any data has been received from the Avalon MM interface and if a read request has been done already
    signal s_read_request_done        : std_logic := '0';
    signal s_Avalon_MM_read_done      : std_logic := '0';

    -- Signal for obtaining the addresses for the Avalon MM interface
    signal s_cPRTCo_Avalon_MM_addr : unsigned(31 downto 0) := (others => '0');

    -- Auxiliary signal to force a wait cycle
    signal s_wait_cycle : std_logic := '0';

begin

    -- State transition process of the module
    p_cPRTCo_state_transition : process(clk_i, rst_sync_i) is
    begin

        -- If a rising edge of clock is detected
        if rising_edge(clk_i) then

            -- If a rst is detected by the module
            if rst_sync_i = '1' then

                -- Resets all the output signals
                cPRTCo_outFIFO_data_o <= (others => '0');
                cPRTCo_outFIFO_flag_o <= '0';
                cPRTCo_outFIFO_wr_en_o <= '0';

                cPRTCo_inFIFO_rd_en_o <= '0';

                cPRTCo_CRC16_en_o <= '0';
                cPRTCo_CRC16_rst_sync_o <= '1';
                cPRTCo_CRC16_data_o <= (others => '0');

                cPRTCo_Avalon_MM_addr_o <= (others => '0');
                cPRTCo_Avalon_MM_read_o <= '0';

                cPRTCo_CCSDS_rst_o <= '0';
                cPRTCo_CCSDS_rst_value_o <= (others => '0');

                -- Resets all the auxiliary signals
                s_data_reg <= (others => '0');
                s_cPRTCo_Avalon_MM_bytes_count <= 0;
                s_cPRTCo_state_bytes_count <= 0;
                s_Avalon_MM_read_done <= '0';
                s_wait_cycle <= '0';

                -- Transitions the state to RESET
                s_cPRTCo_state <= RESET;




            -- If a RST isn't detected
            else

                -- Case for the module's operation
                case s_cPRTCo_state is

                    -- When in RESET
                    when RESET =>

                        -- Resets all the output signals
                        cPRTCo_outFIFO_data_o <= (others => '0');
                        cPRTCo_outFIFO_flag_o <= '0';
                        cPRTCo_outFIFO_wr_en_o <= '0';

                        cPRTCo_inFIFO_rd_en_o <= '0';

                        cPRTCo_CRC16_en_o <= '0';
                        cPRTCo_CRC16_rst_sync_o <= '1';
                        cPRTCo_CRC16_data_o <= (others => '0');

                        cPRTCo_Avalon_MM_addr_o <= (others => '0');
                        cPRTCo_Avalon_MM_read_o <= '0';

                        cPRTCo_CCSDS_rst_o <= '0';
                        cPRTCo_CCSDS_rst_value_o <= (others => '0');

                        -- Resets all the auxiliary signals
                        s_data_reg <= (others => '0');
                        s_cPRTCo_Avalon_MM_bytes_count <= 0;
                        s_cPRTCo_state_bytes_count <= 0;
                        s_Avalon_MM_read_done <= '0';
                        s_wait_cycle <= '0';

                        -- Transitions the state to IDLE
                        s_cPRTCo_state <= IDLE;


                    -- When in IDLE
                    when IDLE =>

                        -- Deactivates the rst signal for the CRC16 module
                        cPRTCo_CRC16_rst_sync_o <= '0';

                        -- If the input FIFO isn't empty, transitions to TRANSMITING_I
                        if cPRTCo_inFIFO_empty_i = '0' then
                            s_cPRTCo_state <= TRANSMITTING_I;
                        end if;


                    -- When in TRANSMITTING_I
                    when TRANSMITTING_I =>

                        -- Sets the transmitting flag to 0
                        cPRTCo_outFIFO_flag_o <= '0';

                        -- If the output FIFO is ready to receive data and a byte hasn't been transmitted
                        if cPRTCo_outFIFO_txrdy_i = '1' and s_byte_transmitted = '0' then

                            -- Switch case for the number of bytes transmitted in this state
                            case s_cPRTCo_state_bytes_count is

                                -- When transmiting the first byte
                                when 0 =>
                                    cPRTCo_outFIFO_data_o <= c_cPRTCo_PKG_VER_NUM_VAL & c_cPRTCo_PKG_TYPE_VAL & c_cPRTCo_SEC_HDR_FLAG_VAL & cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.apid(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 1 downto c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 3);
                                    cPRTCo_CRC16_data_o <= c_cPRTCo_PKG_VER_NUM_VAL & c_cPRTCo_PKG_TYPE_VAL & c_cPRTCo_SEC_HDR_FLAG_VAL & cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.apid(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 1 downto c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 3);

                                -- When transmitting the second byte
                                when 1 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.apid(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 4 downto 0);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.apid(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 4 downto 0);

                                -- When transmitting the third byte
                                when 2 =>
                                    cPRTCo_outFIFO_data_o <= c_cPRTCo_SEQ_FLAGS_VAL & cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.seq_count(c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 1 downto c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 6);
                                    cPRTCo_CRC16_data_o <= c_cPRTCo_SEQ_FLAGS_VAL & cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.seq_count(c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 1 downto c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 6);

                                -- When transmitting the fourth byte
                                when 3 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.seq_count(c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 7 downto 0);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.seq_count(c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 7 downto 0);

                                -- When transmitting the fifth byte
                                when 4 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 1 downto c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 8);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 1 downto c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 8);

                                -- When transmitting the sixth byte
                                when 5 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 9 downto 0);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 9 downto 0);

                                when others =>
                                    null;

                            end case;

                            -- Enables the wr en flag for the output FIFO, asserts the byte transmitted signal, increases the byte count and enables the CRC16 module
                            cPRTCo_outFIFO_wr_en_o     <= '1';
                            s_byte_transmitted         <= '1';
                            s_cPRTCo_state_bytes_count <= s_cPRTCo_state_bytes_count + 1;
                            cPRTCo_CRC16_en_o          <= '1';

                            -- If the number of bytes transmitted is equal to 6, transitions to TRANSMITTING_II
                            if s_cPRTCo_state_bytes_count = 5 then
                                s_cPRTCo_state_bytes_count <= 0;
                                s_cPRTCo_state <= TRANSMITTING_II;
                            end if;

                        -- If the FIFO isn't ready to receive data, stops
                        else

                            cPRTCo_outFIFO_wr_en_o <= '0';
                            cPRTCo_CRC16_en_o      <= '0';
                            s_byte_transmitted     <= '0';

                        end if;


                    -- When in TRANSMITTING_II
                    when TRANSMITTING_II =>

                        -- Sets the transmitting flag to '0'
                        cPRTCo_outFIFO_flag_o <= '0';

                        -- Initially resets the CRC and the FIFO output
                        cPRTCo_outFIFO_wr_en_o <= '0';
                        cPRTCo_CRC16_en_o      <= '0';

                        -- If the output FIFO is ready to receive data and a byte hasn't been transmitted
                        if cPRTCo_outFIFO_txrdy_i = '1' and s_byte_transmitted = '0' then

                            -- Switch case for the number of bytes transmitted in this state
                            case s_cPRTCo_state_bytes_count is

                                -- When transmiting the first byte
                                when 0 =>
                                    cPRTCo_outFIFO_data_o <= c_cPRTCo_PKG_PUSVNUM_VAL & cPRTCo_inFIFO_data_i.PKG_SEC_HDR.spacecraft_time_ref;
                                    cPRTCo_CRC16_data_o <= c_cPRTCo_PKG_PUSVNUM_VAL & cPRTCo_inFIFO_data_i.PKG_SEC_HDR.spacecraft_time_ref;

                                -- When transmitting the second byte
                                when 1 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.service_id;
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.service_id;

                                -- When transmitting the third byte
                                when 2 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.subservice_id;
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.subservice_id;

                                -- When transmitting the fourth byte
                                when 3 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.msg_type_counter(c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 1 downto c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 8);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.msg_type_counter(c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 1 downto c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 8);

                                -- When transmitting the fifth byte
                                when 4 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.msg_type_counter(c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 9 downto 0);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.msg_type_counter(c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 9 downto 0);

                                -- When transmitting the sixth byte
                                when 5 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.dest_id(c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 1 downto c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 8);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.dest_id(c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 1 downto c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 8);

                                -- When transmiting the seventh byte
                                when 6 =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.dest_id(c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 9 downto 0);
                                    cPRTCo_CRC16_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.dest_id(c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 9 downto 0);

                                -- Transmit each byte of the TIME field, parametrized by c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH
                                when 7 to (7 + (c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH/8) - 1) =>
                                    cPRTCo_outFIFO_data_o <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.time(
                                        c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH - 1 - 8*(s_cPRTCo_state_bytes_count - 7) downto
                                        c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH - 8 - 8*(s_cPRTCo_state_bytes_count - 7)
                                    );
                                    cPRTCo_CRC16_data_o   <= cPRTCo_inFIFO_data_i.PKG_SEC_HDR.time(
                                        c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH - 1 - 8*(s_cPRTCo_state_bytes_count - 7) downto
                                        c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH - 8 - 8*(s_cPRTCo_state_bytes_count - 7)
                                    );
                                    
                                when others =>
                                    null;
                                

                            end case;

                            -- Enables the wr en flag for the output FIFO, asserts the byte transmitted signal and increases the byte count
                            cPRTCo_outFIFO_wr_en_o     <= '1';
                            s_byte_transmitted         <= '1';
                            s_cPRTCo_state_bytes_count <= s_cPRTCo_state_bytes_count + 1;
                            cPRTCo_CRC16_en_o          <= '1';

                            -- If the number of bytes transmitted is equal to 6, transitions to TRANSMITTING_II
                            if s_cPRTCo_state_bytes_count = 6 + (c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH / 8) then
                                s_cPRTCo_state_bytes_count <= 0;

                                -- If there is some App data to be read from the Avalon MM interface
                                if to_integer(unsigned(cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len)) - 9 - (c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH / 8) > 0 then

                                    -- Determines the address offset of the packet
                                    s_cPRTCo_Avalon_MM_addr <= unsigned(cPRTCo_inFIFO_data_i.PKG_addr);

                                    s_cPRTCo_state <= TRANSMITTING_III;
                                else
                                    s_cPRTCo_state <= TRANSMITTING_CRC;
                                end if;
                            end if;

                        -- If the FIFO isn't ready to receive data, stops
                        else

                            cPRTCo_outFIFO_wr_en_o <= '0';
                            cPRTCo_CRC16_en_o      <= '0';
                            s_byte_transmitted     <= '0';

                        end if;


                    -- When in TRANSMITTING_III
                    when TRANSMITTING_III =>

                        -- Sets the transmitting flag to '0'
                        cPRTCo_outFIFO_flag_o <= '0';

                        -- Initially resets the Avalon read, FIFO wr en and CRC
                        cPRTCo_Avalon_MM_read_o <= '0';
                        cPRTCo_outFIFO_wr_en_o <= '0';
                        cPRTCo_CRC16_en_o      <= '0';

                        -- If the application data is none, transitions to TRANSMITTING_CRC
                        if to_integer(unsigned(cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len)) = 11 then

                            -- Transitions to TRANSMITTING_CRC
                            s_cPRTCo_state <= TRANSMITTING_CRC;

                        -- If there hasn't been a read from the Avalon MM before or the number of bytes transmitted equals 4, receives data from the Avalon MM
                        elsif s_cPRTCo_state_bytes_count = 0 and s_Avalon_MM_read_done = '0' then

                            -- If a read request hasnt been done
                            if s_read_request_done = '0' then

                                -- Sets the address and the read signals
                                cPRTCo_Avalon_MM_addr_o <= std_logic_vector(s_cPRTCo_Avalon_MM_addr);
                                cPRTCo_Avalon_MM_read_o <= '1';

                                -- Asserts the s_read_request_done signal
                                s_read_request_done <= '1';

                                -- Increases the addr in Avalon MM, returning to the base address if necessary
                                if s_cPRTCo_Avalon_MM_addr + 4 > unsigned(cPRTCo_DMA_start_addr_i) + unsigned(cPRTCo_DMA_num_bytes_i) - 1 then
                                    s_cPRTCo_Avalon_MM_addr <= unsigned(cPRTCo_DMA_start_addr_i);
                                else
                                    s_cPRTCo_Avalon_MM_addr <= s_cPRTCo_Avalon_MM_addr + 4;
                                end if;
                                
                            -- If a read request has been done
                            else

                                -- If the wait_request signal isn't asserted, reads the data from the Avalon MM
                                if cPRTCo_Avalon_MM_wait_request_i = '0' then

                                    -- Reads the data from the Avalon MM
                                    s_data_reg <= cPRTCo_Avalon_MM_read_data_i;

                                    -- Resets the read request done signal
                                    s_read_request_done <= '0';

                                    -- Sets the avalon read done
                                    s_Avalon_MM_read_done <= '1';

                                -- Else, maintains the read signal up
                                else

                                    cPRTCo_Avalon_MM_read_o <= '1';

                                end if;
                            end if;

                        -- The system needs to transmit data to the output FIFO
                        else

                            -- If the output FIFO is ready to receive data and a byte hasn't been transmitted
                            if ((cPRTCo_outFIFO_txrdy_i = '1' and s_byte_transmitted = '0') and (s_cPRTCo_Avalon_MM_bytes_count + s_cPRTCo_state_bytes_count < to_integer(unsigned(cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len)) - 9 - (c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH / 8))) and s_Avalon_MM_read_done = '1' then

                                -- Switch case for the number of bytes transmitted in this state
                                case s_cPRTCo_state_bytes_count is

                                    -- When transmiting the first byte
                                    when 0 =>
                                        cPRTCo_outFIFO_data_o <= s_data_reg(31 downto 24);
                                        cPRTCo_CRC16_data_o <= s_data_reg(31 downto 24);

                                    -- When transmitting the second byte
                                    when 1 =>
                                        cPRTCo_outFIFO_data_o <= s_data_reg(23 downto 16);
                                        cPRTCo_CRC16_data_o <= s_data_reg(23 downto 16);

                                    -- When transmitting the third byte
                                    when 2 =>
                                        cPRTCo_outFIFO_data_o <= s_data_reg(15 downto 8);
                                        cPRTCo_CRC16_data_o <= s_data_reg(15 downto 8);

                                    -- When transmitting the fourth byte
                                    when 3 =>
                                        cPRTCo_outFIFO_data_o <= s_data_reg(7 downto 0);
                                        cPRTCo_CRC16_data_o <= s_data_reg(7 downto 0);

                                    when others =>
                                        null;

                                end case;

                                -- Enables the wr en flag for the output FIFO, asserts the byte transmitted signal and increases the byte count
                                cPRTCo_outFIFO_wr_en_o         <= '1';
                                s_byte_transmitted             <= '1';
                                s_cPRTCo_state_bytes_count     <= s_cPRTCo_state_bytes_count + 1;
                                cPRTCo_CRC16_en_o              <= '1';

                                -- If the number of bytes transmitted is equal to 3, resets its value, updates the value of the Avalon MM and resets the Avalon Read done signal
                                if s_cPRTCo_state_bytes_count = 3 then
                                    s_cPRTCo_state_bytes_count <= 0;
                                    s_cPRTCo_Avalon_MM_bytes_count <= s_cPRTCo_Avalon_MM_bytes_count + 4;
                                    s_Avalon_MM_read_done <= '0';
                                end if;

                                -- If the maximum number of bytes has been reached, transitions to the TRANSMITING_CRC state
                                if s_cPRTCo_Avalon_MM_bytes_count + s_cPRTCo_state_bytes_count >= to_integer(unsigned(cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len)) - 10 - (c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH / 8) then

                                    -- Resets the byte count
                                    s_cPRTCo_state_bytes_count <= 0;

                                    s_cPRTCo_state <= TRANSMITTING_CRC;
                                    
                                end if;

                            -- If the FIFO isn't ready to receive data, stops
                            else

                                cPRTCo_outFIFO_wr_en_o <= '0';
                                cPRTCo_CRC16_en_o      <= '0';
                                s_byte_transmitted     <= '0';

                            end if;
                        end if;


                    -- When in TRANSMITTING_CRC, transmiting also an EOP
                    when TRANSMITTING_CRC =>

                        -- If condition for waiting a cycle
                        if s_wait_cycle = '1' then

                            -- Initially resets the CRC and the FIFO output
                            cPRTCo_outFIFO_wr_en_o <= '0';
                            cPRTCo_CRC16_en_o      <= '0';

                            -- Resets the wr en flag for the output FIFO
                            cPRTCo_outFIFO_wr_en_o <= '0';

                            -- Stores the calculated CRC value into the register
                            s_data_reg <= X"0000" & cPRTCo_CRC16_crc_i;

                            -- If the output FIFO is ready to receive data and a byte hasn't been transmitted
                            if cPRTCo_outFIFO_txrdy_i = '1' and s_byte_transmitted = '0' then

                                -- Switch case for the number of bytes transmitted in this state
                                case s_cPRTCo_state_bytes_count is

                                    -- When transmiting the first byte
                                    when 0 =>
                                        cPRTCo_outFIFO_flag_o <= '0';
                                        cPRTCo_outFIFO_data_o <= s_data_reg(c_cPRTCo_CRC16_CRC_WIDTH - 1 downto c_cPRTCo_CRC16_CRC_WIDTH - 8);
                                        
                                    -- When transmitting the second byte
                                    when 1 =>
                                        cPRTCo_outFIFO_flag_o <= '0';
                                        cPRTCo_outFIFO_data_o <= s_data_reg(c_cPRTCo_CRC16_CRC_WIDTH - 9 downto 0);

                                    -- When transmitting the EOP
                                    when 2 =>
                                        cPRTCo_outFIFO_flag_o <= '1';
                                        cPRTCo_outFIFO_data_o <= X"00";


                                    when others =>
                                        null;

                                end case;

                                -- Enables the wr en flag for the output FIFO, asserts the byte transmitted signal and increases the byte count
                                cPRTCo_outFIFO_wr_en_o <= '1';
                                s_byte_transmitted     <= '1';
                                s_cPRTCo_state_bytes_count <= s_cPRTCo_state_bytes_count + 1;

                                -- If the number of bytes transmitted is equal to 2, transitions to RESTART, resets the counter, sets the rst values and finally reads the input FIFO
                                if s_cPRTCo_state_bytes_count = 2 then

                                    s_cPRTCo_state_bytes_count <= 0;
                                    s_cPRTCo_state <= RESTART;

                                    -- Sets the rst values
                                    cPRTCo_CCSDS_rst_o <= '1';
                                    cPRTCo_CCSDS_rst_value_o <= x"0000" & std_logic_vector(unsigned(cPRTCo_inFIFO_data_i.PKG_PRIM_HDR.pkg_data_len) - 9 - (c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH / 8));

                                    -- Reads the input FIFO
                                    cPRTCo_inFIFO_rd_en_o <= '1';

                                end if;

                            -- If the FIFO isn't ready to receive data, stops
                            else

                                cPRTCo_outFIFO_wr_en_o <= '0';
                                s_byte_transmitted     <= '0';

                            end if;

                        -- Waits a cycle
                        else

                            -- Sets the wait cycle signal
                            s_wait_cycle <= '1';

                            -- Resets the wr en flag for the output FIFO
                            cPRTCo_outFIFO_wr_en_o <= '0';

                            -- Resets the CRC16 module
                            cPRTCo_CRC16_en_o <= '0';
                            cPRTCo_CRC16_rst_sync_o <= '0';
                            cPRTCo_CRC16_data_o <= (others => '0');

                        end if;

                    -- When in RESTART
                    when RESTART =>

                        -- Resets the output FIFO
                        cPRTCo_outFIFO_data_o <= (others => '0');
                        cPRTCo_outFIFO_wr_en_o <= '0';

                        -- Resets the input FIFO
                        cPRTCo_inFIFO_rd_en_o <= '0';

                        -- Resets the CRC16 module
                        cPRTCo_CRC16_en_o <= '0';
                        cPRTCo_CRC16_rst_sync_o <= '1';
                        cPRTCo_CRC16_data_o <= (others => '0');

                        -- Resets the Avalon MM interface
                        cPRTCo_Avalon_MM_addr_o <= (others => '0');
                        cPRTCo_Avalon_MM_read_o <= '0';

                        -- Resets the CCSDS RST signals
                        cPRTCo_CCSDS_rst_o <= '0';
                        cPRTCo_CCSDS_rst_value_o <= (others => '0');

                        -- Resets the auxiliary signals
                        s_data_reg <= (others => '0');
                        s_cPRTCo_Avalon_MM_bytes_count <= 0;
                        s_Avalon_MM_read_done <= '0';
                        s_cPRTCo_state_bytes_count <= 0;
                        s_wait_cycle <= '0';

                        -- Transitions the state to IDLE
                        s_cPRTCo_state <= IDLE;

                end case;
            end if;

        end if;
    end process p_cPRTCo_state_transition;

end architecture rtl;
    




