---------------------------------------------------------------------------------------------------------
-- codec_PUS_Receiver_Transmitter_main_pkg.vhd
-- Author: Luiz H. A. Santos
-- Date: 2024-09-12
-- Description: This file contains all the important types and constants reharding the entities declared
-- into the Receiver_Transmitter module.
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Pacotes

package codec_PUS_main_pkg is

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    ---- Types and constants important to the entire Codec PUS --

    -- Constants for defining the codec PUS APID
    constant C_CODEC_PUS_APID : std_logic_vector(10 downto 0) := "00000000000"; -- TODO: Define the APID for the codec PUS based on the mission's requirements
    constant C_CODEC_PUS_MAIN_DEST_ID : std_logic_vector(15 downto 0) := "0000000000000000"; -- TODO: Define the destination ID for the codec PUS based on the mission's requirements

    -- Constants for defining the Codec PUS number of channels and services
    constant C_CODEC_PUS_NUM_CHANNELS : natural := 2;
    constant C_CODEC_PUS_NUM_SERVICES : natural := 256;

    -- Constant for defining the width of the Avalon MM address and data buses
    constant C_CODEC_PUS_AVALON_ADDR_WIDTH : integer := 32;
    constant C_CODEC_PUS_AVALON_DATA_WIDTH : integer := 32;

    -- Constant for defining the available Services for the Codec PUS
    constant C_CODEC_PUS_AVAILABLE_SERVICES : std_logic_vector(C_CODEC_PUS_NUM_SERVICES - 1 downto 0) := (0 => '1', others => '0');

    -- Constant for defining the data width for the SpW Codecs
    constant C_CODEC_PUS_SPW_DATA_WIDTH : integer := 8;


    ----------------------------------------------------------------------------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    ---- Tipos e constantes importantes para o Codec_PUS_Receiver_Transmitter_CCSDS_In --

    -------------------------------------------------------------------------------------
    -- Aliases importantes para o módulo --

    -- Important constants for defining the number of channels and services
    alias C_CCSDS_IN_MAX_CHANNELS is C_CODEC_PUS_NUM_CHANNELS;
    alias C_CCSDS_IN_MAX_SERVICES is C_CODEC_PUS_NUM_SERVICES;

    -- Important constants for defining the width of the Avalon MM address and data buses
    alias C_CCSDS_IN_AVALON_ADDR_WIDTH is C_CODEC_PUS_AVALON_ADDR_WIDTH;
    alias C_CCSDS_IN_AVALON_DATA_WIDTH is C_CODEC_PUS_AVALON_DATA_WIDTH;

    -- Important constants for defining the available Services for the Codec PUS
    alias C_CCSDS_IN_AVAILABLE_SERVICES is C_CODEC_PUS_AVAILABLE_SERVICES;

    -- Alias for determining the PROC_RST_VALUE_WIDTH based on the avalon data field
    alias C_CCSDS_IN_PROC_RST_VALUE_WIDTH is C_CCSDS_IN_AVALON_DATA_WIDTH;

    -- Alias for determining the data width of the SpW Codecs
    alias C_CCSDS_DATA_WIDTH is C_CODEC_PUS_SPW_DATA_WIDTH;

    -- Constants for determining the signals width
    constant C_CCSDS_IN_STATUS_FLAGS_WIDTH  : integer := 8;
    constant C_CCSDS_IN_CNTRL_FLAGS_WIDTH : integer := 8;

    constant C_CCSDS_IN_IRQ_WIDTH         : integer := 8;

    constant C_CCSDS_IN_APID_WIDTH        : integer := 11;

    constant C_CCSDS_IN_DATA_REG_WIDTH    : integer := 48;

    constant C_CCSDS_IN_PROC_RST_SERVICE_WIDTH : integer := 8;

    -- Constante para determinação do PKG_USR_DATA_WIDTH (em bytes)
    constant C_CCSDS_IN_PKG_USR_DATA_WIDTH : integer := 512; --65536 * 8;

    -- Constante para determinação do tamanho da memória a ser ocupada por cada CCSDS_In
    constant C_CCSDS_IN_AVALON_SECTOR_MEM_SIZE    : integer := 16#00001000#;

    -- Constante para determinação do tamanho de memória a ser ocupada por cada serviço
    constant C_CCSDS_IN_AVALON_SERVICE_MEM_SIZE   : integer := 16#00001000#;

    -- Constantes para determinação dos tamanhos de cada campo do packet primary header
    constant C_CCSDS_IN_PKG_PRIM_HDR_PKG_VERNUM_WIDTH : integer := 3;
    constant C_CCSDS_IN_PKG_PRIM_HDR_TYPE             : integer := 1;
    constant C_CCSDS_IN_PKG_PRIM_HDR_SEC_HDR_FLAG     : integer := 1;
    constant C_CCSDS_IN_PKG_PRIM_HDR_APID             : integer := 11;
    constant C_CCSDS_IN_PKG_PRIM_HDR_SEQ_FLAGS        : integer := 2;
    constant C_CCSDS_IN_PKG_PRIM_HDR_SEQ_COUNT        : integer := 14;
    constant C_CCSDS_IN_PKG_PRIM_HDR_PKG_DATA_LEN     : integer := 16;

    -- Constantes para determinação dos tamanhos de cada campo do packet secondary header
    constant C_CCSDS_IN_PKG_SEC_HDR_PUSVNUM_WIDTH : integer := 4;
    constant C_CCSDS_IN_PKG_SEC_HDR_ACK_FLAGS     : integer := 4;
    constant C_CCSDS_IN_PKG_SEC_HDR_SERVICE_ID    : integer := 8;
    constant C_CCSDS_IN_PKG_SEC_HDR_SUBSERVICE_ID : integer := 8;
    constant C_CCSDS_IN_PKG_SEC_HDR_SOURCE_ID     : integer := 16;

    -- Constantes de registradores e tipos de erros
    subtype t_CCSDS_In_status_flags_vector is std_logic_vector(C_CCSDS_IN_STATUS_FLAGS_WIDTH - 1 downto 0);
    type t_CCSDS_In_status_flags is (NO_ERROR, PKG_PRIM_HDR_VER_NUM_ERROR, PKG_PRIM_HDR_TYPE_ERROR, PKG_PRIM_HDR_SEC_HDR_FLAG_ERROR, PKG_PRIM_HDR_SEQ_ERROR, PKG_SEC_HDR_PUSVNUM_ERROR, PKG_SEC_HDR_SERVICE_ID_ERROR, CRC16_ERROR, EOP_ERROR);

    function f_ver_flags_to_std_logic_vector_mask(ver_flags_reg : t_CCSDS_In_status_flags_vector; ver_flags : t_CCSDS_In_status_flags) return t_CCSDS_In_status_flags_vector;

    subtype t_CCSDS_In_cntrl_flags_vector is std_logic_vector(C_CCSDS_IN_CNTRL_FLAGS_WIDTH - 1 downto 0);

    
    -- Constantes para verificação de tipos arbitrários
    constant C_CCSDS_IN_PKG_VER_NUM  : std_logic_vector(2 downto 0) := "000";
    constant C_CCSDS_IN_PKG_TYPE     : std_logic                    := '1';
    constant C_CCSDS_IN_PKG_SEC_HDR_FLAG : std_logic                    := '1';
    constant C_CCSDS_IN_SEC_HDR_FLAG : std_logic                    := '1';
    constant C_CCSDS_IN_SEQ_FLAGS    : std_logic_vector(1 downto 0) := "11";
    constant C_CCSDS_IN_PKG_PUSVNUM  : std_logic_vector(3 downto 0) := "0010";


    --------------------------------------------------------------------------
    ---- Tipos e subtipos --
    type t_codec_PUS_Receiver_Transmitter_CCSDS_in_states is (RESET, IDLE, RECEIVING_I, INTERPRETING_I, RECEIVING_II, INTERPRETING_II, TRANSFERING, INTERPRETING_III, WAITING_FOR_TRANSMISSION);
    type t_codec_PUS_Receiver_Transmitter_CCSDS_in_wAvalon_states is (RESET, IDLE, RECEIVING_I, INTERPRETING_I, RECEIVING_II, INTERPRETING_II, ACCUMULATING, RESETING_MEM, TRANSFERING, ACCUMULATING_CRC, INTERPRETING_III, WAITING_FOR_TRANSMISSION, RESTART);

    type t_codec_PUS_Receiver_Transmitter_CCSDS_Out_states is (RESET, IDLE, TRANSMITING_I, TRANSMITING_II, TRANSMITING_III, TRANSMITING_CRC);


    -- Declaração de tipos relacionados à FIFO de entrada do CCSDS
    type t_CCSDS_In_FIFO_status_in_i is record
        empty : std_logic;
        almost_empty : std_logic;
        rxvalid : std_logic;
    end record t_CCSDS_In_FIFO_status_in_i;

    type t_CCSDS_In_FIFO_data_in_i is record
        data : std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
    end record t_CCSDS_In_FIFO_data_in_i;

    type t_CCSDS_In_FIFO_control_in_o is record
        read_en : std_logic;
    end record t_CCSDS_In_FIFO_control_in_o;

    type t_CCSDS_In_FIFO_in is record
        status : t_CCSDS_In_FIFO_status_in_i;
        data : t_CCSDS_In_FIFO_data_in_i;
        control : t_CCSDS_In_FIFO_control_in_o;
    end record t_CCSDS_In_FIFO_in;

    -- Declaração de tipos relacionados ao CRC16
    type t_CCSDS_In_CRC16_cntrl_out_o is record
        en : std_logic;
        rst_sync : std_logic;
    end record t_CCSDS_In_CRC16_cntrl_out_o;

    type t_CCSDS_In_CRC16_data_out_o is record
        data : std_logic_vector(C_CCSDS_DATA_WIDTH - 1 downto 0);
    end record t_CCSDS_In_CRC16_data_out_o;

    type t_CCSDS_In_CRC16_crc_in_i is record
        crc : std_logic_vector(15 downto 0);
    end record t_CCSDS_In_CRC16_crc_in_i;

    type t_CCSDS_In_CRC16 is record
        cntrl : t_CCSDS_In_CRC16_cntrl_out_o;
        data : t_CCSDS_In_CRC16_data_out_o;
        crc : t_CCSDS_In_CRC16_crc_in_i;
    end record t_CCSDS_In_CRC16;

    -- Declaração de tipos relacionados ao registrador de APID
    type t_CCSDS_In_APID_in_i is record
        apid : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_APID - 1 downto 0);
    end record t_CCSDS_In_APID_in_i;

    -- Declaração de tipo relacionado ao registrador de controle
    type t_CCSDS_In_flags_in_i is record
        cntrl_flags : std_logic_vector(C_CCSDS_IN_CNTRL_FLAGS_WIDTH - 1 downto 0);
    end record t_CCSDS_In_flags_in_i;

    -- Declaração de tipo relacionado aos dados do registrador de status
    type t_CCSDS_In_flags_out_o is record
        ver_flags : std_logic_vector(C_CCSDS_IN_STATUS_FLAGS_WIDTH - 1 downto 0);
    end record t_CCSDS_In_flags_out_o;

    -- Declaração de tipo relacionado aos dados do registrador de IRQ
    type t_CCSDS_In_IRQ_out_o is record
        data : std_logic_vector(C_CCSDS_IN_IRQ_WIDTH - 1 downto 0);
    end record t_CCSDS_In_IRQ_out_o;

    -- Declaração de tipo relacionado aos dados do registrador de PKG PRIM HEADER
    type t_CCSDS_In_PKG_PRIM_HDR_out_o is record
        pkg_vernum : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_PKG_VERNUM_WIDTH - 1 downto 0);--3
        pkg_type : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_TYPE - 1 downto 0);--1
        sec_hdr_flag : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_SEC_HDR_FLAG - 1 downto 0);--1
        apid : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_APID - 1 downto 0);--11
        seq_flags : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_SEQ_FLAGS - 1 downto 0);--2
        seq_count : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_SEQ_COUNT - 1 downto 0);--14
        pkg_data_len : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_PKG_DATA_LEN - 1 downto 0);--16
    end record t_CCSDS_In_PKG_PRIM_HDR_out_o;

    -- Declaração de tipo relacionado aos dados do registrador de PKG SEC HEADER
    type t_CCSDS_In_PKG_SEC_HDR_out_o is record
        pusvnum : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_PUSVNUM_WIDTH - 1 downto 0);--4
        ack_flags : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_ACK_FLAGS - 1 downto 0);--4
        service_id : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_SERVICE_ID - 1 downto 0);--8
        subservice_id : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_SUBSERVICE_ID - 1 downto 0);--8
        source_id : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_SOURCE_ID - 1 downto 0);--16
    end record t_CCSDS_In_PKG_SEC_HDR_out_o;

    -- Type related to the data to be transmitted by the module to the output FIFO
    type t_CCSDs_in_FIFO_data_out is record
        PKG_PRIM_HDR : t_CCSDS_In_PKG_PRIM_HDR_out_o;
        PKG_SEC_HDR  : t_CCSDS_In_PKG_SEC_HDR_out_o;
        status_flags : t_CCSDS_In_flags_out_o;
        PKG_addr     : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_CCSDs_in_FIFO_data_out;

    -- Declaração de tipo relacionado aos sinais Avalon de saída do módulo
    type t_CCSDS_In_AVALON_out_o is record
        addr         : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
        write        : std_logic;
        write_data   : std_logic_vector(C_CCSDS_IN_AVALON_DATA_WIDTH - 1 downto 0);
        wait_request : std_logic;
    end record t_CCSDS_In_AVALON_out_o;

    -- Declaração de tipo relacionado ao aos sinais de reset parcial da memória do módulo
    type t_CCSDS_In_PROC_rst_mem_i is record
        rst_value : std_logic_vector(C_CCSDS_IN_PROC_RST_VALUE_WIDTH - 1 downto 0);
    end record t_CCSDS_In_PROC_rst_mem_i;

    -- Tipo relacionado ao tamanho máximo do número de bytes a serem recebidos
    subtype t_CCSDS_In_max_recv_bytes is natural range 0 to 65536 + 8;


    -- Tipk relacionado ao tamanho máximo do número de bytes a serem recebidos, sem processamento
    subtype t_CCSDS_In_max_stored_bytes is natural range 0 to (65536 + 8)*8;

    -- Subtipo relacionado aos serviços disponíveis
    subtype t_CCSDS_In_services_available is natural range 0 to 255;



    --------------------------------------------------------------------------
    ---- Constantes de RESET importantes aos registradores de saída do CCSDS_In --
    -- Constante de RESET para o registrador de status
    constant C_CCSDS_In_flags_out_reset : t_CCSDS_In_flags_out_o := (
        ver_flags => (others => '0')
    );

    -- Constante de RESET para o registrador de PKG PRIM HEADER
    constant C_CCSDS_In_PKG_PRIM_HDR_out_reset : t_CCSDS_In_PKG_PRIM_HDR_out_o := (
        pkg_vernum => (others => '0'),
        pkg_type => (others => '0'),
        apid => (others => '0'),
        sec_hdr_flag => (others => '0'),
        seq_flags => (others => '0'),
        seq_count => (others => '0'),
        pkg_data_len => (others => '0')
    );

    -- Constante de RESET para o registrador de PKG SEC HEADER
    constant C_CCSDS_In_PKG_SEC_HDR_out_reset : t_CCSDS_In_PKG_SEC_HDR_out_o := (
        pusvnum => (others => '0'),
        ack_flags => (others => '0'),
        service_id => (others => '0'),
        subservice_id => (others => '0'),
        source_id => (others => '0')
    );

    -- Constante de RESET para a FIFO de saída do CCSDS_In
    constant C_CCSDs_in_FIFO_data_out_reset : t_CCSDs_in_FIFO_data_out := (
        PKG_PRIM_HDR => C_CCSDS_In_PKG_PRIM_HDR_out_reset,
        PKG_SEC_HDR => C_CCSDS_In_PKG_SEC_HDR_out_reset,
        status_flags => C_CCSDS_In_flags_out_reset,
        PKG_addr => (others => '0')
    );

    -- Constante de RESET para o registrador de IRQ
    constant C_CCSDS_In_IRQ_out_reset : t_CCSDS_In_IRQ_out_o := (
        data => (others => '0')
    );

    -- Constante de RESET para o sinal registrador de requisições de RESET
    constant C_CCSDS_In_PROC_rst_mem_reset : t_CCSDS_In_PROC_rst_mem_i := (
            rst_value => (others => '0')
        
    );

    

    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    -- Tipos e constantes importantes para o CRC16CITT

    -- Constantes de largura de sinais
    constant C_CRC16CITT_WIDTH      : integer := 16;
    constant C_CRC16CITT_INIT       : std_logic_vector(C_CRC16CITT_WIDTH - 1 downto 0) := X"FFFF";
    constant C_CRC16CITT_DATA_WIDTH : integer := 8;
        
    
    ----------------------------------------------------------------------------------------------------------------------------------------------------
    ---- Types, constants and aliases important for the CCSDS Out module

    -- Important aliases for the module --

    -- Alias for defining the width of the ADDR of the Avalon MM interface
    alias C_cPRTCo_AVALON_ADDR_WIDTH is C_CODEC_PUS_AVALON_ADDR_WIDTH;

    -- Alias for determining important signals widths
    alias c_cPRTCo_CRC16_DATA_WIDTH is C_CRC16CITT_DATA_WIDTH;
    alias c_cPRTCo_CRC16_CRC_WIDTH is C_CRC16CITT_WIDTH;

    alias c_cPRTCo_AVALON_MM_DATA_WIDTH is C_CODEC_PUS_AVALON_DATA_WIDTH;
    alias c_cPRTCo_AVALON_MM_ADDR_WIDTH is C_CODEC_PUS_AVALON_ADDR_WIDTH;

    alias c_cPRTCo_CCSDS_RST_VALUE_WIDTH is C_CCSDS_IN_AVALON_DATA_WIDTH;

    alias c_cPRTCo_SPW_DATA_WIDTH is C_CODEC_PUS_SPW_DATA_WIDTH;


    -- Important constants for the module --

    -- Constants for the width of the PKG_PRIM_HDR field
    constant c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH : integer := 11;
    constant c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH : integer := 14;
    constant c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH : integer := 16;

    -- Constants for the width of the PKG_SEC_HDR field
    constant c_cPRTCo_PKG_SEC_HDR_SPACECRAFT_TIME_REFERENCE_WIDTH : integer := 4;
    constant c_cPRTCo_PKG_SEC_HDR_SERVICE_ID_WIDTH : integer := 8;
    constant c_cPRTCo_PKG_SEC_HDR_SUBSERVICE_ID_WIDTH : integer := 8;
    constant c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH : integer := 16;
    constant c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH : integer := 16;
    constant c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH : integer := 16;

    -- Constant for defining the size of the std_logic_vector that will be used to store the PUS channel
    constant C_cPRTCo_PUS_CHANNEL_WIDTH : natural := 8;

    -- Constants for defining arbitrary output fields and values
    constant c_cPRTCo_PKG_VER_NUM_VAL  : std_logic_vector(2 downto 0) := "000";
    constant c_cPRTCo_PKG_TYPE_VAL     : std_logic                    := '0';
    constant c_cPRTCo_SEC_HDR_FLAG_VAL : std_logic                    := '1';
    constant c_cPRTCo_SEQ_FLAGS_VAL    : std_logic_vector(1 downto 0) := "11";
    constant c_cPRTCo_PKG_PUSVNUM_VAL  : std_logic_vector(3 downto 0) := "0010";


    -- Important types and subtypes for the module --

    -- Type for defining the PKG_PRIM_HDR
    type t_cPRTCo_PKG_PRIM_HDR_in is record
        apid : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 1 downto 0);--11
        pkg_data_len : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 1 downto 0);--16
    end record t_cPRTCo_PKG_PRIM_HDR_in;

    -- Type for defining the PKG_SEC_HDR
    type t_cPRTCo_PKG_SEC_HDR_in is record
        spacecraft_time_ref : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_SPACECRAFT_TIME_REFERENCE_WIDTH - 1 downto 0);--4
        service_id : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_SERVICE_ID_WIDTH - 1 downto 0);--8
        subservice_id : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_SUBSERVICE_ID_WIDTH - 1 downto 0);--8
        msg_type_counter : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 1 downto 0);--16
        dest_id : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 1 downto 0);--16
        time    : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH - 1 downto 0);--16
    end record t_cPRTCo_PKG_SEC_HDR_in;

     -- Type for defining the PKG_PRIM_HDR output signal, with the addition of the PKG seq count
     type t_cPRTCo_PKG_PRIM_HDR_out is record
        apid : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 1 downto 0);
        seq_count : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 1 downto 0);
        pkg_data_len : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 1 downto 0);
    end record t_cPRTCo_PKG_PRIM_HDR_out;

    -- Type for defining the data output of the module for the waiting FIFO
    type t_cPRTCo_inFIFO_data_in is record
        PKG_PRIM_HDR : t_cPRTCo_PKG_PRIM_HDR_out;
        PKG_SEC_HDR  : t_cPRTCo_PKG_SEC_HDR_in;
        PKG_addr     : std_logic_vector(C_cPRTCo_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_cPRTCo_inFIFO_data_in;

    
    -- Important types and subtypes for the module --
    type t_cPRTCo_states is (RESET, IDLE, TRANSMITTING_I, TRANSMITTING_II, TRANSMITTING_III, TRANSMITTING_CRC, RESTART);
                                                      
    -- Type related to the number of bytes to be received
    subtype t_CCSDS_Out_max_recv_bytes is natural range 0 to 65536;

    
    -- Important RESET constants for the module --

    -- Constant for defining the reset value of the PKG_PRIM_HDR
    constant C_cPRTCo_PKG_PRIM_HDR_out_reset : t_cPRTCo_PKG_PRIM_HDR_out := (
        apid => (others => '0'),
        seq_count => (others => '0'),
        pkg_data_len => (others => '0')
    );

    -- Constant for defining the reset value of the PKG_SEC_HDR
    constant C_cPRTCo_PKG_SEC_HDR_out_reset : t_cPRTCo_PKG_SEC_HDR_in := (
        spacecraft_time_ref => (others => '0'),
        service_id => (others => '0'),
        subservice_id => (others => '0'),
        msg_type_counter => (others => '0'),
        dest_id => (others => '0'),
        time    => (others => '0')
    );

    -- Constant for defining the reset value of the PKG_PRIM_HDR
    constant C_cPRTCo_inFIFO_data_in_reset : t_cPRTCo_inFIFO_data_in := (
        PKG_PRIM_HDR => C_cPRTCo_PKG_PRIM_HDR_out_reset,
        PKG_SEC_HDR => C_cPRTCo_PKG_SEC_HDR_out_reset,
        PKG_addr => (others => '0')
    );


    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types, aliases and constants for the codec_Output_Header_FIFO module

    -- Important aliases for the module
    alias t_cPFo_FIFO_data is t_cPRTCo_inFIFO_data_in;

    constant c_cPFo_DATA_RST : t_cPFo_FIFO_data := C_cPRTCo_inFIFO_data_in_reset;

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types, aliases and constants for the codec_Input_Header_FIFO module

    -- Important aliases for the module
    alias t_cPFi_FIFO_data is t_CCSDs_in_FIFO_data_out;

    constant c_cPFi_DATA_RST : t_cPFi_FIFO_data := C_CCSDs_in_FIFO_data_out_reset;

    -- Important constants 

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types related to the registers of the PUS Codec

    -- Constant for the number of bits of success flags
    constant C_CODEC_PUS_SEND_SUCCESS_FLAGS_WIDTH : integer := 8;

    -- WR Registers --

    -- Control Register
    type t_codec_PUS_control_reg is record
        proc_rst    : std_logic; -- Bit para sinalização de reset do módulo a partir do processador.
        en          : std_logic; -- Habilita o funcionamento do Codec como um todo.
        recv_en     : std_logic; -- Habilita o recebimento a partir do módulo CCSDS In.
        send_en     : std_logic; -- Habilita o envio de informações a partir do CCSDS Out.
        irq_en      : std_logic; -- Habilita interrupções do módulo.
        recv_irq_en : std_logic; -- Habilita interrupções de recebimento.
        send_irq_en : std_logic; -- Habilita interrupções de transmissão.
    end record t_codec_PUS_control_reg;

    -- RD Registers --

    -- Primeiro registrador de PKG_PRIM_HDR de Recebimento (RD)
    type t_codec_PUS_recv_PKG_PRIM_HDR1_reg is record
        pkg_vernum : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_PKG_VERNUM_WIDTH - 1 downto 0);
        pkg_type   : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_TYPE - 1 downto 0);
        sec_hdr_flag : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_SEC_HDR_FLAG - 1 downto 0);
        apid       : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_APID - 1 downto 0);
        seq_flags  : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_SEQ_FLAGS - 1 downto 0);
        seq_count  : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_SEQ_COUNT - 1 downto 0);
    end record t_codec_PUS_recv_PKG_PRIM_HDR1_reg;

    -- Segundo registrador de PKG_PRIM_HDR de Recebimento (RD)
    type t_codec_PUS_recv_PKG_PRIM_HDR2_reg is record
        pkg_data_len : std_logic_vector(C_CCSDS_IN_PKG_PRIM_HDR_PKG_DATA_LEN - 1 downto 0);
    end record t_codec_PUS_recv_PKG_PRIM_HDR2_reg;

    -- Primeiro registrador de PKG_SEC_HDR de Recebimento (RD)
    type t_codec_PUS_recv_PKG_SEC_HDR1_reg is record
        pusvnum      : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_PUSVNUM_WIDTH - 1 downto 0);
        ack_flags    : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_ACK_FLAGS - 1 downto 0);
        service_id   : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_SERVICE_ID - 1 downto 0);
        subservice_id: std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_SUBSERVICE_ID - 1 downto 0);
    end record t_codec_PUS_recv_PKG_SEC_HDR1_reg;

    -- Segundo registrador de PKG_SEC_HDR de Recebimento (RD)
    type t_codec_PUS_recv_PKG_SEC_HDR2_reg is record
        source_id : std_logic_vector(C_CCSDS_IN_PKG_SEC_HDR_SOURCE_ID - 1 downto 0);
    end record t_codec_PUS_recv_PKG_SEC_HDR2_reg;

    -- Registrador de Endereçamento de Pacote de Recebimento (RD)
    type t_codec_PUS_recv_pkg_addr_reg is record
        pkg_addr : std_logic_vector(C_CCSDS_IN_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_codec_PUS_recv_pkg_addr_reg;

    -- Registrador de Status de Pacote de Recebimento (RD)
    type t_codec_PUS_recv_status_reg is record
        status_flags : std_logic_vector(C_CCSDS_IN_STATUS_FLAGS_WIDTH - 1 downto 0);
    end record t_codec_PUS_recv_status_reg;

    -- WR Registers --

    -- Registrador de PKG_PRIM_HDR1 de Envio (WR)
    type t_codec_PUS_send_PKG_PRIM_HDR1_reg is record
        apid         : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_APID_WIDTH - 1 downto 0);
        pkg_data_len : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_PKG_DATA_LEN_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_PKG_PRIM_HDR1_reg;

    -- Registrador de PKG_PRIM_HDR2 de Envio (WR)
    type t_codec_PUS_send_PKG_PRIM_HDR2_reg is record
        seq_count : std_logic_vector(c_cPRTCo_PKG_PRIM_HDR_SEQ_COUNT_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_PKG_PRIM_HDR2_reg;

    -- Primeiro registrador de PKG_SEC_HDR de Envio (WR)
    type t_codec_PUS_send_PKG_SEC_HDR1_reg is record
        spacecraft_time_ref : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_SPACECRAFT_TIME_REFERENCE_WIDTH - 1 downto 0);
        service_id          : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_SERVICE_ID_WIDTH - 1 downto 0);
        subservice_id       : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_SUBSERVICE_ID_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_PKG_SEC_HDR1_reg;

    -- Segundo registrador de PKG_SEC_HDR de Envio (WR)
    type t_codec_PUS_send_PKG_SEC_HDR2_reg is record
        msg_type_counter : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_MSG_TYPE_CONT_WIDTH - 1 downto 0);
        dest_id          : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_DEST_ID_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_PKG_SEC_HDR2_reg;

    -- Terceiro registrador de PKG_SEC_HDR de Envio (WR)
    type t_codec_PUS_send_PKG_SEC_HDR3_reg is record
        time : std_logic_vector(c_cPRTCo_PKG_SEC_HDR_TIME_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_PKG_SEC_HDR3_reg;

    -- Registrador de Endereçamento de pacote de Envio (WR)
    type t_codec_PUS_send_pkg_addr_reg is record
        pkg_addr : std_logic_vector(C_CODEC_PUS_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_pkg_addr_reg;

    -- Registrador de Manipulação (WR*) (virtualmente separado em um de escrita e um de leitura)
    type t_codec_PUS_handling_reg is record
        data_rcv_rdy_flag     : std_logic; -- Sinaliza que o módulo apresenta dados prontos a serem acessados e lidos pelo processador.
        data_rcv_rd_flag      : std_logic; -- Sinalização do processador para informar que os dados de recebimento foram lidos. Retorna automaticamente para 0.
        irq_rcv_clr           : std_logic; -- Bit de limpeza de interrupção de recebimento. Retorna automaticamente para 0.
        data_send_rdy_flag    : std_logic; -- Sinalização do processador para o módulo que dados estão prontos para serem lidos. Retorna para 0 quando módulo realizar a leitura dos dados.
        data_send_wr_flag     : std_logic; -- Sinalização do processador para informar que os dados de envio foram escritos. Retorna automaticamente para 0.
        data_send_success_flags : std_logic_vector(C_CODEC_PUS_SEND_SUCCESS_FLAGS_WIDTH - 1 downto 0); -- Conta incrementalmente quantos pacotes foram enviados com sucesso até então. Circular pelo número de bits.
        irq_send_clr          : std_logic; -- Bit de limpeza de interrupção de envio. Retorna automaticamente para 0.
    end record t_codec_PUS_handling_reg;

    -- Registrador de Offset de memória para DMA de entrada (WR)
    type t_codec_PUS_recv_mem_offset_reg is record
        mem_offset : std_logic_vector(C_CODEC_PUS_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_codec_PUS_recv_mem_offset_reg;

    -- Registrador de Tamanho de fila de DMA de entrada (WR)
    type t_codec_PUS_recv_fifo_size_reg is record
        fifo_size : std_logic_vector(C_CODEC_PUS_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_codec_PUS_recv_fifo_size_reg;

    -- Registrador de Offset de memória para DMA de saída (WR)
    type t_codec_PUS_send_mem_offset_reg is record
        mem_offset : std_logic_vector(C_CODEC_PUS_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_mem_offset_reg;

    -- Registrador de Tamanho de fila de DMA de saída (WR)
    type t_codec_PUS_send_fifo_size_reg is record
        fifo_size : std_logic_vector(C_CODEC_PUS_AVALON_ADDR_WIDTH - 1 downto 0);
    end record t_codec_PUS_send_fifo_size_reg;

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types, constants and aliases for the codec_PUS_Avalon_Read module

    -- Important aliases for the module

    -- Important constants for the module

    -- Constant for defining the width of the Avalon MM address and data buses
    constant c_CPAR_AVALON_ADDR_WIDTH : integer := C_CODEC_PUS_AVALON_ADDR_WIDTH;
    constant c_CPAR_AVALON_DATA_WIDTH : integer := C_CODEC_PUS_AVALON_DATA_WIDTH;


    -- Important types for the module

    -- Type for defining all the read registers of the module
    type t_codec_PUS_rd_regs is record

        control_reg         : t_codec_PUS_control_reg;
        recv_PKG_PRIM_HDR1  : t_codec_PUS_recv_PKG_PRIM_HDR1_reg;
        recv_PKG_PRIM_HDR2  : t_codec_PUS_recv_PKG_PRIM_HDR2_reg;
        recv_PKG_SEC_HDR1   : t_codec_PUS_recv_PKG_SEC_HDR1_reg;
        recv_PKG_SEC_HDR2   : t_codec_PUS_recv_PKG_SEC_HDR2_reg;
        recv_pkg_addr       : t_codec_PUS_recv_pkg_addr_reg;
        recv_status         : t_codec_PUS_recv_status_reg;
        send_PKG_PRIM_HDR1  : t_codec_PUS_send_PKG_PRIM_HDR1_reg;
        send_PKG_PRIM_HDR2  : t_codec_PUS_send_PKG_PRIM_HDR2_reg;
        send_PKG_SEC_HDR1   : t_codec_PUS_send_PKG_SEC_HDR1_reg;
        send_PKG_SEC_HDR2   : t_codec_PUS_send_PKG_SEC_HDR2_reg;
        send_PKG_SEC_HDR3   : t_codec_PUS_send_PKG_SEC_HDR3_reg;
        send_pkg_addr       : t_codec_PUS_send_pkg_addr_reg;
        handling            : t_codec_PUS_handling_reg;
        recv_mem_offset     : t_codec_PUS_recv_mem_offset_reg; -- Offset de memória para DMA de entrada
        recv_fifo_size      : t_codec_PUS_recv_fifo_size_reg; -- Tamanho de fila de DMA de entrada
        send_mem_offset     : t_codec_PUS_send_mem_offset_reg; -- Offset de memória
        send_fifo_size      : t_codec_PUS_send_fifo_size_reg; -- Tamanho de fila de DMA de saída

    end record t_codec_PUS_rd_regs;

    -- Subtype for defining the addresses of the read registers
    subtype t_codec_PUS_rd_regs_addr is natural range 0 to 255;

    -- Important RESET constants for the module

    -- RESET constants for all read registers
    constant C_codec_PUS_recv_PKG_PRIM_HDR1_reg_reset : t_codec_PUS_recv_PKG_PRIM_HDR1_reg := (
        pkg_vernum => (others => '0'),
        pkg_type   => (others => '0'),
        sec_hdr_flag => (others => '0'),
        apid       => (others => '0'),
        seq_flags  => (others => '0'),
        seq_count  => (others => '0')
    );

    constant C_codec_PUS_recv_PKG_PRIM_HDR2_reg_reset : t_codec_PUS_recv_PKG_PRIM_HDR2_reg := (
        pkg_data_len => (others => '0')
    );

    constant C_codec_PUS_recv_PKG_SEC_HDR1_reg_reset : t_codec_PUS_recv_PKG_SEC_HDR1_reg := (
        pusvnum       => (others => '0'),
        ack_flags     => (others => '0'),
        service_id    => (others => '0'),
        subservice_id => (others => '0')
    );

    constant C_codec_PUS_recv_PKG_SEC_HDR2_reg_reset : t_codec_PUS_recv_PKG_SEC_HDR2_reg := (
        source_id => (others => '0')
    );

    constant C_codec_PUS_recv_pkg_addr_reg_reset : t_codec_PUS_recv_pkg_addr_reg := (
        pkg_addr => (others => '0')
    );

    constant C_codec_PUS_recv_status_reg_reset : t_codec_PUS_recv_status_reg := (
        status_flags => (others => '0')
    );

    constant C_codec_PUS_send_PKG_PRIM_HDR1_reg_reset : t_codec_PUS_send_PKG_PRIM_HDR1_reg := (
        apid         => (others => '0'),
        pkg_data_len => (others => '0')
    );

    constant C_codec_PUS_send_PKG_PRIM_HDR2_reg_reset : t_codec_PUS_send_PKG_PRIM_HDR2_reg := (
        seq_count => (others => '0')
    );

    constant C_codec_PUS_send_PKG_SEC_HDR1_reg_reset : t_codec_PUS_send_PKG_SEC_HDR1_reg := (
        spacecraft_time_ref => (others => '0'),
        service_id          => (others => '0'),
        subservice_id       => (others => '0')
    );

    constant C_codec_PUS_send_PKG_SEC_HDR2_reg_reset : t_codec_PUS_send_PKG_SEC_HDR2_reg := (
        msg_type_counter => (others => '0'),
        dest_id          => (others => '0')
    );

    constant C_codec_PUS_send_PKG_SEC_HDR3_reg_reset : t_codec_PUS_send_PKG_SEC_HDR3_reg := (
        time => (others => '0')
    );

    constant C_codec_PUS_send_pkg_addr_reg_reset : t_codec_PUS_send_pkg_addr_reg := (
        pkg_addr => (others => '0')
    );

    constant C_codec_PUS_handling_reg_reset : t_codec_PUS_handling_reg := (
        data_rcv_rdy_flag      => '0',
        data_rcv_rd_flag       => '0',
        irq_rcv_clr            => '0',
        data_send_rdy_flag     => '0',
        data_send_wr_flag      => '0',
        data_send_success_flags => (others => '0'),
        irq_send_clr           => '0'
    );

    constant C_codec_PUS_control_reg_reset : t_codec_PUS_control_reg := (
        proc_rst    => '0',
        en          => '0',
        recv_en     => '0',
        send_en     => '0',
        irq_en      => '0',
        recv_irq_en => '0',
        send_irq_en => '0'
    );

    -- Constant for defining the reset value of the recv_mem_offset register
    constant C_codec_PUS_recv_mem_offset_reg_reset : t_codec_PUS_recv_mem_offset_reg := (
        mem_offset => (others => '0')
    );

    -- Constant for defining the reset value of the recv_fifo_size register
    constant C_codec_PUS_recv_fifo_size_reg_reset : t_codec_PUS_recv_fifo_size_reg := (
        fifo_size => (others => '0')
    );

    -- Constant for defining the reset value of the send_mem_offset register
    constant C_codec_PUS_send_mem_offset_reg_reset : t_codec_PUS_send_mem_offset_reg := (
        mem_offset => (others => '0')
    );

    -- Constant for defining the reset value of the send_fifo_size register
    constant C_codec_PUS_send_fifo_size_reg_reset : t_codec_PUS_send_fifo_size_reg := (
        fifo_size => (others => '0')
    );

    constant c_CODEC_PUS_RD_REGS_RST : t_codec_PUS_rd_regs := (
        control_reg        => C_codec_PUS_control_reg_reset,
        recv_PKG_PRIM_HDR1 => C_codec_PUS_recv_PKG_PRIM_HDR1_reg_reset,
        recv_PKG_PRIM_HDR2 => C_codec_PUS_recv_PKG_PRIM_HDR2_reg_reset,
        recv_PKG_SEC_HDR1  => C_codec_PUS_recv_PKG_SEC_HDR1_reg_reset,
        recv_PKG_SEC_HDR2  => C_codec_PUS_recv_PKG_SEC_HDR2_reg_reset,
        recv_pkg_addr      => C_codec_PUS_recv_pkg_addr_reg_reset,
        recv_status        => C_codec_PUS_recv_status_reg_reset,
        send_PKG_PRIM_HDR1 => C_codec_PUS_send_PKG_PRIM_HDR1_reg_reset,
        send_PKG_PRIM_HDR2 => C_codec_PUS_send_PKG_PRIM_HDR2_reg_reset,
        send_PKG_SEC_HDR1  => C_codec_PUS_send_PKG_SEC_HDR1_reg_reset,
        send_PKG_SEC_HDR2  => C_codec_PUS_send_PKG_SEC_HDR2_reg_reset,
        send_PKG_SEC_HDR3  => C_codec_PUS_send_PKG_SEC_HDR3_reg_reset,
        send_pkg_addr      => C_codec_PUS_send_pkg_addr_reg_reset,
        handling           => C_codec_PUS_handling_reg_reset,
        recv_mem_offset    => C_codec_PUS_recv_mem_offset_reg_reset,
        recv_fifo_size     => C_codec_PUS_recv_fifo_size_reg_reset,
        send_mem_offset    => C_codec_PUS_send_mem_offset_reg_reset,
        send_fifo_size     => C_codec_PUS_send_fifo_size_reg_reset

    );
    

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types, constants and aliases for the codec_PUS_Avalon_Write module

    -- Important aliases for the module

    -- Important constants for the module

    -- Constant for defining the width of the Avalon MM address and data buses
    constant c_cPAW_AVALON_ADDR_WIDTH : integer := C_CODEC_PUS_AVALON_ADDR_WIDTH;
    constant c_cPAW_AVALON_DATA_WIDTH : integer := C_CODEC_PUS_AVALON_DATA_WIDTH;

    -- Important types for the module

    -- Type for defining all the write registers of the module
    type t_codec_PUS_wr_regs is record
        
        control_reg         : t_codec_PUS_control_reg;
        send_PKG_PRIM_HDR1  : t_codec_PUS_send_PKG_PRIM_HDR1_reg;
        send_PKG_PRIM_HDR2  : t_codec_PUS_send_PKG_PRIM_HDR2_reg;
        send_PKG_SEC_HDR1   : t_codec_PUS_send_PKG_SEC_HDR1_reg;
        send_PKG_SEC_HDR2   : t_codec_PUS_send_PKG_SEC_HDR2_reg;
        send_PKG_SEC_HDR3   : t_codec_PUS_send_PKG_SEC_HDR3_reg;
        send_pkg_addr       : t_codec_PUS_send_pkg_addr_reg;
        handling            : t_codec_PUS_handling_reg;
        recv_mem_offset     : t_codec_PUS_recv_mem_offset_reg; -- Offset de memória para DMA de entrada
        recv_fifo_size      : t_codec_PUS_recv_fifo_size_reg; -- Tamanho de
        send_mem_offset     : t_codec_PUS_send_mem_offset_reg; -- Offset de memória
        send_fifo_size      : t_codec_PUS_send_fifo_size_reg; -- Tamanho de fila de DMA de saída

    end record t_codec_PUS_wr_regs;

    -- Subtype for defining the addresses of the write registers
    subtype t_codec_PUS_wr_regs_addr is natural range 0 to 255;

    -- Important RESET constants for the module

    -- RESET constants for all write registers


    -- RESET constant for all the write registers
    constant c_CODEC_PUS_WR_REGS_RST : t_codec_PUS_wr_regs := (
        control_reg       => C_codec_PUS_control_reg_reset,
        send_PKG_PRIM_HDR1 => C_codec_PUS_send_PKG_PRIM_HDR1_reg_reset,
        send_PKG_PRIM_HDR2 => C_codec_PUS_send_PKG_PRIM_HDR2_reg_reset,
        send_PKG_SEC_HDR1 => C_codec_PUS_send_PKG_SEC_HDR1_reg_reset,
        send_PKG_SEC_HDR2 => C_codec_PUS_send_PKG_SEC_HDR2_reg_reset,
        send_PKG_SEC_HDR3 => C_codec_PUS_send_PKG_SEC_HDR3_reg_reset,
        send_pkg_addr     => C_codec_PUS_send_pkg_addr_reg_reset,
        handling          => C_codec_PUS_handling_reg_reset,
        recv_mem_offset   => C_codec_PUS_recv_mem_offset_reg_reset,
        recv_fifo_size    => C_codec_PUS_recv_fifo_size_reg_reset,
        send_mem_offset   => C_codec_PUS_send_mem_offset_reg_reset,
        send_fifo_size    => C_codec_PUS_send_fifo_size_reg_reset
    );

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types, constants and aliases for the codec_PUS_IRQ_Controller module

    -- Important aliases for the module

    -- Important constants for the module

    -- Important types for the module

    -- Important RESET constants for the module

    ----------------------------------------------------------------------------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------------------------------------------------------------------------
    -- Important types, constants and aliases for the codec_PUS_Registers_Controoller_Module

    -- Important aliases for the module
    
    -- Alias for determining the mem rst value width for the CCSDS In module
    constant c_CPRCM_RST_VALUE_WIDTH : integer := C_CCSDS_IN_PROC_RST_VALUE_WIDTH;

    -- Alias for defining the width of the mem offset and fifo size
    constant c_CPRCM_MEM_OFFSET_WIDTH : integer := C_CCSDS_IN_AVALON_ADDR_WIDTH;
    constant c_CPRCM_FIFO_SIZE_WIDTH  : integer := C_CCSDS_IN_AVALON_ADDR_WIDTH;

    -- Important constants for the module
    

    -- Important types for the module

    -- Important RESET constants for the module

    
end package codec_PUS_main_pkg;

package body codec_PUS_main_pkg is

    --------------------------------------------------------------------------------------
    -- Important functions for the codec_PUS_Receiver_Transmitter_CCSDS_In --

    -- Função que converte um tipo t_CCSDS_In_ver_flags para std_logic_vector
    function f_ver_flags_to_std_logic_vector_mask(ver_flags_reg : t_CCSDS_In_status_flags_vector; ver_flags : t_CCSDS_In_status_flags) return t_CCSDS_In_status_flags_vector is
        -- Variável local para armazenar o valor de ver_flags_reg
        variable v_ver_flags_reg : t_CCSDS_In_status_flags_vector := (others => '0');
    begin
        case ver_flags is
            when NO_ERROR => 
                v_ver_flags_reg := "00000000" or ver_flags_reg;
                return v_ver_flags_reg;
            when PKG_PRIM_HDR_VER_NUM_ERROR =>
                v_ver_flags_reg := "00000001" or ver_flags_reg;
                return v_ver_flags_reg;
            when PKG_PRIM_HDR_TYPE_ERROR =>
                v_ver_flags_reg := "00000010" or ver_flags_reg;
                return v_ver_flags_reg;
            when PKG_PRIM_HDR_SEC_HDR_FLAG_ERROR =>
                v_ver_flags_reg := "00000100" or ver_flags_reg;
                return v_ver_flags_reg;
            when PKG_PRIM_HDR_SEQ_ERROR =>
                v_ver_flags_reg := "00001000" or ver_flags_reg;
                return v_ver_flags_reg;
            when PKG_SEC_HDR_PUSVNUM_ERROR =>
                v_ver_flags_reg := "00010000" or ver_flags_reg;
                return v_ver_flags_reg;
            when PKG_SEC_HDR_SERVICE_ID_ERROR =>
                v_ver_flags_reg := "00100000" or ver_flags_reg;
                return v_ver_flags_reg;
            when CRC16_ERROR =>
                v_ver_flags_reg := "01000000" or ver_flags_reg;
                return v_ver_flags_reg;
            when EOP_ERROR =>
                v_ver_flags_reg := "10000000" or ver_flags_reg;
                return v_ver_flags_reg;
            when others =>
                v_ver_flags_reg := "00000000" or ver_flags_reg;
                return v_ver_flags_reg;
        end case;
    end function f_ver_flags_to_std_logic_vector_mask;


end package body codec_PUS_main_pkg;
---------------------------------------------------------------------------------------------------------
