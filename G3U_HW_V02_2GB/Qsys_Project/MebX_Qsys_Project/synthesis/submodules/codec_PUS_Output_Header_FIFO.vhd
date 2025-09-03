---------------------------------------------------------------------------------------------------------
-- codec_PUS_Output_Header_FIFO.vhd
-- Author: Thiago Alves Mendes do Amaral and Luiz Henrique Antoniassi Santos
-- Date: 2025-05-22
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
-- Main module's entity 

entity codec_PUS_Output_Header_FIFO is
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

end entity codec_PUS_Output_Header_FIFO;

---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
-- Module's Architecture

architecture rtl of codec_PUS_Output_Header_FIFO is

    -- FIFO memory declaration
    type fifo_mem_t is array (0 to c_cPFo_LENGTH-1) of t_cPFo_FIFO_data;
    signal fifo_mem : fifo_mem_t;

    -- FIFO pointers and counters
    signal wr_ptr      : integer range 0 to c_cPFo_LENGTH-1 := 0;
    signal rd_ptr      : integer range 0 to c_cPFo_LENGTH-1 := 0;
    signal fifo_count  : integer range 0 to c_cPFo_LENGTH := 0;

begin

    -- Combined Write/Read process with proper reset and simultaneous operation handling
    process(clk_i, rst_sync_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync_i = '1' then
                wr_ptr     <= 0;
                rd_ptr     <= 0;
                fifo_count <= 0;
                fifo_mem   <= (others => c_cPFo_DATA_RST);
            else
                -- Write operation
                if cPFo_wr_en_i = '1' and fifo_count < c_cPFo_LENGTH then
                    fifo_mem(wr_ptr) <= cPFo_data_i;
                    wr_ptr <= (wr_ptr + 1) mod c_cPFo_LENGTH;
                end if;
                -- Read operation
                if cPFo_rd_en_i = '1' and fifo_count > 0 then
                    rd_ptr <= (rd_ptr + 1) mod c_cPFo_LENGTH;
                end if;
                -- FIFO count management for simultaneous read/write
                if (cPFo_wr_en_i = '1' and cPFo_rd_en_i = '0') then -- Write only
                    if fifo_count < c_cPFo_LENGTH then
                        fifo_count <= fifo_count + 1;
                    end if;
                elsif (cPFo_wr_en_i = '0' and cPFo_rd_en_i = '1') then -- Read only
                    if fifo_count > 0 then
                        fifo_count <= fifo_count - 1;
                    end if;
                elsif (cPFo_wr_en_i = '1' and cPFo_rd_en_i = '1') then -- Simultaneous read and write
                    -- Only update pointers, count unchanged
                    fifo_count <= fifo_count;
                else
                    fifo_count <= fifo_count;
                end if;
            end if;
        end if;
    end process;

    -- Output assignments
    cPFo_data_o <= fifo_mem(rd_ptr);

    cPFo_empty_o        <= '1' when fifo_count = 0 else '0';
    cPFo_almost_empty_o <= '1' when fifo_count <= 1 else '0';
    cPFo_txrdy_o        <= '1' when fifo_count > 0 else '0';

    cPFo_full_o         <= '1' when fifo_count = c_cPFo_LENGTH else '0';
    cPFo_almost_full_o  <= '1' when fifo_count >= c_cPFo_LENGTH-1 else '0';
    cPFo_rxrdy_o        <= '1' when fifo_count < c_cPFo_LENGTH else '0';

end architecture rtl;
    




