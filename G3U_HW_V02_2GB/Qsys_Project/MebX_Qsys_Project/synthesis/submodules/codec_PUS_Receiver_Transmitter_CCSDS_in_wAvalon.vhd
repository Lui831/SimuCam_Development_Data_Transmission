---------------------------------------------------------------------------------------------------------
-- codec_PUS_Receiver_Transmitter_CCSDS_in.vhd
-- Author: Luiz H. A. Santos
-- Date: 2025-16-01
-- Description: this file contains the VHDL code for the codec_PUS_Receiver_Transmitter_CCSDS_In module,
-- implemented storing the CCSDS packets partly in a DDR3 memory using the Avalon MM interface.
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.codec_PUS_main_pkg.all;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Entidade do codec_PUS_Receiver_Transmitter_CCSDS_in

entity codec_pus_receiver_transmitter_ccsds_in is
    generic (
    
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

end entity codec_pus_receiver_transmitter_ccsds_in;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Arquitetura do codec_PUS_Receiver_Transmitter_CCSDS_in

architecture rtl of codec_pus_receiver_transmitter_ccsds_in is

    ---- Declaração de Sinais Internos --
    -- Sinal de estado da máquina de estados
    signal s_CCSDS_in_state : t_codec_PUS_Receiver_Transmitter_CCSDS_in_wAvalon_states := RESET;


    ---- Declaracao de sinais auxiliares --
    -- Sinal de contagem de bytes recebidos / transferidos
    signal s_byte_count     : t_CCSDS_In_max_recv_bytes := 0;

    -- Sinal de contagem de bytes acumulados e de transferência
    signal s_byte_acc       : t_CCSDS_In_max_recv_bytes := 0;

    -- Sinal de contagem de bytes armazenados na memória até então para todos os serviços
    signal s_byte_mem       : t_CCSDS_In_max_recv_bytes := 0;

    -- Sinal de iteração sobre a memória de serviços
    signal s_byte_itrt      : t_CCSDS_In_max_recv_bytes := 0;

    -- Sinal de memória para recebidos de bytes
    signal s_byte_transfered  : std_logic                 := '0';

    -- Sinal para registrar o alcance do CRC
    signal s_CRC16_reached    : std_logic                 := '0';

    -- Sinal para o tamanho esperado de bytes a serem recebidos no data field
    signal s_data_field_len : t_CCSDS_In_max_recv_bytes := 0;

    -- Sinal para lembrar se o sistema já esteve em erro
    signal s_eop_error     : std_logic := '0';

    -- Sinal para armazenar os dados recebidos
    signal s_CCSDS_data_reg : std_logic_vector(C_CCSDS_IN_DATA_REG_WIDTH - 1 downto 0);

    -- Sinal para aviso e confirmação de reset de memória de um processo para o outro
    signal s_rst_mem_flags  : std_logic;

    -- Sinal para armazenar o offset de memória do pacote atual
    signal s_mem_offset     : t_CCSDS_In_max_stored_bytes := 0;

    -- Sinal para armazenar o serviço do pacote que está sendo recebido em questão
    signal s_pkg_service    : t_CCSDS_In_services_available := 0;

    -- Sinal de rst_mem para armazenamento das solicitações de RESET recebidas
    signal s_rst_mem        : t_CCSDS_In_PROC_rst_mem_i;


begin

---- Declaração dos principais processos da arquitetura --
-- Processo de controle da máquina de estados
p_CCSDS_in_state_machine : process(clk_i, rst_sync_i) is

    -- Declaração de variáveis locais
    variable v_ver_flags_reg : t_CCSDS_In_status_flags_vector := (others => '0');

    begin

        -- Detecta a borda de subida
        if rising_edge(clk_i) then

            -- Caso esteja em estado de resete síncrono
            if rst_sync_i = '1' then

                -- Reseta a máquina de estados
                s_CCSDS_in_state <= RESET;

                -- Reseta todos os sinais da FIFO de saída
                cPRTCi_outFIFO_data_o <= C_CCSDS_In_FIFO_data_out_reset;
                cPRTCi_outFIFO_wr_en_o   <= '0';

                -- Reseta todos os sinais relacionados à FIFO de entrada
                cPRTCi_inFIFO_rd_en_o  <= '0';

                -- Reseta todos os sinais relacionados ao CRC16
                cPRTCi_CRC16_en_o         <= '0';
                cPRTCi_CRC16_rst_sync_o   <= '1';

                -- Reseta todos os sinais relacionados à interface Avalon
                cPRTCi_Avalon_MM_addr_o          <= (others => '0');
                cPRTCi_Avalon_MM_write_o         <= '0';
                cPRTCi_Avalon_MM_write_data_o    <= (others => '0');

                -- Reseta todos os sinais auxiliares
                s_byte_count              <= 0;
                s_byte_acc                <= 0;
                s_byte_mem                <= 0;
                s_byte_itrt               <= 0;
                s_byte_transfered         <= '0';
                s_data_field_len          <= 0;
                s_CRC16_reached           <= '0';
                s_eop_error              <= '0';
                s_mem_offset              <= 0;
                s_pkg_service             <= 0;
                s_rst_mem_flags           <= '0';
                s_CCSDS_data_reg          <= (others => '0');
                v_ver_flags_reg           := (others => '0');


            -- Caso não esteja -> Operação normal da máquina de estados    
            else

                -- Máquina de estados
                case s_CCSDS_in_state is

                    -- Estado de RESET
                    when RESET =>

                        -- Reseta todos os sinais da FIFO de saída
                        cPRTCi_outFIFO_data_o <= C_CCSDS_In_FIFO_data_out_reset;
                        cPRTCi_outFIFO_wr_en_o   <= '0';

                        -- Reseta todos os sinais relacionados à FIFO de entrada
                        cPRTCi_inFIFO_rd_en_o  <= '0';

                        -- Reseta todos os sinais relacionados ao CRC16
                        cPRTCi_CRC16_en_o         <= '0';
                        cPRTCi_CRC16_rst_sync_o   <= '1';

                        -- Reseta todos os sinais relacionados à interface Avalon
                        cPRTCi_Avalon_MM_addr_o          <= (others => '0');
                        cPRTCi_Avalon_MM_write_o         <= '0';
                        cPRTCi_Avalon_MM_write_data_o    <= (others => '0');

                        -- Reseta todos os sinais auxiliares
                        s_byte_count              <= 0;
                        s_byte_acc                <= 0;
                        s_byte_mem                <= 0;
                        s_byte_itrt               <= 0;
                        s_byte_transfered         <= '0';
                        s_data_field_len          <= 0;
                        s_CRC16_reached           <= '0';
                        s_eop_error              <= '0';
                        s_mem_offset              <= 0;
                        s_pkg_service             <= 0;
                        s_rst_mem_flags           <= '0';
                        s_CCSDS_data_reg          <= (others => '0');
                        v_ver_flags_reg           := (others => '0');

                        -- Transiciona para o estado IDLE
                        s_CCSDS_in_state <= IDLE;


                    -- Estado de IDLE
                    when IDLE =>

                        -- Tira o CRC16CITT module do reset
                        cPRTCi_CRC16_rst_sync_o   <= '0';

                        -- Verifica se a FIFO de entrada está vazia
                        if cPRTCi_inFIFO_empty_i = '1' then

                            -- Continua no estado IDLE
                            s_CCSDS_in_state <= IDLE;

                        -- Caso contrário, transiciona para o estado de RECEIVING_I
                        else

                            -- Transiciona para o estado de RECEIVING_I
                            s_CCSDS_in_state <= RECEIVING_I;

                        end if;


                    -- Estado de RECEIVING_I
                    when RECEIVING_I =>

                        -- Caso o número de bytes recebidos seja menor que 2
                        if s_byte_count < 6 then

                            -- Se a FIFO de entrada não estiver vazia e rxvalid estiver ativado
                            if (cPRTCi_inFIFO_empty_i = '0' and cPRTCi_inFIFO_rxvalid_i = '1') and s_byte_transfered = '0' then
    
                                cPRTCi_inFIFO_rd_en_o    <= '1';
                                cPRTCi_CRC16_en_o        <= '1';
    
                                -- Ativa o sinal de recebimento de byte
                                s_byte_transfered              <= '1';
    
                                -- Continua no estado RECEIVING_I
    
                                -- Recebe o byte com base no case
                                case s_byte_count is
    
                                    -- Para o primeiro, recebe os 8 bits menos significativos
                                    when 0 =>
                                        s_CCSDS_data_reg(47 downto 40) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                 <= s_byte_count + 1;
    
                                    -- Para o segundo...
                                    when 1 =>
                                        s_CCSDS_data_reg(39 downto 32) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o terceiro...
                                    when 2 =>
                                        s_CCSDS_data_reg(31 downto 24) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o quarto...
                                    when 3 =>
                                        s_CCSDS_data_reg(23 downto 16) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o quinto...
                                    when 4 =>
                                        s_CCSDS_data_reg(15 downto 8) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o sexto...
                                    when 5 =>
                                        s_CCSDS_data_reg(7 downto 0) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;
    
                                    -- Para os outros, não faz nada
                                    when others =>
                                        null;

                                end case;
    
                            -- Se a FIFO de entrada estiver vazia, ou rxvald estiver desativado, ou já tenha recebido um byte, desativa o sinal de recebimento
                            else
                                
                                -- Desativa o sinal de leitura e de en do CRC16CITT
                                cPRTCi_inFIFO_rd_en_o    <= '0';
                                cPRTCi_CRC16_en_o      <= '0';
    
                                -- Desativa o sinal de recebimento de byte
                                s_byte_transfered              <= '0';
    
                                -- Continua no estado RECEIVING_I
    
                            end if;

                        -- Caso tenham sido atingidos os 6 bytes, transiciona para o estado de INTERPRETING_I, reseta o contador de bytes e desativa o recebimento
                        else
                                
                            -- Desativa o sinal de leitura e de en do CRC16CITT
                            cPRTCi_inFIFO_rd_en_o    <= '0';
                            cPRTCi_CRC16_en_o      <= '0';
    
                            -- Desativa o sinal de recebimento de byte
                            s_byte_transfered              <= '0';
    
                            -- Transiciona para o estado de INTERPRETING_I
                            s_CCSDS_in_state             <= INTERPRETING_I;
    
                            -- Reseta o contador de bytes
                            s_byte_count                 <= 0;

                        end if;

                    
                    -- Estado de INTERPRETING_I
                    when INTERPRETING_I =>

                        -- Verifica os primeiros 3 bits do packet version number
                        if s_CCSDS_data_reg(47 downto 45) /= C_CCSDS_IN_PKG_VER_NUM then

                            -- Expõe o erro de versão do pacote
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, PKG_PRIM_HDR_VER_NUM_ERROR);

                        end if;

                        -- Vefifica o packet type
                        if s_CCSDS_data_reg(44) /= C_CCSDS_IN_PKG_TYPE then

                            -- Expõe o erro de tipo de pacote
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, PKG_PRIM_HDR_TYPE_ERROR);

                        end if;

                        -- Verifica o package secondary header flag
                        if s_CCSDS_data_reg(43) /= C_CCSDS_IN_PKG_SEC_HDR_FLAG then

                            -- Expõe o erro de tipo de pacote
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, PKG_PRIM_HDR_SEC_HDR_FLAG_ERROR);

                        end if;

                        -- Verifica os sequence flags
                        if s_CCSDS_data_reg(31 downto 30) /= C_CCSDS_IN_SEQ_FLAGS then

                            -- Expõe o erro de flags de sequência
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, PKG_PRIM_HDR_SEQ_ERROR);

                        end if;

                        -- Obtém o packet data length e preenche os campos dos registradores de PKG PRIM HEADER
                        s_data_field_len <= to_integer(unsigned(s_CCSDS_data_reg(15 downto 0)));

                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.pkg_vernum     <= s_CCSDS_data_reg(47 downto 45);
                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.pkg_type       <= s_CCSDS_data_reg(44 downto 44);
                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.sec_hdr_flag   <= s_CCSDS_data_reg(43 downto 43);
                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.apid           <= s_CCSDS_data_reg(42 downto 32);
                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.seq_flags      <= s_CCSDS_data_reg(31 downto 30);
                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.seq_count      <= s_CCSDS_data_reg(29 downto 16);
                        cPRTCi_outFIFO_data_o.PKG_PRIM_HDR.pkg_data_len   <= s_CCSDS_data_reg(15 downto 0);

                        -- Reseta o registrador de armazenamento
                        s_CCSDS_data_reg                  <= (others => '0');

                        s_CCSDS_in_state                  <= RECEIVING_II;
                        

                    -- Estado de RECEIVING_II
                    when RECEIVING_II =>

                        -- Caso o número de bytes recebidos seja menor que 5
                        if s_byte_count < 5 then

                            -- Se a FIFO de entrada não estiver vazia e rxvalid estiver ativado
                            if (cPRTCi_inFIFO_empty_i = '0' and cPRTCi_inFIFO_rxvalid_i = '1') and s_byte_transfered = '0' then

                                cPRTCi_inFIFO_rd_en_o    <= '1';
                                cPRTCi_CRC16_en_o         <= '1';

                                -- Ativa o sinal de recebimento de byte
                                s_byte_transfered              <= '1';

                                -- Continua no estado RECEIVING_I

                                -- Recebe o byte com base no case
                                case s_byte_count is

                                    -- Para o primeiro, recebe os 8 bits menos significativos
                                    when 0 =>
                                        s_CCSDS_data_reg(39 downto 32) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                 <= s_byte_count + 1;

                                    -- Para o segundo...
                                    when 1 =>
                                        s_CCSDS_data_reg(31 downto 24) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o terceiro...
                                    when 2 =>
                                        s_CCSDS_data_reg(23 downto 16) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o quarto...
                                    when 3 =>
                                        s_CCSDS_data_reg(15 downto 8) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para o quinto...
                                    when 4 =>
                                        s_CCSDS_data_reg(7 downto 0) <= cPRTCi_inFIFO_data_i;
                                        s_byte_count                  <= s_byte_count + 1;

                                    -- Para os outros, não faz nada
                                    when others =>
                                        null;

                                end case;

                            -- Se a FIFO de entrada estiver vazia, ou rxvald estiver desativado, ou já tenha recebido um byte, desativa o sinal de recebimento
                            else
                            
                                -- Desativa o sinal de leitura e de en do CRC16CITT
                                cPRTCi_inFIFO_rd_en_o    <= '0';
                                cPRTCi_CRC16_en_o         <= '0';

                                -- Desativa o sinal de recebimento de byte
                                s_byte_transfered            <= '0';

                                -- Continua no estado RECEIVING_II

                            end if;

                        -- Caso tenham sido atingidos os 6 bytes, transiciona para o estado de INTERPRETING_II, reseta o contador de bytes e desativa o recebimento
                        else
                            
                            -- Desativa o sinal de leitura e de en do CRC16CITT
                            cPRTCi_inFIFO_rd_en_o    <= '0';
                            cPRTCi_CRC16_en_o         <= '0';

                            -- Desativa o sinal de recebimento de byte
                            s_byte_transfered              <= '0';

                            -- Reseta o contador de bytes
                            s_byte_count                 <= 0;

                            -- Transiciona para o estado de INTERPRETING_I
                            s_CCSDS_in_state             <= INTERPRETING_II;


                        end if;


                    -- Estado de INTERPRETING_II
                    when INTERPRETING_II =>

                        -- Verifica o PUS version number do secondary header
                        if s_CCSDS_data_reg(39 downto 36) /= C_CCSDS_IN_PKG_PUSVNUM then

                            -- Expõe o erro de versão do pacote
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, PKG_SEC_HDR_PUSVNUM_ERROR);

                        end if;

                        -- Verifica o service type ID e se está disponível no sistema
                        if C_CCSDS_In_AVAILABLE_SERVICES(to_integer(unsigned(s_CCSDS_data_reg(31 downto 24)))) = '0' then

                            -- Expõe o erro de service type ID
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, PKG_SEC_HDR_SERVICE_ID_ERROR);

                        end if;

                        -- Armazena os valores do secondary header no registrador
                        cPRTCi_outFIFO_data_o.PKG_SEC_HDR.pusvnum       <= s_CCSDS_data_reg(39 downto 36);
                        cPRTCi_outFIFO_data_o.PKG_SEC_HDR.ack_flags     <= s_CCSDS_data_reg(35 downto 32);
                        cPRTCi_outFIFO_data_o.PKG_SEC_HDR.service_id    <= s_CCSDS_data_reg(31 downto 24);
                        cPRTCi_outFIFO_data_o.PKG_SEC_HDR.subservice_id <= s_CCSDS_data_reg(23 downto 16);
                        cPRTCi_outFIFO_data_o.PKG_SEC_HDR.source_id     <= s_CCSDS_data_reg(15 downto 0);

                        -- Armazena o serviço do pacote em questão
                        s_pkg_service <= to_integer(unsigned(s_CCSDS_data_reg(31 downto 24)));

                        -- Stores the current offset based on the service number
                        s_mem_offset <= s_byte_itrt;

                        -- Reseta o registrador de armazenamento
                        s_CCSDS_data_reg                <= (others => '0');

                        -- Transitions the state to ACCUMULATING
                        s_CCSDS_in_state                  <= ACCUMULATING;


                    -- Estado de ACCUMULATING
                    when ACCUMULATING =>

                        -- Caso o número de bytes recebidos seja menor que a quantidade disponível pelo data bus
                        if s_byte_acc < C_CCSDS_IN_AVALON_DATA_WIDTH / 8 and (s_byte_count + s_byte_acc) < s_data_field_len - 5 - 2 then

                            -- Se a FIFO de entrada não estiver vazia e rxvalid estiver ativado
                            if (cPRTCi_inFIFO_empty_i = '0' and cPRTCi_inFIFO_rxvalid_i = '1') and s_byte_transfered = '0' then
    
                                cPRTCi_inFIFO_rd_en_o   <= '1';
                                cPRTCi_CRC16_en_o        <= '1';
    
                                -- Ativa o sinal de recebimento de byte
                                s_byte_transfered              <= '1';
    
                                -- Recebe o byte com base no case
                                case s_byte_acc is
    
                                    -- Para o primeiro, recebe os 8 bits menos significativos
                                    when 0 =>
                                        s_CCSDS_data_reg(31 downto 24) <= cPRTCi_inFIFO_data_i;
                                        s_byte_acc                   <= s_byte_acc + 1;
    
                                    -- Para o segundo...
                                    when 1 =>
                                        s_CCSDS_data_reg(23 downto 16) <= cPRTCi_inFIFO_data_i;
                                        s_byte_acc                    <= s_byte_acc + 1;

                                    -- Para o terceiro...
                                    when 2 =>
                                        s_CCSDS_data_reg(15 downto 8) <= cPRTCi_inFIFO_data_i;
                                        s_byte_acc                     <= s_byte_acc + 1;

                                    -- Para o quarto...
                                    when 3 =>
                                        s_CCSDS_data_reg(7 downto 0) <= cPRTCi_inFIFO_data_i;
                                        s_byte_acc                     <= s_byte_acc + 1;

                                    -- Para outros casos...
                                    when others =>
                                        null;

                                end case;
    
                            -- Se a FIFO de entrada estiver vazia, ou rxvald estiver desativado, ou já tenha recebido um byte, desativa o sinal de recebimento
                            else
                                
                                -- Desativa o sinal de leitura e de en do CRC16CITT
                                cPRTCi_inFIFO_rd_en_o    <= '0';
                                cPRTCi_CRC16_en_o        <= '0';
    
                                -- Desativa o sinal de recebimento de byte
                                s_byte_transfered              <= '0';
    
                            end if;

                        else

                            -- Desativa os sinais de leitura e de en do CRC16CITT
                            cPRTCi_inFIFO_rd_en_o    <= '0';
                            cPRTCi_CRC16_en_o        <= '0';

                            -- Desativa o sinal de recebimento de byte
                            s_byte_transfered              <= '0';

                            -- Atualiza o valor de contagem de bytes
                            s_byte_count                   <= s_byte_count + s_byte_acc;

                            -- Verifica se o valor de contagem atingiu o CRC
                            if s_byte_count + s_byte_acc = s_data_field_len - 5 - 2 then

                                -- Seta o sinal de CRC achieved
                                s_CRC16_reached                <= '1';

                            end if;

                            -- Antes de transicionar para o próximo estado, verifica se há alguma solicitação de limpeza de memória
                            if s_byte_mem + s_data_field_len - 5 - s_byte_count - s_byte_acc > to_integer(unsigned(cPRTCi_DMA_num_bytes_i)) then

                                -- Transitions to the state of RESETING_MEM
                                s_CCSDS_in_state                <= RESETING_MEM;

                            else

                                -- Transitions to the state of TRANSFERING
                                s_CCSDS_in_state                <= TRANSFERING;

                            end if;                         
                        end if;


                    -- Estado de RESETING_MEM
                    when RESETING_MEM =>

                        -- Reseta as flags de reset de memória
                        s_rst_mem_flags <= '0';

                        -- Caso o serviço em questão tenha alguma solicitação de reset de memória sob espera
                        if to_integer(unsigned(s_rst_mem.rst_value)) > 0 then 

                            -- Limpa a memória, atualizando a variável de ponteiro de memória
                            s_byte_mem <= s_byte_mem - to_integer(unsigned(s_rst_mem.rst_value));

                            -- Aciona o sinal de sinalização de limpeza de memória
                            s_rst_mem_flags <= '1';

                            -- Caso haja espaço suficiente para armazenar o pacote
                            if s_byte_mem - to_integer(unsigned(s_rst_mem.rst_value)) + s_data_field_len - 5 - s_byte_count - s_byte_acc <= to_integer(unsigned(cPRTCi_DMA_num_bytes_i)) then

                                -- Transiciona para o estado de TRANSFERING
                                s_CCSDS_in_state <= TRANSFERING;

                            -- Caso contrário, mantém no estado de RESETING_MEM
                            else

                                -- Continua no estado de RESETING_MEM
                                s_CCSDS_in_state <= RESETING_MEM;

                            end if;

                        end if;


                    -- Estado de TRANSFERING
                    when TRANSFERING =>

                        -- Reseta as flags de reset de memória
                        s_rst_mem_flags <= '0';

                        -- Caso a operação de escrita não tenha sido realizada ainda
                        if s_byte_transfered = '0' then

                            -- Determina o que será escrito e o addr no Avalon MM
                            cPRTCi_Avalon_MM_addr_o       <= std_logic_vector(to_unsigned(s_byte_itrt, c_CCSDS_IN_AVALON_ADDR_WIDTH));
                            cPRTCi_Avalon_MM_write_data_o <= s_CCSDS_data_reg(31 downto 0);

                            -- Ativa o sinal de escrita
                            cPRTCi_Avalon_MM_write_o      <= '1';

                            -- Aciona s_byte_transfered, determinando a operação como setada
                            s_byte_transfered              <= '1';

                        -- Caso a operação de escrita tenha sido ativada
                        else
                            
                            -- Verifica o sinal de waitrequest esta ativo
                            if cPRTCi_Avalon_MM_wait_request_i = '1' then

                                -- Continua no estado de TRANSFERING, mantendo os sinais
                                s_CCSDS_in_state <= TRANSFERING;


                            -- Caso contrário, a operação de escrita foi concluída
                            else
                                
                                -- Reseta o sinal de byte_transfered
                                s_byte_transfered <= '0';

                                -- Atualiza o sinal de byte_mem, sinalizando aumento da ocupação da memória
                                s_byte_mem <= s_byte_mem + s_byte_acc;

                                -- Atualiza o sinal de byte_itrt, sinalizando o próximo byte a ser escrito
                                s_byte_itrt <= to_integer(unsigned(cPRTCi_DMA_start_addr_i)) + ((s_byte_itrt + 4) mod to_integer(unsigned(cPRTCi_DMA_num_bytes_i)));
                                
                                -- Reseta o sinal de bytes acumulados
                                s_byte_acc        <= 0;

                                -- Desativa o sinal de escrita
                                cPRTCi_Avalon_MM_write_o <= '0';

                                -- Reseta o registrador de acúmulo de dados
                                s_CCSDS_data_reg  <= (others => '0');

                                -- Reseta o sinal de byte_transfered
                                s_byte_transfered <= '0';

                                -- Caso o CRC tenha sido detectado transiciona para o estado de ACCUMULATING_CRC
                                if s_CRC16_reached = '1' then

                                    -- Transiciona para o estado de ACCUMULATING_CRC
                                    s_CCSDS_in_state <= ACCUMULATING_CRC;

                                -- Caso contrário, mantém retornando para ACCUMULATING
                                else

                                    s_CCSDS_in_state <= ACCUMULATING;

                                end if;

                            end if;
                        end if;

                 
                    -- Estado de ACCUMULATING_CRC, aguardando também o recebimento do EOP
                    when ACCUMULATING_CRC =>

                        -- Caso o número de bytes recebidos seja menor que a quantidade disponível pelo data bus
                        if s_byte_acc < 3 then

                            -- Se a FIFO de entrada não estiver vazia e rxvalid estiver ativado
                            if (cPRTCi_inFIFO_empty_i = '0' and cPRTCi_inFIFO_rxvalid_i = '1') and s_byte_transfered = '0' then
    
                                cPRTCi_inFIFO_rd_en_o    <= '1';
                                cPRTCi_CRC16_en_o       <= '0';
    
                                -- Ativa o sinal de recebimento de byte
                                s_byte_transfered              <= '1';
    
                                -- Recebe o byte com base no case
                                case s_byte_acc is
    
                                    -- Para o primeiro, recebe os 8 bits menos significativos
                                    when 0 =>
                                        s_CCSDS_data_reg(15 downto 8) <= cPRTCi_inFIFO_data_i;
                                        s_byte_acc                   <= s_byte_acc + 1;
    
                                    -- Para o segundo...
                                    when 1 =>
                                        s_CCSDS_data_reg(7 downto 0) <= cPRTCi_inFIFO_data_i;
                                        s_byte_acc                    <= s_byte_acc + 1;

                                    -- Para o terceiro (EOP)...
                                    when 2 =>
                                        
                                        -- If the last byte data is 00 and its flag is 1, sets the s_eop_error to '0'
                                        if cPRTCi_inFIFO_data_i /= X"00" or cPRTCi_inFIFO_flag_i /= '1' then
                                            s_eop_error <= '1';
                                        end if;

                                        -- Increases the byte count
                                        s_byte_acc <= s_byte_acc + 1;

                                        null;

                                    -- Para outros casos
                                    when others =>
                                        null;

                                end case;
    
                            -- Se a FIFO de entrada estiver vazia, ou rxvald estiver desativado, ou já tenha recebido um byte, desativa o sinal de recebimento
                            else
                                
                                -- Desativa o sinal de leitura e de en do CRC16CITT
                                cPRTCi_inFIFO_rd_en_o    <= '0';
                                cPRTCi_CRC16_en_o       <= '0';
    
                                -- Desativa o sinal de recebimento de byte
                                s_byte_transfered              <= '0';
    
                            end if;

                        else

                            -- Desativa os sinais de leitura e de en do CRC16CITT
                            cPRTCi_inFIFO_rd_en_o    <= '0';
                            cPRTCi_CRC16_en_o       <= '0';

                            -- Desativa o sinal de recebimento de byte
                            s_byte_transfered              <= '0';

                            -- Transiciona para o estado de INTERPRETING_III
                            s_CCSDS_in_state                <= INTERPRETING_III;
                            
                        end if;

                    -- Estado de INTERPRETING_III
                    when INTERPRETING_III =>

                        -- Compara o CRC16 recebido com o calculado
                        if cPRTCi_CRC16_crc_i(15 downto 8) /= s_CCSDS_data_reg(15 downto 8) or cPRTCi_CRC16_crc_i(7 downto 0) /= s_CCSDS_data_reg(7 downto 0) then

                            -- Expõe o erro de CRC
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, CRC16_ERROR);

                        end if;

                        -- If a EOP error has been detected, update the status flags
                        if s_eop_error = '1' then
                            v_ver_flags_reg := f_ver_flags_to_std_logic_vector_mask(v_ver_flags_reg, EOP_ERROR);
                        end if;

                        -- Reseta o registrador de armazenamento
                        s_CCSDS_data_reg          <= (others => '0');

                        -- Transiciona para o estado de WAITING_FOR_TRANSMISSION
                        s_CCSDS_in_state          <= WAITING_FOR_TRANSMISSION;


                    -- Estado de WAITING_FOR_TRANSMISSION
                    when WAITING_FOR_TRANSMISSION =>

                        -- Verifica se a FIFO de saída não está cheia e permite recebimento de dados
                        if cPRTCi_outFIFO_full_i = '0' and cPRTCi_outFIFO_txrdy_i = '1' then

                            -- Escreve os sinais de PKG addr e status flags na FIFO de saída
                            cPRTCi_outFIFO_data_o.status_flags.ver_flags <= v_ver_flags_reg;
                            cPRTCi_outFIFO_data_o.PKG_addr         <= std_logic_vector(to_unsigned(s_mem_offset, C_CCSDS_IN_AVALON_ADDR_WIDTH));

                            -- Ativa o sinal de escrita na FIFO de saída
                            cPRTCi_outFIFO_wr_en_o <= '1';

                            -- Transiciona para RESTART
                            s_CCSDS_in_state   <= RESTART;

                        end if;

                    
                    -- Estado de RESTART
                    when RESTART =>

                        -- Reseta todos os sinais da FIFO de saída
                        cPRTCi_outFIFO_data_o <= C_CCSDS_In_FIFO_data_out_reset;
                        cPRTCi_outFIFO_wr_en_o   <= '0';


                        -- Reseta todos os sinais relacionados à FIFO de entrada
                        cPRTCi_inFIFO_rd_en_o  <= '0';

                        -- Reseta todos os sinais relacionados ao CRC16
                        cPRTCi_CRC16_en_o          <= '0';
                        cPRTCi_CRC16_rst_sync_o   <= '1';


                        -- Reseta todos os sinais relacionados à interface Avalon
                        cPRTCi_Avalon_MM_addr_o          <= (others => '0');
                        cPRTCi_Avalon_MM_write_o         <= '0';


                        -- Reseta todos os sinais auxiliares
                        s_byte_count              <= 0;
                        s_byte_acc                <= 0;
                        s_byte_transfered         <= '0';
                        s_data_field_len          <= 0;
                        s_eop_error              <= '0';
                        s_CRC16_reached           <= '0';
                        s_mem_offset              <= 0;
                        s_pkg_service             <= 0;
                        s_CCSDS_data_reg          <= (others => '0');
                        v_ver_flags_reg           := (others => '0');

                        -- Transiciona para o estado IDLE
                        s_CCSDS_in_state <= IDLE;

                    end case;
            end if;
        end if;
    end process p_CCSDS_in_state_machine;

-- Processo para resetar a memória do PROC
p_CCSDS_in_reset_mem: process(clk_i, rst_sync_i) is

    -- Creates a variable to store the value of the reset memory
    variable v_rst_mem_values : t_CCSDS_In_max_stored_bytes := 0;

begin

    -- Caso seja detectada uma borda de subida de clock
    if rising_edge(clk_i) then

        -- Caso o sinal de reset esteja ativo
        if rst_sync_i = '1' then

            -- Resets the signals and the variables
            s_rst_mem <= C_CCSDS_In_PROC_rst_mem_reset;

            v_rst_mem_values  := 0;

        -- Caso contrário
        else

            -- Caso o valor do reset de memória esteja ativo, acumula o valor
            if cPRTCi_PROC_rst_i = '1' then

                -- Based on the service number, stores the value
                v_rst_mem_values := v_rst_mem_values + to_integer(unsigned(cPRTCi_PROC_rst_mem_value_i));

            end if;

            -- If some rst flag is active, it means that a reset was done correctly and the value must be updated
            -- If the reset flag is active
            if s_rst_mem_flags = '1' then

                v_rst_mem_values := v_rst_mem_values - to_integer(unsigned(s_rst_mem.rst_value));

            end if;

            -- Redetermines the value of the reset memory for each service
            s_rst_mem.rst_value <= std_logic_vector(to_unsigned(v_rst_mem_values, C_CCSDS_IN_PROC_RST_VALUE_WIDTH));

        end if;

    end if;

end process p_CCSDS_in_reset_mem;

    -- The data to the CRC module is always connected to the fifo data
    cPRTCi_CRC16_data_o <= cPRTCi_inFIFO_data_i;

end architecture rtl;
    




