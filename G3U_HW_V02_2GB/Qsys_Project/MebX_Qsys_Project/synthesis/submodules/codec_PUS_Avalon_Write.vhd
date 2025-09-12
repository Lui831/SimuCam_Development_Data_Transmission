--------------------------------------------------------------------------------------------------------------------------------------
-- codec_PUS_Avalon_Write.vhd.
-- Authors: Luiz H. A. Santos, Thiago A. M. Amaral.
-- Date: 23-05-2025.
-- Description: this code is responsible for enabling write operations by the Avalon interface to the codec PUS itself.
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Important libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.codec_PUS_main_pkg.all;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Entity declaration

entity codec_PUS_Avalon_Write is

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

end entity codec_PUS_Avalon_Write;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of codec_PUS_Avalon_Write is

    signal s_wr_regs : t_codec_PUS_wr_regs := c_CODEC_PUS_WR_REGS_RST;
    signal s_data_written : std_logic := '0';
    signal s_int_wait_request : std_logic := '1';

begin

    p_avalon_mm_write : process(clk_i, rst_i)
        procedure p_write_all_registers(write_address_i : t_codec_PUS_wr_regs_addr; write_data_i : std_logic_vector(c_cPAW_AVALON_DATA_WIDTH-1 downto 0)) is
        begin
            case write_address_i is
                when 0 =>
                    -- Control Register
                    s_wr_regs.control_reg.proc_rst    <= write_data_i(0);
                    s_wr_regs.control_reg.en          <= write_data_i(1);
                    s_wr_regs.control_reg.recv_en     <= write_data_i(2);
                    s_wr_regs.control_reg.send_en     <= write_data_i(3);
                    s_wr_regs.control_reg.irq_en      <= write_data_i(4);
                    s_wr_regs.control_reg.recv_irq_en <= write_data_i(5);
                    s_wr_regs.control_reg.send_irq_en <= write_data_i(6);
                when 7 =>
                    -- SEND_PKG_PRIM_HDR1
                    s_wr_regs.send_PKG_PRIM_HDR1.apid         <= write_data_i(10 downto 0);
                    s_wr_regs.send_PKG_PRIM_HDR1.pkg_data_len <= write_data_i(26 downto 11);
                when 8 =>
                    -- SEND_PKG_PRIM_HDR2
                    s_wr_regs.send_PKG_PRIM_HDR2.seq_count <= write_data_i(13 downto 0);
                when 9 =>
                    -- SEND_PKG_SEC_HDR1
                    s_wr_regs.send_PKG_SEC_HDR1.spacecraft_time_ref <= write_data_i(3 downto 0);
                    s_wr_regs.send_PKG_SEC_HDR1.service_id          <= write_data_i(11 downto 4);
                    s_wr_regs.send_PKG_SEC_HDR1.subservice_id       <= write_data_i(19 downto 12);
                when 10 =>
                    -- SEND_PKG_SEC_HDR2
                    s_wr_regs.send_PKG_SEC_HDR2.msg_type_counter <= write_data_i(15 downto 0);
                    s_wr_regs.send_PKG_SEC_HDR2.dest_id          <= write_data_i(31 downto 16);
                when 11 =>
                    -- SEND_PKG_SEC_HDR3
                    s_wr_regs.send_PKG_SEC_HDR3.time <= write_data_i(15 downto 0);
                when 12 =>
                    -- SEND_PKG_ADDR
                    s_wr_regs.send_pkg_addr.pkg_addr <= write_data_i;
                when 13 =>
                    -- HANDLING SEND
                    s_wr_regs.handling.data_send_wr_flag      <= write_data_i(9);
                    s_wr_regs.handling.irq_send_clr           <= write_data_i(0);
                when 14 =>
                    -- HANDLING RECV
                    s_wr_regs.handling.irq_rcv_clr            <= write_data_i(0);
                    s_wr_regs.handling.data_rcv_rd_flag       <= write_data_i(1);
                when 15 =>
                    -- RECV_MEM_OFFSET
                    s_wr_regs.recv_mem_offset.mem_offset <= write_data_i;
                when 16 =>
                    -- RECV_FIFO_SIZE
                    s_wr_regs.recv_fifo_size.fifo_size   <= write_data_i;
                when 17 =>
                    -- SEND_MEM_OFFSET
                    s_wr_regs.send_mem_offset.mem_offset <= write_data_i;
                when 18 =>
                    -- SEND_FIFO_SIZE
                    s_wr_regs.send_fifo_size.fifo_size   <= write_data_i;
                    
    
                when others =>
                    null;
            end case;
        end procedure p_write_all_registers;

        variable v_write_address : t_codec_PUS_wr_regs_addr := 0;
    begin
        if (rst_i = '1') then
            s_wr_regs <= c_CODEC_PUS_WR_REGS_RST;
            cPAW_controller_wr_flag <= '0';
            s_int_wait_request <= '1';
            s_data_written <= '0';
        elsif rising_edge(clk_i) then
            s_int_wait_request <= '1';
            s_data_written <= '0';
            cPAW_controller_wr_flag <= '0';

            -- Always write registers from the Controller module
            s_wr_regs <= cPAW_controller_wr_regs_i;

            -- Resets the IRQ clr signals to 0
            s_wr_regs.handling.irq_rcv_clr  <= '0';
            s_wr_regs.handling.irq_send_clr <= '0';

            if s_data_written = '0' then
                if (cPAW_avalon_mm_write_i = '1') then
                    v_write_address := to_integer(unsigned(cPAW_avalon_mm_address_i));
                    s_int_wait_request <= '0';
                    s_data_written <= '1';
                    cPAW_controller_wr_flag <= '1';
                    p_write_all_registers(v_write_address, cPAW_avalon_mm_write_data_i);
                end if;
            else
                cPAW_controller_wr_flag <= '0';
                s_int_wait_request <= '0';
                s_data_written <= '0';
            end if;
        end if;

    end process p_avalon_mm_write;

    cPAW_controller_wr_regs <= s_wr_regs;
    cPAW_avalon_mm_wait_request_o <= s_int_wait_request;

end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------