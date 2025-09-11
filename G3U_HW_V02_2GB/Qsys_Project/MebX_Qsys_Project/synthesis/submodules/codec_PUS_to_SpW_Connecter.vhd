----------------------------------------------------------------------------------------------------
-- codec_PUS_top.vhd
-- Author: Thiago A. M. do Amaral and Luiz H. A. Santos
-- Date: 2025-02-06
-- Description: this file contains the top level entity of the entire codec_PUS system.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Libraries import

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.codec_PUS_main_pkg.all;

----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Entity Declaration

entity codec_PUS_to_SpW_Connecter is

port(

    -- Input Signals --

    -- Clock and reset signals
    clk_i          : in  std_logic;  -- Global clock signal
    rst_i          : in  std_logic;  -- Global reset signal

    -- Conduit signals that come from Codec PUS
    codec_PUS_conduit_inFIFO_rd_en_o         : in std_logic;

    codec_PUS_conduit_outFIFO_data_o         : in std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
    codec_PUS_conduit_outFIFO_flag_o         : in std_logic;
    codec_PUS_conduit_outFIFO_wr_en_o        : in std_logic;


    -- Conduit signals that come from SpaceWire Light
    spw_link_status_started_i        : in  std_logic                     := '0'; --          -- conduit_end_spacewire_controller.spw_link_status_started_signal
    spw_link_status_connecting_i     : in  std_logic                     := '0'; --          --                                 .spw_link_status_connecting_signal
    spw_link_status_running_i        : in  std_logic                     := '0'; --          --                                 .spw_link_status_running_signal
    spw_link_error_errdisc_i         : in  std_logic                     := '0'; --          --                                 .spw_link_error_errdisc_signal
    spw_link_error_errpar_i          : in  std_logic                     := '0'; --          --                                 .spw_link_error_errpar_signal
    spw_link_error_erresc_i          : in  std_logic                     := '0'; --          --                                 .spw_link_error_erresc_signal
    spw_link_error_errcred_i         : in  std_logic                     := '0'; --          --                                 .spw_link_error_errcred_signal  
    spw_timecode_rx_tick_out_i       : in  std_logic                     := '0'; --          --                                 .spw_timecode_rx_tick_out_signal
    spw_timecode_rx_ctrl_out_i       : in  std_logic_vector(1 downto 0)  := (others => '0'); --                                 .spw_timecode_rx_ctrl_out_signal
    spw_timecode_rx_time_out_i       : in  std_logic_vector(5 downto 0)  := (others => '0'); --                                 .spw_timecode_rx_time_out_signal
    spw_data_rx_status_rxvalid_i     : in  std_logic                     := '0'; --          --                                 .spw_data_rx_status_rxvalid_signal
    spw_data_rx_status_rxhalff_i     : in  std_logic                     := '0'; --          --                                 .spw_data_rx_status_rxhalff_signal
    spw_data_rx_status_rxflag_i      : in  std_logic                     := '0'; --          --                                 .spw_data_rx_status_rxflag_signal
    spw_data_rx_status_rxdata_i      : in  std_logic_vector(7 downto 0)  := (others => '0'); --                                 .spw_data_rx_status_rxdata_signal
    spw_data_tx_status_txrdy_i       : in  std_logic                     := '0'; --          --                                 .spw_data_tx_status_txrdy_signal
    spw_data_tx_status_txhalff_i     : in  std_logic                     := '0'; --          --                                 .spw_data_tx_status_txhalff_signal
    spw_errinj_ctrl_errinj_busy_i    : in  std_logic                     := '0'; --          --                                 .spw_errinj_ctrl_errinj_busy_signal
    spw_errinj_ctrl_errinj_ready_i   : in  std_logic                     := '0'; --          --         .spw_errinj_ctrl_errinj_ready_signal


    -- Output Signals --


    -- Signals that go to Codec PUS
    codec_PUS_conduit_inFIFO_data_i          : out  std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
    codec_PUS_conduit_inFIFO_flag_i          : out  std_logic;
    codec_PUS_conduit_inFIFO_almost_empty_i  : out  std_logic;
    codec_PUS_conduit_inFIFO_empty_i         : out  std_logic;
    codec_PUS_conduit_inFIFO_rxvalid_i       : out  std_logic;

    codec_PUS_conduit_outFIFO_almost_full_i : out  std_logic;
    codec_PUS_conduit_outFIFO_full_i        : out  std_logic;
    codec_PUS_conduit_outFIFO_txrdy_i       : out  std_logic;


    -- Signals that go to SpaceWire Light
    spw_link_command_enable_o        : out std_logic; --                                     --                                 .spw_link_command_enable_signal
    spw_link_command_autostart_o     : out std_logic; --                                     --                                 .spw_link_command_autostart_signal
    spw_link_command_linkstart_o     : out std_logic; --                                     --                                 .spw_link_command_linkstart_signal
    spw_link_command_linkdis_o       : out std_logic; --                                     --                                 .spw_link_command_linkdis_signal
    spw_link_command_txdivcnt_o      : out std_logic_vector(7 downto 0); --                  --                                 .spw_link_command_txdivcnt_signal
    spw_timecode_tx_tick_in_o        : out std_logic; --                                     --                                 .spw_timecode_tx_tick_in_signal
    spw_timecode_tx_ctrl_in_o        : out std_logic_vector(1 downto 0); --                  --                                 .spw_timecode_tx_ctrl_in_signal
    spw_timecode_tx_time_in_o        : out std_logic_vector(5 downto 0); --                  --                                 .spw_timecode_tx_time_in_signal
    spw_data_rx_command_rxread_o     : out std_logic; --                                     --                                 .spw_data_rx_command_rxread_signal
    spw_data_tx_command_txwrite_o    : out std_logic; --                                     --                                 .spw_data_tx_command_txwrite_signal
    spw_data_tx_command_txflag_o     : out std_logic; --                                     --                                 .spw_data_tx_command_txflag_signal
    spw_data_tx_command_txdata_o     : out std_logic_vector(7 downto 0); --                  --                                 .spw_data_tx_command_txdata_signal
    spw_errinj_ctrl_start_errinj_o   : out std_logic; --                                     --                                 .spw_errinj_ctrl_start_errinj_signal
    spw_errinj_ctrl_reset_errinj_o   : out std_logic; --                                     --                                 .spw_errinj_ctrl_reset_errinj_signal
    spw_errinj_ctrl_errinj_code_o    : out std_logic_vector(3 downto 0) --                  --                                 .spw_errinj_ctrl_errinj_code_signal

);

end entity codec_PUS_to_SpW_Connecter;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Architecture Definition

architecture rtl of codec_PUS_to_SpW_Connecter is
        
begin
    
    -- SpaceWire Channel Codec Configuration
    p_spwc_codec_config : process(clk_i, rst_i) is
    begin
        if (rst_i = '1') then
  
            spw_link_command_enable_o      <= '0';
            spw_link_command_autostart_o   <= '0';
            spw_link_command_linkstart_o   <= '0';
            spw_link_command_linkdis_o     <= '0';
            spw_link_command_txdivcnt_o    <= x"01";
            spw_timecode_tx_tick_in_o      <= '0';
            spw_timecode_tx_ctrl_in_o      <= (others => '0');
            spw_timecode_tx_time_in_o      <= (others => '0');
            spw_errinj_ctrl_start_errinj_o <= '0';
            spw_errinj_ctrl_reset_errinj_o <= '0';
            spw_errinj_ctrl_errinj_code_o  <= (others => '0');
   
        elsif rising_edge(clk_i) then
  
            spw_link_command_enable_o      <= '1';
            spw_link_command_autostart_o   <= '1';
            spw_link_command_linkstart_o   <= '0';
            spw_link_command_linkdis_o     <= '0';
            spw_link_command_txdivcnt_o    <= x"01";
            spw_timecode_tx_tick_in_o      <= '0';
            spw_timecode_tx_ctrl_in_o      <= (others => '0');
            spw_timecode_tx_time_in_o      <= (others => '0');
            spw_errinj_ctrl_start_errinj_o <= '0';
            spw_errinj_ctrl_reset_errinj_o <= '0';
            spw_errinj_ctrl_errinj_code_o  <= (others => '0');
   
        end if;
    end process p_spwc_codec_config;

    -- Definition of arbitrary signals for Codec PUS
    codec_PUS_conduit_inFIFO_almost_empty_i <= '0';
    codec_PUS_conduit_inFIFO_empty_i        <= '0';

    codec_PUS_conduit_outFIFO_almost_full_i  <= '0';
    codec_PUS_conduit_outFIFO_full_i         <= '0';

    
    -- Interconnect output SpaceWire Light signals to input Codec PUS signals
    spw_data_rx_command_rxread_o  <= codec_PUS_conduit_inFIFO_rd_en_o;                       
    spw_data_tx_command_txwrite_o <= codec_PUS_conduit_outFIFO_wr_en_o;
    spw_data_tx_command_txflag_o  <= codec_PUS_conduit_outFIFO_flag_o;
    spw_data_tx_command_txdata_o  <= codec_PUS_conduit_outFIFO_data_o;


    -- Interconnect output Codec PUS signals to input SpaceWire Light signals
    codec_PUS_conduit_inFIFO_data_i <= spw_data_rx_status_rxdata_i;     
    codec_PUS_conduit_inFIFO_flag_i <= spw_data_rx_status_rxflag_i;
    codec_PUS_conduit_inFIFO_rxvalid_i <= spw_data_rx_status_rxvalid_i;

    codec_PUS_conduit_outFIFO_txrdy_i <= spw_data_tx_status_txrdy_i;


end architecture rtl;

----------------------------------------------------------------------------------------------------