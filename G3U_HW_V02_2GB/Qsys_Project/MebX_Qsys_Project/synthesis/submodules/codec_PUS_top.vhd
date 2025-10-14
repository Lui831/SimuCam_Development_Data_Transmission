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

entity codec_PUS_top is

port(

    -- Input Signals --

    -- Input and rst signals
    clk_i                         : in  std_logic;
    rst_sync_i                    : in  std_logic;

    -- Avalon MM Agent Input signals
    avalon_mm_agent_addr_i        : in std_logic_vector(5 - 1 downto 0);
    avalon_mm_agent_write_data_i  : in std_logic_vector(C_CCSDS_IN_AVALON_DATA_WIDTH - 1 downto 0);
    avalon_mm_agent_read_i        : in std_logic;
    avalon_mm_agent_write_i       : in std_logic;

    -- Avalon MM Master Input signals
    avalon_mm_master_wait_request_i : in  std_logic;
    avalon_mm_master_read_data_i    : in  std_logic_vector(C_CCSDS_IN_AVALON_DATA_WIDTH - 1 downto 0);

    -- Input FIFO signals --
    conduit_inFIFO_data_i          : in  std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
    conduit_inFIFO_flag_i          : in  std_logic;
    conduit_inFIFO_almost_empty_i  : in  std_logic;
    conduit_inFIFO_empty_i         : in  std_logic;
    conduit_inFIFO_rxvalid_i       : in  std_logic;

    -- Output FIFO signals --
    conduit_outFIFO_almost_full_i : in  std_logic;
    conduit_outFIFO_full_i        : in  std_logic;
    conduit_outFIFO_txrdy_i       : in  std_logic;


    -- Output Signals --

    -- Avalon MM Master Output signals
    avalon_mm_master_addr_o        : out std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
    avalon_mm_master_write_data_o  : out std_logic_vector(C_CCSDS_IN_AVALON_DATA_WIDTH - 1 downto 0);
    avalon_mm_master_read_o        : out std_logic;
    avalon_mm_master_write_o       : out std_logic;

    -- Avalon MM Agent Output signals
    avalon_mm_agent_wait_request_o : out std_logic;
    avalon_mm_agent_read_data_o    : out std_logic_vector(C_CCSDS_IN_AVALON_DATA_WIDTH - 1 downto 0);

    -- Input FIFO signals
    conduit_inFIFO_rd_en_o         : out std_logic;

    -- Output FIFO signals
    conduit_outFIFO_data_o         : out std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
    conduit_outFIFO_flag_o         : out std_logic;
    conduit_outFIFO_wr_en_o        : out std_logic;

    -- Output IRQ signals
    IRQ_send_recv_o                : out std_logic;
    IRQ_send_send_o                : out std_logic


);

end entity codec_PUS_top;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Architecture Definition

architecture rtl of codec_PUS_top is

    -- Components declaration --

    component  codec_pus_receiver_transmitter_ccsds_in is
    generic(
    
        -- Generic de identificação do canal
        g_PUS_CHANNEL_ID         : integer range 0 to C_CCSDS_IN_MAX_CHANNELS - 1 := 0

    );
    port(
    
        ---- Snais de clock e reset do sistema --
        clk_i                    : in std_logic;
        rst_sync_i               : in std_logic;


        ---- Sinais da FIFO de entrada --
        cPRTCi_inFIFO_data_i          : in std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
        cPRTCi_inFIFO_flag_i          : in std_logic;
        cPRTCi_inFIFO_almost_empty_i  : in std_logic;
        cPRTCi_inFIFO_empty_i         : in std_logic;
        cPRTCi_inFIFO_rxvalid_i       : in std_logic;

        cPRTCi_inFIFO_rd_en_o          : out std_logic;


        ---- Sinais do módulo de CRC16 --
        cPRTCi_CRC16_crc_i           : in std_logic_vector(15 downto 0);

        cPRTCi_CRC16_data_o         : out std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
        cPRTCi_CRC16_en_o           : out std_logic;
        cPRTCi_CRC16_rst_sync_o     : out std_logic;


        ---- Sinais de interconexão com a FIFO de saida do módulo --
        cPRTCi_outFIFO_data_o : out t_CCSDs_in_FIFO_data_out;
        cPRTCi_outFIFO_wr_en_o : out std_logic;

        cPRTCi_outFIFO_full_i : in std_logic;
        cPRTCi_outFIFO_almost_full_i : in std_logic;
        cPRTCi_outFIFO_txrdy_i : in std_logic;


        -- Sinais de conexão com o Avalon MM e a DDR3 -- 
        cPRTCi_Avalon_MM_addr_o                    : out std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
        cPRTCi_Avalon_MM_write_o                   : out std_logic;
        cPRTCi_Avalon_MM_write_data_o              : out std_logic_vector(C_CCSDS_IN_AVALON_DATA_WIDTH - 1 downto 0);

        cPRTCi_Avalon_MM_wait_request_i            : in std_logic;

        -- Sinais de restauração de memória junto ao Processer --
        cPRTCi_PROC_rst_mem_value_i              : in std_logic_vector(C_CCSDS_IN_PROC_RST_VALUE_WIDTH - 1 downto 0);
        cPRTCi_PROC_rst_i                        : in std_logic;

        -- Sinais para a definição da fila de DMA --
        cPRTCi_DMA_start_addr_i               : in std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
        cPRTCi_DMA_num_bytes_i               : in std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0)

    );
end component;

component codec_PUS_Receiver_Transmitter_CCSDS_Out is
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

end component;

component codec_PUS_CRC16CITT_module is
    generic(

        -- CRC16 Inicial
        g_crc_init: std_logic_vector(15 downto 0) := C_CRC16CITT_INIT

    );
    port (

        ---- Sinais de Entrada --
        -- Clock e reset síncrono do sistema
        clk_i        : in std_logic;
        rst_sync_i   : in std_logic;

        -- Dados de entrada para cálculo do CRC16
        CRC16_data_i : in std_logic_vector(C_CRC16CITT_DATA_WIDTH - 1 downto 0);

        -- Sinal de enable do CRC16
        CRC16_en_i   : in std_logic;

        ---- Sinais de Saída do CRC16 --
        -- CRC16 calculado
        CRC16_out_o  : out std_logic_vector(C_CRC16CITT_WIDTH - 1 downto 0)
    );
end component;

component codec_PUS_Registers_Controller_Module is
    port(

        -- Input Signals --

        -- Reset and Clock signals
        clk_i      : in std_logic;
        rst_sync_i : in std_logic;

        -- Input Header FIFO signals
        cPRCM_input_hdr_fifo_data_i         : in t_cPFi_FIFO_data;
        cPRCM_input_hdr_fifo_rxrdy_i        : in std_logic;
        cPRCM_input_hdr_fifo_empty_i        : in std_logic;
        cPRCM_input_hdr_fifo_almost_empty_i : in std_logic;

        -- Output Header FIFO signals
        cPRCM_output_hdr_fifo_txrdy_i       : in std_logic;
        cPRCM_output_hdr_fifo_full_i        : in std_logic;
        cPRCM_output_hdr_fifo_almost_full_i : in std_logic;

        -- IN SpW ADDR FIFO signals
        cPRCM_IN_SpW_ADDR_FIFO_txrdy_i       : in std_logic;
        cPRCM_IN_SpW_ADDR_FIFO_full_i        : in std_logic;
        cPRCM_IN_SpW_ADDR_FIFO_almost_full_i : in std_logic;

        -- OUT SpW ADDR FIFO signals
        cPRCM_OUT_SpW_ADDR_FIFO_rxvalid_i      : in std_logic;
        cPRCM_OUT_SpW_ADDR_FIFO_empty_i        : in std_logic;
        cPRCM_OUT_SpW_ADDR_FIFO_almost_empty_i : in std_logic;
        cPRCM_OUT_SpW_ADDR_FIFO_data_i         : in t_cPSAF_FIFO_data;

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

        -- IN SpW ADDR FIFO signals
        cPRCM_IN_SpW_ADDR_FIFO_wr_en_o : out std_logic;
        cPRCM_IN_SpW_ADDR_FIFO_data_o  : out t_cPSAF_FIFO_data;

        -- OUT SpW ADDR FIFO signals
        cPRCM_OUT_SpW_ADDR_FIFO_rd_en_o : out std_logic;

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
        cPRCM_gen_proc_rst_o : out std_logic;

        -- External protocol adapter configuration signals
        cPRCM_external_proto_cfg_spw_addr_o : out std_logic_vector(7 downto 0)
    );
end component;

component codec_PUS_Input_Header_FIFO is

    generic(

        -- Generic for the FIFO's length
        c_cPFi_LENGTH : natural := 16

    );


    port(

        clk_i                            : in std_logic;
        rst_sync_i                       : in std_logic;

        cPCIHF_CCSDS_In_data_i           : in t_cPFi_FIFO_data;
        cPCIHF_CCSDS_In_wr_en_i          : in std_logic;
        cPCIHF_CCSDS_In_rd_en_i          : in std_logic;
         
 
        
        cPCIHF_CCSDS_In_data_o           : out t_cPFi_FIFO_data;
        cPCIHF_CCSDS_In_full_o           : out std_logic;
        cPCIHF_CCSDS_In_empty_o          : out std_logic;
        cPCIHF_CCSDS_In_almost_empty_o   : out std_logic;
        cPCIHF_CCSDS_In_almost_full_o    : out std_logic;
        cPCIHF_CCSDS_In_txrdy_o          : out std_logic;
        cPCIHF_CCSDS_In_rxrdy_o          : out std_logic 
    );

end component;

component codec_PUS_Output_Header_FIFO is
    generic (
    
        -- Generic for the FIFO's length
        c_cPFo_LENGTH : natural := 16

    );
    port(
    
        -- Input signals --

        -- Clock and rst signals
        clk_i                   : in std_logic;
        rst_sync_i              : in std_logic;

        -- Input FIFO signals for the receiving part
        cPFo_wr_en_i          : in std_logic;
        cPFo_data_i           : in t_cPFo_FIFO_data;
        
        -- Input FIFO signals for the transmiting part
        cPFo_rd_en_i          : in std_logic;


        -- Output signals --

        -- Output FIFO signals for the receiving part
        cPFo_empty_o         : out std_logic;
        cPFo_almost_empty_o  : out std_logic;
        cPFo_txrdy_o     : out std_logic;

        -- Output FIFO signals for the transmiting part
        cPFo_full_o         : out std_logic;
        cPFo_almost_full_o  : out std_logic;
        cPFo_data_o         : out t_cPFo_FIFO_data;
        cPFo_rxrdy_o        : out std_logic

    );

end component;

component codec_PUS_SpW_ADDR_FIFO is
    generic(

        -- Generic for the FIFO's length
        c_cPSAF_LENGTH : natural := C_CPSAF_FIFO_DEPTH
    );

    port(

        -- Clock and Reset
        clk_i        : in  std_logic;
        rst_sync_i   : in  std_logic;

        -- FIFO Write Interface (Codec PUS side)
        cPSAF_wr_en_i : in  std_logic;
        cPSAF_data_i  : in  t_cPSAF_FIFO_data;

        -- FIFO Read Interface (SpaceWire side)
        cPSAF_rd_en_i : in  std_logic;

        -- FIFO Status Outputs
        cPSAF_empty_o         : out std_logic;
        cPSAF_almost_empty_o  : out std_logic;
        cPSAF_txrdy_o         : out std_logic;
        cPSAF_full_o          : out std_logic;
        cPSAF_almost_full_o   : out std_logic;
        cPSAF_data_o          : out t_cPSAF_FIFO_data;
        cPSAF_rxvalid_o       : out std_logic
    );

end component;

component codec_PUS_SpW_adapter is
    port(

        -- Input Signals --

        -- Clock and Reset
        clk_i        : in  std_logic;  -- Global clock
        rst_sync_i   : in  std_logic;  -- Global synchronous reset (active high)

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

        -- Output signals to the SpW connecter module
        cPSa_SpW_connecter_rd_en_in_o : out std_logic;
        cPSa_SpW_connecter_data_out_o  : out std_logic_vector(c_cPSA_SpW_DATA_WIDTH - 1 downto 0);
        cPSa_SpW_connecter_flag_out_o  : out std_logic;
        cPSa_SpW_connecter_wr_en_out_o : out std_logic
    );
end component;

component codec_PUS_Avalon_Write is

	port(

        -- Input Signals --

        -- Reset and clock signals
		clk_i                   : in  std_logic;
		rst_i                   : in  std_logic;

        -- Avalon Interface Input Signals
        cPAW_avalon_mm_write_i      : in std_logic;
        cPAW_avalon_mm_address_i    : in std_logic_vector(c_CPAW_AVALON_ADDR_WIDTH - 1 downto 0);
        cPAW_avalon_mm_write_data_i : in std_logic_vector(c_CPAW_AVALON_DATA_WIDTH - 1 downto 0);

        -- Write registers from the Controller module
        cPAW_controller_wr_regs_i : in t_codec_PUS_wr_regs;
		

        -- Output Signals --

        -- Write registers for the Controller module
        cPAW_controller_wr_regs : out t_codec_PUS_wr_regs;

        -- Write flag for the Controller module
        cPAW_controller_wr_flag : out std_logic;

        -- Avalon MM Interface Output Signals
        cPAW_avalon_mm_wait_request_o : out std_logic 
		
	);

end component;

component codec_PUS_Avalon_Read is

	port(

        -- Input Signals --

        -- Reset and clock signals
		clk_i                   : in  std_logic;
		rst_i                   : in  std_logic;

        -- Avalon MM Interface Input Signals
        cPAR_avalon_mm_read_i    : in std_logic;
        cPAR_avalon_mm_address_i : in std_logic_vector(c_CPAR_AVALON_ADDR_WIDTH - 1 downto 0);
		
        -- Write and Read Registers from the Controller
        cPAR_controller_rd_regs : in t_codec_PUS_rd_regs;
        

        -- Output Signals --

        -- Avalon MM Interface Output Signals
        cPAR_avalon_mm_read_data_o    : out std_logic_vector(c_CPAR_AVALON_DATA_WIDTH - 1 downto 0);
        cPAR_avalon_mm_wait_request_o : out std_logic 
		
	);

end component;

component codec_PUS_IRQ_Controller is
    port(
        -- Input Signals --
        clk_i      : in std_logic;
        rst_sync_i : in std_logic;

        -- Input Signals from the Controller
        cPIC_controller_wr_regs_i          : in t_codec_PUS_wr_regs;
        cPIC_controller_recv_IRQ_trigger_i : in std_logic;
        cPIC_controller_send_IRQ_trigger_i : in std_logic;

        -- Output Signals --
        cPIC_avalon_IRQ_recv_IRQ_o : out std_logic;
        cPIC_avalon_IRQ_send_IRQ_o : out std_logic
    );
end component;

-- Signals for Interconnecting the Components --

-- Signals for interconnecting the CCSDS In with the Input Header FIFO
signal s_CCSDS_in_Input_Header_FIFO_data : t_cPFi_FIFO_data;
signal s_CCSDS_in_Input_Header_FIFO_full : std_logic;
signal s_CCSDS_in_Input_Header_FIFO_almost_full : std_logic;
signal s_CCSDS_in_Input_Header_FIFO_txrdy : std_logic;
signal s_CCSDS_in_Input_Header_FIFO_wr_en : std_logic;

-- Signals for interconnecting the CCSDS In and the CRC16 module
signal s_CCSDS_in_CRC16_data : std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
signal s_CCSDS_in_CRC16_crc : std_logic_vector(C_CRC16CITT_WIDTH - 1 downto 0);
signal s_CCSDS_in_CRC16_en : std_logic;
signal s_CCSDS_in_CRC16_rst : std_logic;

-- Signals for interconnecting the Input Header FIFO to the Controller module
signal s_Input_Header_FIFO_Controller_data : t_cPFi_FIFO_data;
signal s_Input_Header_FIFO_Controller_empty : std_logic;
signal s_Input_Header_FIFO_Controller_almost_empty : std_logic;
signal s_Input_Header_FIFO_Controller_rxrdy : std_logic;
signal s_Input_Header_FIFO_Controller_rd_en : std_logic;

-- Signals for interconnecting the CCSDS Out module with the Output Header FIFO
signal s_CCSDS_out_Output_Header_FIFO_data : t_cPFo_FIFO_data;
signal s_CCSDS_out_Output_Header_FIFO_empty : std_logic;
signal s_CCSDS_out_Output_Header_FIFO_almost_empty : std_logic;
signal s_CCSDS_out_Output_Header_FIFO_rxrdy : std_logic;
signal s_CCSDS_Out_Output_Header_FIFO_rd_en : std_logic;

-- Signals for interconnecting the CCSDS Out module and the CRC16 module
signal s_CCSDS_out_CRC16_data : std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
signal s_CCSDS_out_CRC16_crc : std_logic_vector(C_CRC16CITT_WIDTH - 1 downto 0);
signal s_CCSDS_out_CRC16_en : std_logic;
signal s_CCSDS_out_CRC16_rst : std_logic;

-- Signals for interconnecting the Output Header FIFO with the Controller module
signal s_Output_Header_FIFO_Controller_data : t_cPFo_FIFO_data;
signal s_Output_Header_FIFO_Controller_full : std_logic;
signal s_Output_Header_FIFO_Controller_almost_full : std_logic;
signal s_Output_Header_FIFO_Controller_txrdy : std_logic;
signal s_Output_Header_FIFO_Controller_wr_en : std_logic;

-- Signals for interconnecting the Controller module with the Avalon Write module
signal s_Controller_Avalon_Write_wr_regs : t_codec_PUS_wr_regs;
signal s_Controller_Avalon_Write_wr_flag : std_logic;
signal s_Controller_Avalon_Write_feedback_wr_regs : t_codec_PUS_wr_regs;

-- Signals for interconnecting the Controller module with the Avalon Read module
signal s_Controller_Avalon_Read_rd_regs : t_codec_PUS_rd_regs;

-- Signals for interconnecting the Controller module with the IRQ Controller module
signal s_Controller_IRQ_Controller_wr_regs : t_codec_PUS_wr_regs;
signal s_Controller_IRQ_Controller_recv_IRQ_trigger : std_logic;
signal s_Controller_IRQ_Controller_send_IRQ_trigger : std_logic;

-- Signals for interconnecting the Controller module with the CCSDS in module
signal s_Controller_CCSDS_in_rst : std_logic;
signal s_Controller_CCSDS_in_rst_value : std_logic_vector(C_CPRCM_RST_VALUE_WIDTH - 1 downto 0);
signal s_Controller_CCSDS_in_DMA_start_addr : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
signal s_Controller_CCSDS_in_DMA_num_bytes : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);

-- Signals for interconnecting the Controller module with the CCSDS out module
signal s_Controller_CCSDS_out_rst : std_logic;
signal s_Controller_CCSDS_out_DMA_start_addr : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
signal s_Controller_CCSDS_out_DMA_num_bytes : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);

-- Signals for interconnecting the Controller module with the SpW Adapter module
signal s_Controller_SpW_adapter_SpW_node_ADDR : std_logic_vector(c_cPSA_SpW_ADDR_WIDTH - 1 downto 0);

-- Signals for interconnecting the Controller module with the IN SpW ADDR FIFO module
signal s_Controller_IN_SpW_ADDR_FIFO_wr_en : std_logic;
signal s_Controller_IN_SpW_ADDR_FIFO_data : t_cPSAF_FIFO_data;
signal s_Controller_IN_SpW_ADDR_FIFO_full : std_logic;
signal s_Controller_IN_SpW_ADDR_FIFO_almost_full : std_logic;
signal s_Controller_IN_SpW_ADDR_FIFO_txrdy : std_logic;

-- Signals for interconnecting the Controller module with the OUT SpW ADDR FIFO module
signal s_Controller_OUT_SpW_ADDR_FIFO_rd_en : std_logic;
signal s_Controller_OUT_SpW_ADDR_FIFO_data : t_cPSAF_FIFO_data;
signal s_Controller_OUT_SpW_ADDR_FIFO_empty : std_logic;
signal s_Controller_OUT_SpW_ADDR_FIFO_almost_empty : std_logic;
signal s_Controller_OUT_SpW_ADDR_FIFO_rxvalid : std_logic;

-- Signals for interconnecting the SpW Adapter module with the IN SpW ADDR FIFO module
signal s_SpW_adapter_IN_SpW_ADDR_FIFO_rd_en : std_logic;
signal s_SpW_adapter_IN_SpW_ADDR_FIFO_data : t_cPSAF_FIFO_data;
signal s_SpW_adapter_IN_SpW_ADDR_FIFO_empty : std_logic;
signal s_SpW_adapter_IN_SpW_ADDR_FIFO_almost_empty : std_logic;
signal s_SpW_adapter_IN_SpW_ADDR_FIFO_rxvalid : std_logic;

-- Signals for interconnecting the SpW Adapter module with the OUT SpW ADDR FIFO module
signal s_SpW_adapter_OUT_SpW_ADDR_FIFO_data : t_cPSAF_FIFO_data;
signal s_SpW_adapter_OUT_SpW_ADDR_FIFO_full : std_logic;
signal s_SpW_adapter_OUT_SpW_ADDR_FIFO_almost_full : std_logic;
signal s_SpW_adapter_OUT_SpW_ADDR_FIFO_txrdy : std_logic;
signal s_SpW_adapter_OUT_SpW_ADDR_FIFO_wr_en : std_logic;

-- Signals for interconnecting the SpW Adapter module with the CCSDS In module
signal s_SpW_adapter_CCSDS_in_data : std_logic_vector(c_cPSA_CCSDS_DATA_WIDTH - 1 downto 0);
signal s_SpW_adapter_CCSDS_in_end_pkg : std_logic;
signal s_SpW_adapter_CCSDS_in_rxvalid : std_logic;
signal s_SpW_adapter_CCSDS_in_empty : std_logic;
signal s_SpW_adapter_CCSDS_in_almost_empty : std_logic;
signal s_SpW_adapter_CCSDS_in_rd_en : std_logic;

-- Signals for interconnecting the SpW Adapter module with the CCSDS Out module
signal s_SpW_adapter_CCSDS_out_full : std_logic;
signal s_SpW_adapter_CCSDS_out_almost_full : std_logic;
signal s_SpW_adapter_CCSDS_out_txrdy : std_logic;
signal s_SpW_adapter_CCSDS_out_data : std_logic_vector(c_cPSA_CCSDS_DATA_WIDTH - 1 downto 0);
signal s_SpW_adapter_CCSDS_out_end_pkg : std_logic;
signal s_SpW_adapter_CCSDS_out_wr_en : std_logic;

-- Codec PUS general reset signal from the Controller module
signal s_Controller_gen_proc_rst : std_logic;

-- Combined reset signal for the inner parts of the Codec PUS
signal s_comb_rst : std_logic;


-- Wait request logic shared between the Avalon MM Read and Write Master modules
signal s_avalon_mm_master_read_wait_request : std_logic;
signal s_avalon_mm_master_write_wait_request : std_logic;

-- Wait request logic shared the Avalon MM Read and Write Agent modules
signal s_avalon_mm_agent_read_wait_request : std_logic;
signal s_avalon_mm_agent_write_wait_request : std_logic;

-- Address logic shared between the Avalon MM Read and Write Master modules
signal s_avalon_mm_master_read_addr : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
signal s_avalon_mm_master_write_addr : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);

-- Read and write aux signals for the avalon MM Master
signal s_aux_avalon_mm_master_read_o : std_logic;
signal s_aux_avalon_mm_master_write_o : std_logic;

-- Designate type and signal to store the avalon mm master last operation
type t_avalon_mm_master_last_operation is (READ, WRITE, NONE);
signal s_avalon_mm_master_last_operation : t_avalon_mm_master_last_operation := NONE;
signal s_avalon_mm_master_prev_operation : t_avalon_mm_master_last_operation := NONE;

-- Signal to pad the avalon mm agent address input
signal s_avalon_mm_addr_padding_signal : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);



begin


-- Instantiation for the CCSDS In module
CCSDS_Input : codec_pus_receiver_transmitter_ccsds_in
    generic map(
        -- Channel identification generic
        g_PUS_CHANNEL_ID => 0
    )
    port map(

        -- System clock and reset signals
        clk_i                    => clk_i,
        rst_sync_i               => s_comb_rst,

        -- Input FIFO signals
        cPRTCi_inFIFO_data_i         => s_SpW_adapter_CCSDS_in_data,
        cPRTCi_inFIFO_flag_i         => s_SpW_adapter_CCSDS_in_end_pkg,
        cPRTCi_inFIFO_almost_empty_i => s_SpW_adapter_CCSDS_in_almost_empty,
        cPRTCi_inFIFO_empty_i        => s_SpW_adapter_CCSDS_in_empty,
        cPRTCi_inFIFO_rxvalid_i      => s_SpW_adapter_CCSDS_in_rxvalid,
        cPRTCi_inFIFO_rd_en_o        => s_SpW_adapter_CCSDS_in_rd_en,

        -- CRC16 module signals
        cPRTCi_CRC16_crc_i           => s_CCSDS_in_CRC16_crc,
        cPRTCi_CRC16_data_o          => s_CCSDS_in_CRC16_data,
        cPRTCi_CRC16_en_o            => s_CCSDS_in_CRC16_en,
        cPRTCi_CRC16_rst_sync_o      => s_CCSDS_in_CRC16_rst,
        

        -- Interconnection signals with the module output FIFO
        cPRTCi_outFIFO_data_o        => s_CCSDS_in_Input_Header_FIFO_data,
        cPRTCi_outFIFO_wr_en_o       => s_CCSDS_in_Input_Header_FIFO_wr_en,

        cPRTCi_outFIFO_full_i        => s_CCSDS_in_Input_Header_FIFO_full,
        cPRTCi_outFIFO_almost_full_i => s_CCSDS_in_Input_Header_FIFO_almost_full,
        cPRTCi_outFIFO_txrdy_i       => s_CCSDS_in_Input_Header_FIFO_txrdy,

        -- Avalon MM and DDR3 connection signals
        cPRTCi_Avalon_MM_addr_o         => s_avalon_mm_master_write_addr,
        cPRTCi_Avalon_MM_write_o        => s_aux_avalon_mm_master_write_o,
        cPRTCi_Avalon_MM_write_data_o   => avalon_mm_master_write_data_o,
        cPRTCi_Avalon_MM_wait_request_i => s_avalon_mm_master_write_wait_request,

        -- Memory restore signals with the Processor
        cPRTCi_PROC_rst_mem_value_i  => s_Controller_CCSDS_in_rst_value,
        cPRTCi_PROC_rst_i            => s_Controller_CCSDS_in_rst,

        -- DMA queue definition signals
        cPRTCi_DMA_start_addr_i      => s_Controller_CCSDS_in_DMA_start_addr,
        cPRTCi_DMA_num_bytes_i       => s_Controller_CCSDS_in_DMA_num_bytes
    );

-- Instantiation for the Input Header FIFO
Input_Header_FIFO: codec_PUS_Input_Header_FIFO
    generic map(
        c_cPFi_LENGTH => 16
    )
    port map(
        -- Reset and clk signals
        clk_i                     => clk_i,
        rst_sync_i                => s_comb_rst,

        -- Sinais vindos do CCSDS in
        cPCIHF_CCSDS_In_data_i        => s_CCSDS_in_Input_Header_FIFO_data,
        cPCIHF_CCSDS_In_wr_en_i       => s_CCSDS_in_Input_Header_FIFO_wr_en,
        cPCIHF_CCSDS_In_rd_en_i       => s_Input_Header_FIFO_Controller_rd_en,

        -- Sinais indo para o módulo Controller
        cPCIHF_CCSDS_In_data_o        => s_Input_Header_FIFO_Controller_data,
        cPCIHF_CCSDS_In_full_o        => s_CCSDS_in_Input_Header_FIFO_full,
        cPCIHF_CCSDS_In_empty_o       => s_Input_Header_FIFO_Controller_empty,
        cPCIHF_CCSDS_In_almost_full_o => s_CCSDS_in_Input_Header_FIFO_almost_full,
        cPCIHF_CCSDS_In_almost_empty_o => s_Input_Header_FIFO_Controller_almost_empty,
        cPCIHF_CCSDS_In_txrdy_o       => s_CCSDS_in_Input_Header_FIFO_txrdy,
        cPCIHF_CCSDS_In_rxrdy_o       => s_Input_Header_FIFO_Controller_rxrdy
    );


-- Instanciação do módulo CCSDS Out com interconexão dos sinais definidos anteriormente
CCSDS_Output: codec_PUS_Receiver_Transmitter_CCSDS_Out
    generic map(
        C_PUS_CHANNEL_ID => C_CODEC_PUS_NUM_CHANNELS
    )
    port map(
        -- Input signals --

        -- Clock and rst signals
        clk_i                   => clk_i,
        rst_sync_i              => s_comb_rst,

        -- Output FIFO flags
        cPRTCo_outFIFO_full_i        => s_SpW_adapter_CCSDS_out_full,
        cPRTCo_outFIFO_almost_full_i => s_SpW_adapter_CCSDS_out_almost_full,
        cPRTCo_outFIFO_txrdy_i       => s_SpW_adapter_CCSDS_out_txrdy,

        -- Input FIFO data and flags
        cPRTCo_inFIFO_empty_i        => s_CCSDS_out_Output_Header_FIFO_empty,
        cPRTCo_inFIFO_almost_empty_i => s_CCSDS_out_Output_Header_FIFO_almost_empty,
        cPRTCo_inFIFO_rxvalid_i      => s_CCSDS_out_Output_Header_FIFO_rxrdy,
        cPRTCo_inFIFO_data_i         => s_CCSDS_out_Output_Header_FIFO_data,

        -- CRC16CITT module input signals
        cPRTCo_CRC16_crc_i           => s_CCSDS_out_CRC16_crc,

        -- Avalon MM input flag and data signals
        cPRTCo_Avalon_MM_wait_request_i => s_avalon_mm_master_read_wait_request,
        cPRTCo_Avalon_MM_response_i     => "11", -- ajuste conforme necessário
        cPRTCo_Avalon_MM_read_data_i    => avalon_mm_master_read_data_i,

        -- CCSDS Out
        cPRTCo_DMA_start_addr_i => s_Controller_CCSDS_out_DMA_start_addr,
        cPRTCo_DMA_num_bytes_i  => s_Controller_CCSDS_out_DMA_num_bytes,

        -- Output signals --

        -- Output FIFO data and wr flag
        cPRTCo_outFIFO_data_o  => s_SpW_adapter_CCSDS_out_data,
        cPRTCo_outFIFO_flag_o  => s_SpW_adapter_CCSDS_out_end_pkg,
        cPRTCo_outFIFO_wr_en_o => s_SpW_adapter_CCSDS_out_wr_en,

        -- Input FIFO rd en flag
        cPRTCo_inFIFO_rd_en_o  => s_CCSDS_Out_Output_Header_FIFO_rd_en,

        -- CPR16CITT module output signals
        cPRTCo_CRC16_en_o       => s_CCSDS_out_CRC16_en,
        cPRTCo_CRC16_rst_sync_o => s_CCSDS_out_CRC16_rst,
        cPRTCo_CRC16_data_o     => s_CCSDS_out_CRC16_data,

        -- Avalon MM output read signals
        cPRTCo_Avalon_MM_addr_o => s_avalon_mm_master_read_addr,
        cPRTCo_Avalon_MM_read_o => s_aux_avalon_mm_master_read_o,

        -- CCSDS MEM RST signals
        cPRTCo_CCSDS_rst_o        => s_Controller_CCSDS_out_rst,
        cPRTCo_CCSDS_rst_value_o  => open
    );

-- Instantiation for the Output Header FIFO
Output_Header_FIFO: codec_PUS_Output_Header_FIFO
    generic map(
        c_cPFo_LENGTH => 16
    )
    port map(
        -- Input signals --
        -- Clock and rst signals
        clk_i               => clk_i,
        rst_sync_i          => s_comb_rst,

        -- Input FIFO signals for the receiving part
        cPFo_wr_en_i        => s_Output_Header_FIFO_Controller_wr_en,
        cPFo_data_i         => s_Output_Header_FIFO_Controller_data,

        -- Input FIFO signals for the transmitting part
        cPFo_rd_en_i        => s_CCSDS_Out_Output_Header_FIFO_rd_en,

        -- Output signals --

        -- Output FIFO signals for the receiving part
        cPFo_empty_o        => s_CCSDS_out_Output_Header_FIFO_empty,
        cPFo_almost_empty_o => s_CCSDS_out_Output_Header_FIFO_almost_empty,
        cPFo_txrdy_o        => s_CCSDS_out_Output_Header_FIFO_rxrdy,

        -- Output FIFO signals for the transmitting part
        cPFo_full_o         => s_Output_Header_FIFO_Controller_full,
        cPFo_almost_full_o  => s_Output_Header_FIFO_Controller_almost_full,
        cPFo_data_o         => s_CCSDS_out_Output_Header_FIFO_data,
        cPFo_rxrdy_o        => s_Output_Header_FIFO_Controller_txrdy
    );

-- Instantiation of the Registers Controller Module
Controller: codec_PUS_Registers_Controller_Module 
    port map(
        -- Input Signals --

        -- Reset and clock signals
        clk_i                              => clk_i,
        rst_sync_i                         => rst_sync_i,

        -- Input Header FIFO signals
        cPRCM_input_hdr_fifo_data_i         => s_Input_Header_FIFO_Controller_data,
        cPRCM_input_hdr_fifo_rxrdy_i        => s_Input_Header_FIFO_Controller_rxrdy,
        cPRCM_input_hdr_fifo_empty_i        => s_Input_Header_FIFO_Controller_empty,    
        cPRCM_input_hdr_fifo_almost_empty_i => s_Input_Header_FIFO_Controller_almost_empty,    

        -- Output Header FIFO signals
        cPRCM_output_hdr_fifo_txrdy_i       => s_Output_Header_FIFO_Controller_txrdy,     
        cPRCM_output_hdr_fifo_full_i        => s_Output_Header_FIFO_Controller_full, 
        cPRCM_output_hdr_fifo_almost_full_i => s_Output_Header_FIFO_Controller_almost_full,

        -- IN SpW ADDR FIFO signals
        cPRCM_IN_SpW_ADDR_FIFO_txrdy_i        => s_Controller_IN_SpW_ADDR_FIFO_txrdy,
        cPRCM_IN_SpW_ADDR_FIFO_full_i         => s_Controller_IN_SpW_ADDR_FIFO_full,
        cPRCM_IN_SpW_ADDR_FIFO_almost_full_i  => s_Controller_IN_SpW_ADDR_FIFO_almost_full,

        -- OUT SpW ADDR FIFO signals
        cPRCM_OUT_SpW_ADDR_FIFO_rxvalid_i      => s_Controller_OUT_SpW_ADDR_FIFO_rxvalid,
        cPRCM_OUT_SpW_ADDR_FIFO_empty_i        => s_Controller_OUT_SpW_ADDR_FIFO_empty,
        cPRCM_OUT_SpW_ADDR_FIFO_almost_empty_i => s_Controller_OUT_SpW_ADDR_FIFO_almost_empty,
        cPRCM_OUT_SpW_ADDR_FIFO_data_i         => s_Controller_OUT_SpW_ADDR_FIFO_data,

        -- Agent Write signals
        cPRCM_agent_write_wr_regs_i         => s_Controller_Avalon_Write_wr_regs,
        cPRCM_agent_write_wr_flag_i         => s_Controller_Avalon_Write_wr_flag, 

        -- CCSDS out signals
        cPRCM_CCSDS_out_rst_i               => s_Controller_CCSDS_out_rst,

        -- Output Header FIFO signals
        cPRCM_input_hdr_fifo_rd_en_o        => s_Input_Header_FIFO_Controller_rd_en, 
        cPRCM_output_hdr_fifo_wr_en_o       => s_Output_Header_FIFO_Controller_wr_en,
        cPRCM_output_hdr_fifo_data_o        => s_Output_Header_FIFO_Controller_data, 

        -- IN SpW ADDR FIFO signals
        cPRCM_IN_SpW_ADDR_FIFO_wr_en_o      => s_Controller_IN_SpW_ADDR_FIFO_wr_en,
        cPRCM_IN_SpW_ADDR_FIFO_data_o       => s_Controller_IN_SpW_ADDR_FIFO_data,

        -- OUT SpW ADDR FIFO signals
        cPRCM_OUT_SpW_ADDR_FIFO_rd_en_o     => s_Controller_OUT_SpW_ADDR_FIFO_rd_en,

        -- Agent Read signals
        cPRCM_avalon_read_rd_regs_o         => s_Controller_Avalon_Read_rd_regs, 

        -- Agent Write signals
        cPRCM_agent_write_wr_regs_o         => s_Controller_Avalon_Write_feedback_wr_regs,

        -- IRQ Controller signals
        cPRCM_IRQ_controller_wr_regs_o          => s_Controller_IRQ_Controller_wr_regs,
        cPRCM_IRQ_controller_recv_IRQ_trigger_o => s_Controller_IRQ_Controller_recv_IRQ_trigger,
        cPRCM_IRQ_controller_send_IRQ_trigger_o => s_Controller_IRQ_Controller_send_IRQ_trigger, 

        -- CCSDS in signals
        cPRCM_CCSDS_in_rst_o       => s_Controller_CCSDS_in_rst,  
        cPRCM_CCSDS_in_rst_value_o => s_Controller_CCSDS_in_rst_value,
        cPRCM_CCSDS_in_mem_offset_o => s_Controller_CCSDS_in_DMA_start_addr,
        cPRCM_CCSDS_in_fifo_size_o  => s_Controller_CCSDS_in_DMA_num_bytes,
        
        -- CCSDS out signals
        cPRCM_CCSDS_out_mem_offset_o => s_Controller_CCSDS_out_DMA_start_addr,
        cPRCM_CCSDS_out_fifo_size_o  => s_Controller_CCSDS_out_DMA_num_bytes,

        -- General reset signal for the inner parts of the Codec PUS
        cPRCM_gen_proc_rst_o         => s_Controller_gen_proc_rst,

        -- SpW Adapter signals
        cPRCM_external_proto_cfg_spw_addr_o => s_Controller_SpW_adapter_SpW_node_ADDR
    );

-- Instantiation of the Avalon Write module.
Avalon_Write : codec_PUS_Avalon_Write
    port map (
        -- Input Signals --

        -- Reset and clock signals
        clk_i                        => clk_i,
        rst_i                        => rst_sync_i,

        -- Avalon Interface Input Signals
        cPAW_avalon_mm_write_i       => avalon_mm_agent_write_i,
        cPAW_avalon_mm_address_i     => s_avalon_mm_addr_padding_signal,
        cPAW_avalon_mm_write_data_i  => avalon_mm_agent_write_data_i,

        -- Write registers from the Controller module
        cPAW_controller_wr_regs_i    => s_Controller_Avalon_Write_feedback_wr_regs,

        -- Output Signals --

        -- Write registers for the Controller module
        cPAW_controller_wr_regs      => s_Controller_Avalon_Write_wr_regs,

        -- Write flag for the Controller module
        cPAW_controller_wr_flag      => s_Controller_Avalon_Write_wr_flag,

        -- Avalon MM Interface Output Signals
        cPAW_avalon_mm_wait_request_o=> s_avalon_mm_agent_write_wait_request
    );

-- Instantiation of the Avalon Read module.
Avalon_Read : codec_PUS_Avalon_Read
    port map (
        -- Input Signals --

        -- Reset and clock signals
        clk_i                   => clk_i,
        rst_i                   => rst_sync_i,

        -- Avalon MM Interface Input Signals
        cPAR_avalon_mm_read_i    => avalon_mm_agent_read_i,
        cPAR_avalon_mm_address_i => s_avalon_mm_addr_padding_signal,

        -- Write and Read Registers from the Controller
        cPAR_controller_rd_regs  => s_Controller_Avalon_Read_rd_regs,

        -- Output Signals --

        -- Avalon MM Interface Output Signals
        cPAR_avalon_mm_read_data_o    => avalon_mm_agent_read_data_o,
        cPAR_avalon_mm_wait_request_o => s_avalon_mm_agent_read_wait_request
    );

-- Instanciação do módulo CRC16CITT para o caminho de entrada (CCSDS in)
CRC_in: codec_PUS_CRC16CITT_module
    generic map(
        -- CRC16 Inicial
        g_crc_init => C_CRC16CITT_INIT
    )
    port map (
        clk_i        => clk_i,
        rst_sync_i   => s_CCSDS_in_CRC16_rst,
        CRC16_data_i => s_CCSDS_in_CRC16_data,
        CRC16_en_i   => s_CCSDS_in_CRC16_en,
        CRC16_out_o  => s_CCSDS_in_CRC16_crc
    );

-- Instanciação do módulo CRC16CITT para o caminho de saída (CCSDS out)
CRC_out: codec_PUS_CRC16CITT_module
    generic map(
        -- CRC16 Inicial
        g_crc_init => C_CRC16CITT_INIT
    )
    port map (
        clk_i        => clk_i,
        rst_sync_i   => s_CCSDS_out_CRC16_rst,
        CRC16_data_i => s_CCSDS_out_CRC16_data,
        CRC16_en_i   => s_CCSDS_out_CRC16_en,
        CRC16_out_o  => s_CCSDS_out_CRC16_crc
    );

-- Instantiation of the IRQ Controller module
IRQ_Controller : codec_PUS_IRQ_Controller
    port map (
        clk_i      => clk_i,
        rst_sync_i => rst_sync_i,

        cPIC_controller_wr_regs_i          => s_Controller_IRQ_Controller_wr_regs,
        cPIC_controller_recv_IRQ_trigger_i => s_Controller_IRQ_Controller_recv_IRQ_trigger,
        cPIC_controller_send_IRQ_trigger_i => s_Controller_IRQ_Controller_send_IRQ_trigger,

        cPIC_avalon_IRQ_recv_IRQ_o => IRQ_send_recv_o,
        cPIC_avalon_IRQ_send_IRQ_o => IRQ_send_send_o
    );

-- Instantiation of the SpW Adapter module
SpW_Adapter : codec_PUS_SpW_Adapter
    port map(
        -- Input Signals --

        -- Clock and Reset
        clk_i        => clk_i,
        rst_sync_i   => s_comb_rst,

        -- Input signals from the CCSDS In module
        cPSa_CCSDS_in_rd_en_i => s_SpW_adapter_CCSDS_in_rd_en,

        -- Input signals from the CCSDS Out module
        cPSa_CCSDS_out_data_i    => s_SpW_adapter_CCSDS_out_data,
        cPSa_CCSDS_out_end_pkg_i => s_SpW_adapter_CCSDS_out_end_pkg,
        cPSa_CCSDS_out_wr_en_i   => s_SpW_adapter_CCSDS_out_wr_en,

        -- Input signals from the Registers and Controller Module
        cPSa_controller_SpW_node_ADDR_i => s_Controller_SpW_adapter_SpW_node_ADDR,

        -- Input signals from the OUT SpW ADDR FIFO module
        cPSa_OUT_SpW_ADDR_FIFO_full_i        => s_SpW_adapter_OUT_SpW_ADDR_FIFO_full,
        cPSa_OUT_SpW_ADDR_FIFO_almost_full_i => s_SpW_adapter_OUT_SpW_ADDR_FIFO_almost_full,
        cPSa_OUT_SpW_ADDR_FIFO_txrdy_i       => s_SpW_adapter_OUT_SpW_ADDR_FIFO_txrdy,

        -- Input signals from the IN SpW ADDR FIFO module
        cPSa_IN_SpW_ADDR_FIFO_data_i         => s_SpW_adapter_IN_SpW_ADDR_FIFO_data,
        cPSa_IN_SpW_ADDR_FIFO_rxvalid_i      => s_SpW_adapter_IN_SpW_ADDR_FIFO_rxvalid,
        cPSa_IN_SpW_ADDR_FIFO_empty_i        => s_SpW_adapter_IN_SpW_ADDR_FIFO_empty,
        cPSa_IN_SpW_ADDR_FIFO_almost_empty_i => s_SpW_adapter_IN_SpW_ADDR_FIFO_almost_empty,

        -- Input signals from the SpW Connecter module
        cPSa_SpW_connecter_data_in_i         => conduit_inFIFO_data_i,
        cPSA_SpW_connecter_flag_in_i         => conduit_inFIFO_flag_i,
        cPSA_SpW_connecter_empty_in_i        => conduit_inFIFO_empty_i,
        cPSA_SpW_connecter_almost_empty_in_i => conduit_inFIFO_almost_empty_i,
        cPSA_SpW_connecter_rxvalid_in_i      => conduit_inFIFO_rxvalid_i,

        cPSa_SpW_connecter_full_out_i        => conduit_outFIFO_full_i,
        cPSa_SpW_connecter_almost_full_out_i => conduit_outFIFO_almost_full_i,
        cPSa_SpW_connecter_txrdy_out_i       => conduit_outFIFO_txrdy_i,

        -- Output Signals --

        -- Output signals to the CCSDS In module
        cPSa_CCSDS_in_data_o         => s_SpW_adapter_CCSDS_in_data,
        cPSa_CCSDS_in_end_pkg_o      => s_SpW_adapter_CCSDS_in_end_pkg,
        cPSA_CCSDS_in_rxvalid_o      => s_SpW_adapter_CCSDS_in_rxvalid,
        cPSa_CCSDS_in_empty_o        => s_SpW_adapter_CCSDS_in_empty,
        cPSa_CCSDS_in_almost_empty_o => s_SpW_adapter_CCSDS_in_almost_empty,

        -- Output signals to the CCSDS Out module
        cPSa_CCSDS_out_full_o        => s_SpW_adapter_CCSDS_out_full,
        cPSa_CCSDS_out_almost_full_o => s_SpW_adapter_CCSDS_out_almost_full,
        cPSa_CCSDS_out_txrdy_o       => s_SpW_adapter_CCSDS_out_txrdy,

        -- Output signals to the OUT SpW ADDR FIFO module
        cPSa_OUT_SpW_ADDR_FIFO_data_o   => s_SpW_adapter_OUT_SpW_ADDR_FIFO_data,
        cPSa_OUT_SpW_ADDR_FIFO_wr_en_o  => s_SpW_adapter_OUT_SpW_ADDR_FIFO_wr_en,

        -- Output signals to the IN SpW ADDR FIFO module
        cPSa_IN_SpW_ADDR_FIFO_rd_en_o => s_SpW_adapter_IN_SpW_ADDR_FIFO_rd_en,

        -- Output signals to the SpW connecter module
        cPSa_SpW_connecter_rd_en_in_o => conduit_inFIFO_rd_en_o,
        cPSa_SpW_connecter_data_out_o  => conduit_outFIFO_data_o,
        cPSa_SpW_connecter_flag_out_o  => conduit_outFIFO_flag_o,
        cPSa_SpW_connecter_wr_en_out_o => conduit_outFIFO_wr_en_o
    );

-- Instantiation of the IN SpW ADDR FIFO module
IN_SpW_ADDR_FIFO: codec_PUS_SpW_ADDR_FIFO
    generic map(
        c_cPSAF_LENGTH => C_CPSAF_FIFO_DEPTH
    )
    port map(
        -- Clock and Reset
        clk_i        => clk_i,
        rst_sync_i   => s_comb_rst,

        -- FIFO Write Interface (Codec PUS side)
        cPSAF_wr_en_i => s_Controller_IN_SpW_ADDR_FIFO_wr_en,
        cPSAF_data_i  => s_Controller_IN_SpW_ADDR_FIFO_data,

        -- FIFO Read Interface (SpaceWire side)
        cPSAF_rd_en_i => s_SpW_adapter_IN_SpW_ADDR_FIFO_rd_en,

        -- FIFO Status Outputs
        cPSAF_empty_o         => s_SpW_adapter_IN_SpW_ADDR_FIFO_empty,
        cPSAF_almost_empty_o  => s_SpW_adapter_IN_SpW_ADDR_FIFO_almost_empty,
        cPSAF_txrdy_o         => s_Controller_IN_SpW_ADDR_FIFO_txrdy,
        cPSAF_full_o          => s_Controller_IN_SpW_ADDR_FIFO_full,
        cPSAF_almost_full_o   => s_Controller_IN_SpW_ADDR_FIFO_almost_full,
        cPSAF_data_o          => s_SpW_adapter_IN_SpW_ADDR_FIFO_data,
        cPSAF_rxvalid_o       => s_SpW_adapter_IN_SpW_ADDR_FIFO_rxvalid
    );

-- Instantiation of the OUT SpW ADDR FIFO module
OUT_SpW_ADDR_FIFO: codec_PUS_SpW_ADDR_FIFO
    generic map(
        c_cPSAF_LENGTH => C_CPSAF_FIFO_DEPTH
    )
    port map(
        -- Clock and Reset
        clk_i        => clk_i,
        rst_sync_i   => s_comb_rst,

        -- FIFO Write Interface (Codec PUS side)
        cPSAF_wr_en_i => s_SpW_adapter_OUT_SpW_ADDR_FIFO_wr_en,
        cPSAF_data_i  => s_SpW_adapter_OUT_SpW_ADDR_FIFO_data,

        -- FIFO Read Interface (SpaceWire side)
        cPSAF_rd_en_i => s_Controller_OUT_SpW_ADDR_FIFO_rd_en,

        -- FIFO Status Outputs
        cPSAF_empty_o         => s_Controller_OUT_SpW_ADDR_FIFO_empty,
        cPSAF_almost_empty_o  => s_Controller_OUT_SpW_ADDR_FIFO_almost_empty,
        cPSAF_txrdy_o         => s_SpW_adapter_OUT_SpW_ADDR_FIFO_txrdy,
        cPSAF_full_o          => s_SpW_adapter_OUT_SpW_ADDR_FIFO_full,
        cPSAF_almost_full_o   => s_SpW_adapter_OUT_SpW_ADDR_FIFO_almost_full,
        cPSAF_data_o          => s_Controller_OUT_SpW_ADDR_FIFO_data,
        cPSAF_rxvalid_o       => s_Controller_OUT_SpW_ADDR_FIFO_rxvalid
    );

-- Combined reset signal for the inner parts of the Codec PUS
s_comb_rst <= rst_sync_i or s_Controller_gen_proc_rst;

-- Logic for the wait request for the Avalon MM Agent Interface (AND gate between the wait request signals)
avalon_mm_agent_wait_request_o <= s_avalon_mm_agent_read_wait_request and s_avalon_mm_agent_write_wait_request;

-- Process for regulating the read and write concomitant operations for the CCSDS In and Out Modules
p_arbitrate_avalon_mm_master : process(clk_i, rst_sync_i) is
begin

    -- If a rising edge of clock is detected
    if rising_edge(clk_i) then

        -- Rst operation for the module
        if rst_sync_i = '1' then

            -- Resets the avalon mm master last operation and prev operation
            s_avalon_mm_master_last_operation <= NONE;
            s_avalon_mm_master_prev_operation <= WRITE;

        -- Normal operation for the module
        else

            -- Switch case for the avalon mm master last operation
            case s_avalon_mm_master_last_operation is

                when READ =>

                    -- If the read operation is done, then it can be set to NONE
                    if s_aux_avalon_mm_master_read_o = '1' and avalon_mm_master_wait_request_i = '0' then
                        s_avalon_mm_master_last_operation <= NONE;
                    end if;

                    -- Updates the prev operation to READ
                    s_avalon_mm_master_prev_operation <= READ;

                when WRITE =>

                    -- If the write operation is done, then it can be set to NONE
                    if s_aux_avalon_mm_master_write_o = '1' and avalon_mm_master_wait_request_i = '0' then
                        s_avalon_mm_master_last_operation <= NONE;
                    end if;

                    -- Updates the prev operation to WRITE
                    s_avalon_mm_master_prev_operation <= WRITE;

                when NONE =>

                    if s_avalon_mm_master_prev_operation = WRITE then

                        -- If no operation is ongoing, check for a new operation
                        if s_aux_avalon_mm_master_read_o = '1' then

                            -- Designates the addr and wait request to the read operation
                            s_avalon_mm_master_last_operation <= READ;

                        elsif s_aux_avalon_mm_master_write_o = '1' then
                            
                            -- Designates the addr and wait request to the write operation
                            s_avalon_mm_master_last_operation <= WRITE;

                        end if;

                    elsif s_avalon_mm_master_prev_operation = READ then

                        -- If no operation is ongoing, check for a new operation
                        if s_aux_avalon_mm_master_write_o = '1' then

                            -- Designates the addr and wait request to the write operation
                            s_avalon_mm_master_last_operation <= WRITE;

                        elsif s_aux_avalon_mm_master_read_o = '1' then
                            
                            -- Designates the addr and wait request to the read operation
                            s_avalon_mm_master_last_operation <= READ;

                        end if;

                    end if;

            end case;
        end if;
    end if;
end process p_arbitrate_avalon_mm_master;

-- Combinational logic, based on the states of the previous process, to set the wait request signals.
with s_avalon_mm_master_last_operation select
    -- Set the wait request signals based on the last operation
    s_avalon_mm_master_read_wait_request <= avalon_mm_master_wait_request_i when READ,
                                           '1' when others;

with s_avalon_mm_master_last_operation select
    -- Set the wait request signals based on the last operation
    s_avalon_mm_master_write_wait_request <= avalon_mm_master_wait_request_i when WRITE,
                                            '1' when others;

-- Combinational logic to set the read and write signals for the Avalon MM Master
with s_avalon_mm_master_last_operation select
    -- Set the read signal based on the last operation
    avalon_mm_master_read_o <= s_aux_avalon_mm_master_read_o when READ,
                               '0' when others;

with s_avalon_mm_master_last_operation select
    -- Set the read signal based on the last operation
    avalon_mm_master_write_o <= s_aux_avalon_mm_master_write_o when WRITE,
                               '0' when others;

-- Select the addr signals
with s_avalon_mm_master_last_operation select
    -- Set the addr signal based on the last operation
    avalon_mm_master_addr_o <= s_avalon_mm_master_read_addr when READ,
                               s_avalon_mm_master_write_addr when WRITE,
                               (others => '0') when others;


-- Pads the signal received from the avalon mm agent address input
s_avalon_mm_addr_padding_signal <= "000000000000000000000000000" & avalon_mm_agent_addr_i;


        


----------------------------------------------------------------------------------------------------

end architecture rtl;

----------------------------------------------------------------------------------------------------