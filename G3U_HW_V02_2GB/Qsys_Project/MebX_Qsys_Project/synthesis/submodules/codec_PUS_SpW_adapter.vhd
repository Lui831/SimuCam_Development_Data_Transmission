----------------------------------------------------------------------------------------------------
-- codec_PUS_SpW_adapter.vhd
-- Author: Thiago Alves Mendes do Amaral and Luiz Henrique Antoniassi Santos
-- Date: 2025-10-05
-- Description: this file defines the base structure for the codec_PUS_SpW_adapter module.
--              It serves as the interface layer between the codec_PUS core and the SpaceWire system.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.codec_PUS_main_pkg.all;

----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Entity Declaration

entity codec_PUS_SpW_adapter is
    port(

        -- Input Signals --

        -- Clock and Reset
        clk_i        : in  std_logic;  -- Global clock
        rst_sync_i   : in  std_logic;   -- Global synchronous reset (active high)

        -- Input signals from the CCSDS In module
        cPSa_CCSDS_in_rd_en_i : in std_logic;

        -- Input signals from the CCSDS Out module
        cPSa_CCSDS_out_data_i    : in std_logic_vector(c_cPSA_CCSDS_DATA_WIDTH - 1 downto 0);
        cPSa_CCSDS_out_end_pkg_i : in std_logic;
        cPSa_CCSDS_out_wr_en_i   : in std_logic;

        -- Input signals from the Registers and Controller Module
        cPSa_controller_SpW_node_ADDR_i : in std_logic_vector(c_cPSA_SpW_ADDR_WIDTH - 1 downto 0);

        -- Input signals from the OUT SpW ADDR FIFO module
        cPSa_OUT_SpW_ADDR_FIFO_full_i        : in std_logic;
        cPSa_OUT_SpW_ADDR_FIFO_almost_full_i : in std_logic;
        cPSa_OUT_SpW_ADDR_FIFO_txrdy_i       : in std_logic;

        -- Input signals from the IN SpW ADDR FIFO module
        cPSa_IN_SpW_ADDR_FIFO_data_i         : in t_cPSAF_FIFO_data;
        cPSa_IN_SpW_ADDR_FIFO_rxvalid_i      : in std_logic;
        cPSa_IN_SpW_ADDR_FIFO_empty_i        : in std_logic;
        cPSa_IN_SpW_ADDR_FIFO_almost_empty_i : in std_logic;

        -- Input signals from the SpW Connecter module
        cPSa_SpW_connecter_data_in_i         : in std_logic_vector(c_cPSA_SpW_DATA_WIDTH - 1 downto 0);
        cPSA_SpW_connecter_flag_in_i         : in std_logic;
        cPSA_SpW_connecter_empty_in_i        : in std_logic;
        cPSA_SpW_connecter_almost_empty_in_i : in std_logic;
        cPSA_SpW_connecter_rxvalid_in_i      : in std_logic;

        cPSa_SpW_connecter_full_out_i        : in std_logic;
        cPSa_SpW_connecter_almost_full_out_i : in std_logic;
        cPSa_SpW_connecter_txrdy_out_i       : in std_logic;



        -- Output Signals --

        -- Output signals to the CCSDS In module
        cPSa_CCSDS_in_data_o         : out std_logic_vector(c_cPSA_CCSDS_DATA_WIDTH - 1 downto 0);
        cPSa_CCSDS_in_end_pkg_o      : out std_logic;
        cPSA_CCSDS_in_rxvalid_o      : out std_logic;
        cPSa_CCSDS_in_empty_o        : out std_logic;
        cPSa_CCSDS_in_almost_empty_o : out std_logic;

        -- Output signals to the CCSDS Out module
        cPSa_CCSDS_out_full_o        : out std_logic;
        cPSa_CCSDS_out_almost_full_o : out std_logic;
        cPSa_CCSDS_out_txrdy_o       : out std_logic;

        -- Output signals to the OUT SpW ADDR FIFO module
        cPSa_OUT_SpW_ADDR_FIFO_data_o   : out t_cPSAF_FIFO_data;
        cPSa_OUT_SpW_ADDR_FIFO_wr_en_o  : out std_logic;

        -- Output signals to the IN SpW ADDR FIFO module
        cPSa_IN_SpW_ADDR_FIFO_rd_en_o : out std_logic;

        -- Output signals from the SpW connecter module]
        cPSa_SpW_connecter_rd_en_in_o : out std_logic;

        cPSa_SpW_connecter_data_out_o  : out std_logic_vector(c_cPSA_SpW_DATA_WIDTH - 1 downto 0);
        cPSa_SpW_connecter_flag_out_o  : out std_logic;
        cPSa_SpW_connecter_wr_en_out_o : out std_logic

    );
end entity codec_PUS_SpW_adapter;

----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Architecture Definition

architecture rtl of codec_PUS_SpW_adapter is

    -- Signal for the internal state machine of the SpW to PUS receiving process
    signal s_receiving_SpW_to_PUS_state : t_cPSa_SpW_to_PUS_states := RESET;
    signal s_receiving_received_SpW_addr : std_logic_vector(c_cPSA_SpW_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s_receiving_byte_transfered : std_logic := '0';
    signal s_receiving_bytes_count : integer range 0 to 6 := 0;
    signal s_receiving_status_vector : std_logic_vector(c_cPSA_STATUS_WIDTH - 1 downto 0) := (others => '0');
    signal s_receiving_SpW_connecter_process_rd_en : std_logic := '0';
    
    -- Signal for the internal state machine of the PUS to SpW transmitting process
    signal s_transfering_PUS_to_SpW_state : t_cPSa_PUS_to_SpW_states := RESET;
    signal s_transfering_bytes_count : integer range 0 to 6 := 0;
    signal s_transfering_byte_transfered : std_logic := '0';
    signal s_transfering_SpW_connecter_process_wr_en : std_logic := '0';
    signal s_transfering_SpW_connecter_process_data : std_logic_vector(c_cPSA_SpW_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_transfering_first_CCSDS_byte : std_logic_vector(c_cPSA_CCSDS_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_transfering_sending_SpW_addr : std_logic_vector(c_cPSA_SpW_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s_transfering_first_CCSDS_byte_sent : std_logic := '0';

begin

    -- Process for handling the SpW to PUS data reception
    p_SpW_to_PUS_process : process(clk_i, rst_sync_i) is
    begin

        if rising_edge(clk_i) then
            
            if rst_sync_i = '1' then
                
                -- Reset all the signals of the process
                s_receiving_SpW_to_PUS_state <= RESET;

                -- Reset the signals for the OUT SpW ADDR FIFO module
                cPSa_OUT_SpW_ADDR_FIFO_data_o  <= c_cPSA_FIFO_data_reset;
                cPSa_OUT_SpW_ADDR_FIFO_wr_en_o <= '0';

                -- Reset internal signals
                s_receiving_received_SpW_addr <= (others => '0');
                s_receiving_byte_transfered    <= '0';
                s_receiving_bytes_count       <= 0;
                s_receiving_status_vector    <= (others => '0');
                s_receiving_SpW_connecter_process_rd_en <= '0';

            else

                -- As a default, the wr_en, rd_en and rxvalid signals are set to low
                s_receiving_SpW_connecter_process_rd_en <= '0';
                cPSa_OUT_SpW_ADDR_FIFO_wr_en_o          <= '0';

                -- Machine state
                case s_receiving_SpW_to_PUS_state is

                    -- RESET state: resets all the signals and transitions to the IDLE state
                    when RESET =>

                        -- Resets all the signals of the process
                        s_receiving_SpW_to_PUS_state <= IDLE;

                        -- Resets the signals for the OUT SpW ADDR FIFO module
                        cPSa_OUT_SpW_ADDR_FIFO_data_o  <= c_cPSA_FIFO_data_reset;
                        cPSa_OUT_SpW_ADDR_FIFO_wr_en_o <= '0';

                        -- Resets internal signals
                        s_receiving_received_SpW_addr <= (others => '0');
                        s_receiving_byte_transfered    <= '0';
                        s_receiving_bytes_count       <= 0;
                        s_receiving_status_vector    <= (others => '0');
                        s_receiving_SpW_connecter_process_rd_en <= '0';


                    -- IDLE state: waits for data from the SpW Connecter module to start receiving a packet
                    when IDLE =>

                        if (cPSA_SpW_connecter_empty_in_i = '0' and cPSA_SpW_connecter_rxvalid_in_i = '1') and (cPSa_OUT_SpW_ADDR_FIFO_full_i = '0' and cPSa_OUT_SpW_ADDR_FIFO_txrdy_i = '1') then
                            
                            -- Transitions to the RECEIVING_HDR state, getting the SpW address and storing it into the FIFO
                            s_receiving_SpW_to_PUS_state <= RECEIVING_HDR;

                        end if;


                    -- RECEIVING_HDR state: receives the SpW Headerss
                    when RECEIVING_HDR =>

                        -- If the SpW connecter is ready to send data and a byte hasn't been transfered yet
                        if cPSA_SpW_connecter_rxvalid_in_i = '1' and s_receiving_byte_transfered = '0' then

                            -- Switch case for the number of bytes transmitted in this state
                            case s_receiving_bytes_count is

                                -- Receives the SpW ADDR, veryfing if it is valid
                                when 0 =>

                                    -- If the SpW ADDR dont match the controller SpW node ADDR, sets the error flag in the status vector
                                    if cPSa_SpW_connecter_data_in_i /= cPSa_controller_SpW_node_ADDR_i then
                                        s_receiving_status_vector <= f_spw_status_to_std_logic_vector_mask(s_receiving_status_vector, ADDR_ERROR);
                                    end if;

                                    -- Updates SPW ADDR
                                    s_receiving_received_SpW_addr <= cPSa_SpW_connecter_data_in_i;

                                -- Receives the Protocol ID, veryfing if it is valid
                                when 1 =>

                                    -- If the Protocol ID is different from 0, sets the error flag in the status vector
                                    if cPSa_SpW_connecter_data_in_i /= c_cPSA_PROTOCOL_ID_PUS then
                                        s_receiving_status_vector <= f_spw_status_to_std_logic_vector_mask(s_receiving_status_vector, PROTOCOL_ID_ERROR);
                                    end if;

                                when others =>
                                    null;

                            end case;

                            -- Enables the wr en flag for the output FIFO, and asserts the byte transfered signal
                            s_receiving_SpW_connecter_process_rd_en <= '1';
                            s_receiving_byte_transfered             <= '1';
                            s_receiving_bytes_count                 <= s_receiving_bytes_count + 1;


                        -- If the FIFO isn't ready to receive data, stops
                        else

                            s_receiving_SpW_connecter_process_rd_en <= '0';
                            s_receiving_byte_transfered             <= '0';

                            -- If the number of bytes transmitted is equal to 6, transitions to RECEIVING CCSDS and writes the received data to the FIFO
                            if s_receiving_bytes_count = 4 then

                                s_receiving_bytes_count      <= 0;
                                s_receiving_SpW_to_PUS_state <= RECEIVING_CCSDS;

                                -- Writes the received SpW ADDR and status to the output FIFO
                                cPSa_OUT_SpW_ADDR_FIFO_data_o  <= (spw_addr => s_receiving_received_SpW_addr, spw_status => s_receiving_status_vector);
                                cPSa_OUT_SpW_ADDR_FIFO_wr_en_o <= '1';
                                s_receiving_status_vector      <= (others => '0');
                                s_receiving_received_SpW_addr  <= (others => '0');

                            end if;

                        end if;

                    when RECEIVING_CCSDS =>

                        -- If a flag indicating the end of the packet is received from the CCSDS In module, go to the IDLE state
                        if cPSA_SpW_connecter_flag_in_i = '1' and cPSa_CCSDS_in_rd_en_i = '1' then

                            s_receiving_SpW_to_PUS_state <= IDLE;

                            -- Resets the internal signals
                            s_receiving_byte_transfered    <= '0';
                            s_receiving_bytes_count       <= 0;
                            s_receiving_status_vector    <= (others => '0');
                            s_receiving_received_SpW_addr <= (others => '0');

                        end if;
                end case;
            end if;
        end if;

    end process p_SpW_to_PUS_process;

    -- Buffer for connecting the SpW connecter to the CCSDS In module
    cPSA_CCSDS_in_rxvalid_o <= cPSA_SpW_connecter_rxvalid_in_i when s_receiving_SpW_to_PUS_state = RECEIVING_CCSDS else '0';
    cPSa_CCSDS_in_empty_o   <= cPSA_SpW_connecter_empty_in_i  when s_receiving_SpW_to_PUS_state = RECEIVING_CCSDS else '1';
    cPSa_CCSDS_in_almost_empty_o <= cPSA_SpW_connecter_almost_empty_in_i when s_receiving_SpW_to_PUS_state = RECEIVING_CCSDS else '1';
    cPSa_CCSDS_in_data_o    <= cPSa_SpW_connecter_data_in_i  when s_receiving_SpW_to_PUS_state = RECEIVING_CCSDS else (others => '0');
    cPSa_CCSDS_in_end_pkg_o <= cPSA_SpW_connecter_flag_in_i  when s_receiving_SpW_to_PUS_state = RECEIVING_CCSDS else '0';

    with s_receiving_SpW_to_PUS_state select

        cPSa_SpW_connecter_rd_en_in_o <= s_receiving_SpW_connecter_process_rd_en when RECEIVING_HDR,
                                         cPSa_CCSDS_in_rd_en_i                   when RECEIVING_CCSDS,
                                         '0'                                     when others;


    -- Process for handling the PUS to SpW data transmission
    p_PUS_to_SpW_process : process(clk_i, rst_sync_i) is
    begin

        if rising_edge(clk_i) then
            
            if rst_sync_i = '1' then
                
                -- Reset all the signals of the process
                s_transfering_PUS_to_SpW_state <= RESET;

                -- Reset the signals for the IN SpW ADDR FIFO module
                cPSa_IN_SpW_ADDR_FIFO_rd_en_o <= '0';

                -- Reset internal signals
                s_transfering_bytes_count      <= 0;
                s_transfering_byte_transfered  <= '0';
                s_transfering_SpW_connecter_process_wr_en <= '0';
                s_transfering_first_CCSDS_byte <= (others => '0');
                s_transfering_sending_SpW_addr <= (others => '0');
                s_transfering_SpW_connecter_process_data <= (others => '0');
                s_transfering_first_CCSDS_byte_sent <= '0';

            else

                -- As a default, the wr_en, rd_en and rxvalid signals are set to low
                s_transfering_SpW_connecter_process_wr_en <= '0';
                cPSa_IN_SpW_ADDR_FIFO_rd_en_o            <= '0';

                -- Machine state
                case s_transfering_PUS_to_SpW_state is

                    -- RESET state: resets all the signals and transitions to the IDLE state
                    when RESET =>

                        -- Reset all the signals of the process
                        s_transfering_PUS_to_SpW_state <= IDLE;

                        -- Reset the signals for the IN SpW ADDR FIFO module
                        cPSa_IN_SpW_ADDR_FIFO_rd_en_o <= '0';

                        -- Reset internal signals
                        s_transfering_bytes_count      <= 0;
                        s_transfering_byte_transfered  <= '0';
                        s_transfering_SpW_connecter_process_wr_en <= '0';
                        s_transfering_first_CCSDS_byte <= (others => '0');
                        s_transfering_sending_SpW_addr <= (others => '0');
                        s_transfering_SpW_connecter_process_data <= (others => '0');
                        s_transfering_first_CCSDS_byte_sent <= '0';


                    -- IDLE state: waits for data from the CCSDS Out module to start transmitting a packet
                    when IDLE =>

                        -- Waits for data from the CCSDS Out module
                        if cPSa_CCSDS_out_wr_en_i = '1' then

                            -- Stores the first byte of the CCSDS packet
                            s_transfering_first_CCSDS_byte <= cPSa_CCSDS_out_data_i;

                            -- Gets the SpW address from the IN SpW ADDR FIFO
                            s_transfering_sending_SpW_addr <= cPSa_IN_SpW_ADDR_FIFO_data_i.spw_addr;
                            cPSa_IN_SpW_ADDR_FIFO_rd_en_o  <= '1';

                            -- Transitions to the SENDING_HDR state
                            s_transfering_PUS_to_SpW_state <= SENDING_HDR;

                        end if;


                    -- SENDING_HDR state: receives the SpW Headerss
                    when SENDING_HDR =>

                        -- If the SpW connecter is ready to receive data and a byte hasn't been transfered yet
                        if cPSa_SpW_connecter_txrdy_out_i = '1' and s_transfering_byte_transfered = '0' then

                            -- Switch case for the number of bytes transmitted in this state
                            case s_transfering_bytes_count is

                                -- Sends the SpW ADDR
                                when 0 =>
                                    s_transfering_SpW_connecter_process_data <= s_transfering_sending_SpW_addr;

                                -- Sends the Protocol ID (PUS)
                                when 1 =>
                                    s_transfering_SpW_connecter_process_data <= c_cPSA_PROTOCOL_ID_PUS;

                                -- The 3th and 4th byte are reserved (set to 0)
                                when 2 =>
                                    s_transfering_SpW_connecter_process_data <= (others => '0');
                                when 3 =>
                                    s_transfering_SpW_connecter_process_data <= (others => '0');

                                -- Sends the first CCSDS byte
                                when 4 =>
                                    s_transfering_SpW_connecter_process_data <= s_transfering_first_CCSDS_byte;

                                when others =>
                                    null;

                            end case;

                            -- Enables the wr en flag for the output FIFO, and asserts the byte transfered signal
                            s_transfering_SpW_connecter_process_wr_en <= '1';
                            s_transfering_byte_transfered             <= '1';
                            s_transfering_bytes_count                 <= s_transfering_bytes_count + 1;

                        -- If the FIFO isn't ready to receive data, stops
                        else

                            s_transfering_SpW_connecter_process_wr_en <= '0';
                            s_transfering_byte_transfered             <= '0';

                            -- If the number of bytes transmitted is equal to 6, transitions to RECEIVING CCSDS and writes the received data to the FIFO
                            if s_transfering_bytes_count = 5 then

                                s_transfering_bytes_count      <= 0;
                                s_transfering_sending_SpW_addr <= (others => '0');
                                s_transfering_PUS_to_SpW_state <= SENDING_CCSDS;

                            end if;

                        end if;


                    -- SENDING_CCSDS state: transmits the CCSDS packet
                    when SENDING_CCSDS =>

                        -- If an end of packet flag is received from the CCSDS Out module, go to the IDLE state
                        if cPSa_CCSDS_out_end_pkg_i = '1' then

                            s_transfering_PUS_to_SpW_state <= IDLE;

                            -- Resets the internal signals
                            s_transfering_bytes_count      <= 0;
                            s_transfering_byte_transfered  <= '0';
                            s_transfering_SpW_connecter_process_wr_en <= '0';
                            s_transfering_first_CCSDS_byte <= (others => '0');
                            s_transfering_sending_SpW_addr <= (others => '0');
                            s_transfering_SpW_connecter_process_data <= (others => '0');
                            s_transfering_first_CCSDS_byte_sent <= '0';

                        end if;

                end case;
            end if;
        end if;

    end process p_PUS_to_SpW_process;

    -- Buffer for connecting the SpW connecter to the CCSDS Out module

    cPSa_CCSDS_out_full_o <= '0' when s_transfering_PUS_to_SpW_state = IDLE else
                              '1' when s_transfering_PUS_to_SpW_state = SENDING_HDR else
                              cPSa_SpW_connecter_full_out_i when s_transfering_PUS_to_SpW_state = SENDING_CCSDS else
                              '1';

    cPSa_CCSDS_out_almost_full_o <= '0' when s_transfering_PUS_to_SpW_state = IDLE else
                                     '1' when s_transfering_PUS_to_SpW_state = SENDING_HDR else
                                     cPSa_SpW_connecter_almost_full_out_i when s_transfering_PUS_to_SpW_state = SENDING_CCSDS else
                                     '1';

    cPSa_CCSDS_out_txrdy_o <= '1' when s_transfering_PUS_to_SpW_state = IDLE else
                               '0' when s_transfering_PUS_to_SpW_state = SENDING_HDR else
                               cPSa_SpW_connecter_txrdy_out_i when s_transfering_PUS_to_SpW_state = SENDING_CCSDS else
                               '0';

    cPSa_SpW_connecter_wr_en_out_o <= s_transfering_SpW_connecter_process_wr_en when s_transfering_PUS_to_SpW_state = SENDING_HDR else
                                      cPSa_CCSDS_out_wr_en_i                  when s_transfering_PUS_to_SpW_state = SENDING_CCSDS else
                                        '0';

    cPSa_SpW_connecter_data_out_o <= s_transfering_SpW_connecter_process_data when s_transfering_PUS_to_SpW_state = SENDING_HDR else
                                    cPSa_CCSDS_out_data_i                  when s_transfering_PUS_to_SpW_state = SENDING_CCSDS else
                                      (others => '0');

    cPSa_SpW_connecter_flag_out_o <= '0' when s_transfering_PUS_to_SpW_state = SENDING_HDR else
                                    cPSa_CCSDS_out_end_pkg_i                  when s_transfering_PUS_to_SpW_state = SENDING_CCSDS else
                                      '0';


end architecture rtl;

----------------------------------------------------------------------------------------------------
