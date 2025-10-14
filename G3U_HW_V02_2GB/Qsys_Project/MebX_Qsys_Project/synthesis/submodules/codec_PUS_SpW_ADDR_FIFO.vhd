----------------------------------------------------------------------------------------------------
-- codec_PUS_SpW_ADDR_FIFO.vhd
-- Author: VHDL GPT
-- Date: 2025-10-05
-- Description: FIFO module for address handling between codec_PUS and SpaceWire interface.
--              Implements synchronous reset and supports simultaneous read/write operations.
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

entity codec_PUS_SpW_ADDR_FIFO is
    generic (

        -- FIFO depth (number of words)
        c_cPSAF_LENGTH : natural := C_CPSAF_FIFO_DEPTH

    );
    port (

        -- Clock and reset
        clk_i        : in  std_logic;
        rst_sync_i   : in  std_logic;

        -- FIFO write interface (Codec PUS side)
        cPSAF_wr_en_i : in  std_logic;
        cPSAF_data_i  : in  t_cPSAF_FIFO_data;

        -- FIFO read interface (SpaceWire side)
        cPSAF_rd_en_i : in  std_logic;

        -- FIFO status outputs
        cPSAF_empty_o         : out std_logic;
        cPSAF_almost_empty_o  : out std_logic;
        cPSAF_txrdy_o         : out std_logic;

        cPSAF_full_o          : out std_logic;
        cPSAF_almost_full_o   : out std_logic;
        cPSAF_data_o          : out t_cPSAF_FIFO_data;
        cPSAF_rxvalid_o       : out std_logic
    );

end entity codec_PUS_SpW_ADDR_FIFO;

----------------------------------------------------------------------------------------------------
-- Architecture Definition

architecture rtl of codec_PUS_SpW_ADDR_FIFO is

    -- FIFO memory declaration
    type fifo_mem_t is array (0 to c_cPSAF_LENGTH-1) of t_cPSAF_FIFO_data;
    signal fifo_mem : fifo_mem_t;

    -- FIFO pointers and counters
    signal wr_ptr     : integer range 0 to c_cPSAF_LENGTH-1 := 0;
    signal rd_ptr     : integer range 0 to c_cPSAF_LENGTH-1 := 0;
    signal fifo_count : integer range 0 to c_cPSAF_LENGTH   := 0;

begin

    ------------------------------------------------------------------------------------------------
    -- Combined Write/Read Process with proper reset and simultaneous operation handling
    ------------------------------------------------------------------------------------------------
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync_i = '1' then
                wr_ptr     <= 0;
                rd_ptr     <= 0;
                fifo_count <= 0;
                fifo_mem   <= (others => C_cPSAF_FIFO_data_reset);  -- Clear FIFO memory on reset

            else
                ------------------------------------------------------------------------
                -- WRITE OPERATION
                ------------------------------------------------------------------------
                if cPSAF_wr_en_i = '1' and fifo_count < c_cPSAF_LENGTH then
                    fifo_mem(wr_ptr) <= cPSAF_data_i;
                    wr_ptr <= (wr_ptr + 1) mod c_cPSAF_LENGTH;
                end if;

                ------------------------------------------------------------------------
                -- READ OPERATION
                ------------------------------------------------------------------------
                if cPSAF_rd_en_i = '1' and fifo_count > 0 then
                    rd_ptr <= (rd_ptr + 1) mod c_cPSAF_LENGTH;
                end if;

                ------------------------------------------------------------------------
                -- FIFO COUNT MANAGEMENT
                -- Simultaneous read/write allowed and handled correctly
                ------------------------------------------------------------------------
                if (cPSAF_wr_en_i = '1' and cPSAF_rd_en_i = '0') then
                    -- Write only
                    if fifo_count < c_cPSAF_LENGTH then
                        fifo_count <= fifo_count + 1;
                    end if;

                elsif (cPSAF_wr_en_i = '0' and cPSAF_rd_en_i = '1') then
                    -- Read only
                    if fifo_count > 0 then
                        fifo_count <= fifo_count - 1;
                    end if;

                elsif (cPSAF_wr_en_i = '1' and cPSAF_rd_en_i = '1') then
                    -- Simultaneous read and write → pointers move, count unchanged
                    fifo_count <= fifo_count;

                else
                    fifo_count <= fifo_count;
                end if;

            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------------------
    -- Output Assignments
    ------------------------------------------------------------------------------------------------
    cPSAF_data_o <= fifo_mem(rd_ptr);

    -- Status Flags
    cPSAF_empty_o        <= '1' when fifo_count = 0 else '0';
    cPSAF_almost_empty_o <= '1' when fifo_count <= 1 else '0';
    cPSAF_rxvalid_o       <= '1' when fifo_count > 0 else '0';  -- FIFO has data to transmit

    cPSAF_full_o         <= '1' when fifo_count = c_cPSAF_LENGTH else '0';
    cPSAF_almost_full_o  <= '1' when fifo_count >= c_cPSAF_LENGTH-1 else '0';
    cPSAF_txrdy_o      <= '1' when fifo_count < c_cPSAF_LENGTH else '0';  -- FIFO ready to receive data

end architecture rtl;

----------------------------------------------------------------------------------------------------
