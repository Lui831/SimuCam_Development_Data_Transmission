---------------------------------------------------------------------------------------------------------
-- codec_PUS_Input_Header_FIFO.vhd
-- Author: Luiz H. A. Santos and Thiago A. M. do Amaral
-- Date: 2025-05-21
-- Description: this file contains the main entity regarding the codec_PUS_Input_Header_FIFO
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

entity codec_PUS_Input_Header_FIFO is

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
        cPCIHF_CCSDS_In_almost_empty_o : out std_logic;
        cPCIHF_CCSDS_In_almost_full_o    : out std_logic;
        cPCIHF_CCSDS_In_txrdy_o          : out std_logic;
        cPCIHF_CCSDS_In_rxrdy_o          : out std_logic 
    );

end entity codec_PUS_Input_Header_FIFO;

---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
-- Architecture

architecture rtl of codec_PUS_Input_Header_FIFO is


signal count: integer range 0 to c_cPFi_LENGTH-1 := 0;


-- SRAM FIFOory
type fifo_array is array (0 to c_cPFi_LENGTH-1) of t_cPFi_FIFO_data; 
signal fifo: fifo_array;


--Counters
signal wr_ptr, rd_ptr: integer range 0 to c_cPFi_LENGTH-1;


begin


  process (clk_i, rst_sync_i)
    begin
        if rst_sync_i = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
           -- for i in 0 to cPCIHF_CCSDS_In_FIFO_Array_Width loop
           --  fifo(i)<=c_cPFo_DATA_RST;
           -- end loop; 
            cPCIHF_CCSDS_In_data_o<=c_cPFi_DATA_RST;
        elsif (clk_i'event and clk_i='1') then
            cPCIHF_CCSDS_In_data_o <= fifo(rd_ptr);
            if (cPCIHF_CCSDS_In_wr_en_i = '1') and (cPCIHF_CCSDS_In_rd_en_i = '1') then
                count<=count;
            elsif (cPCIHF_CCSDS_In_wr_en_i = '1') and (count < c_cPFi_LENGTH) then
                fifo(wr_ptr) <= cPCIHF_CCSDS_In_data_i;
                wr_ptr <= (wr_ptr + 1) mod c_cPFi_LENGTH;
                count <= count + 1;
            elsif (cPCIHF_CCSDS_In_rd_en_i = '1') and (count > 0) and (count < c_cPFi_LENGTH) then
                cPCIHF_CCSDS_In_data_o <= fifo(rd_ptr);
                rd_ptr <= (rd_ptr + 1) mod c_cPFi_LENGTH;
                count <= count - 1;
            end if;
        end if;
    end process;
    
    cPCIHF_CCSDS_In_full_o        <= '1' when (count = c_cPFi_LENGTH-1) else '0';
    cPCIHF_CCSDS_In_almost_full_o <= '1' when (count = c_cPFi_LENGTH-2) else '0';
    cPCIHF_CCSDS_In_empty_o       <= '1' when (count = 0) else '0';
    cPCIHF_CCSDS_In_almost_empty_o <= '1' when (count = 1) else '0';
    cPCIHF_CCSDS_In_txrdy_o       <= '0' when (count = c_cPFi_LENGTH-1) else '1'; -- ready for receiving
    cPCIHF_CCSDS_In_rxrdy_o       <= '0' when (count = 0) else '1'; -- ready for transmitting

end architecture rtl;
---------------------------------------------------------------------------------------------------------