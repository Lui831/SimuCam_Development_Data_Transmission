--------------------------------------------------------------------------------------------------------------------------------------
-- codec_PUS_Avalon_Read.vhd
-- Authors: Luiz H. A. Santos, Thiago A. M. Amaral.
-- Date: 23-05-2025.
-- Description: this code is responsible for enabling read operations by the Avalon interface to the codec PUS itself.
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

entity codec_PUS_Avalon_Read is

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

end entity codec_PUS_Avalon_Read;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Architecture declaration

architecture rtl of codec_PUS_Avalon_Read is

	signal s_data_acquired : std_logic;
	signal s_int_wait_request : std_logic;

begin

    -- Process for receiving write requests and writing data
	p_avalon_mm_read : process(clk_i, rst_i) is

        procedure p_read_all_registers(read_address_i : t_codec_PUS_rd_regs_addr) is
        begin
            -- Case statement to determine which register to read based on the address
            case read_address_i is
                when 0 =>
                    -- Control Register (example: concatenates all bits, inverted order)
                    -- cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(0) <= cPAR_controller_rd_regs.control_reg.proc_rst;
                    cPAR_avalon_mm_read_data_o(1) <= cPAR_controller_rd_regs.control_reg.en;
                    cPAR_avalon_mm_read_data_o(2) <= cPAR_controller_rd_regs.control_reg.recv_en;
                    cPAR_avalon_mm_read_data_o(3) <= cPAR_controller_rd_regs.control_reg.send_en;
                    cPAR_avalon_mm_read_data_o(4) <= cPAR_controller_rd_regs.control_reg.irq_en;
                    cPAR_avalon_mm_read_data_o(5) <= cPAR_controller_rd_regs.control_reg.recv_irq_en;
                    cPAR_avalon_mm_read_data_o(6) <= cPAR_controller_rd_regs.control_reg.send_irq_en;
                when 1 =>
                    -- PKG_PRIM_HDR1
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(2 downto 0)   <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR1.pkg_vernum;
                    cPAR_avalon_mm_read_data_o(3)            <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR1.pkg_type(0);
                    cPAR_avalon_mm_read_data_o(4)            <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR1.sec_hdr_flag(0);
                    cPAR_avalon_mm_read_data_o(15 downto 5)  <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR1.apid;
                    cPAR_avalon_mm_read_data_o(17 downto 16) <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR1.seq_flags;
                    cPAR_avalon_mm_read_data_o(31 downto 18) <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR1.seq_count;
                when 2 =>
                    -- PKG_PRIM_HDR2
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(15 downto 0) <= cPAR_controller_rd_regs.recv_PKG_PRIM_HDR2.pkg_data_len;
                when 3 =>
                    -- PKG_SEC_HDR1
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(3 downto 0)   <= cPAR_controller_rd_regs.recv_PKG_SEC_HDR1.pusvnum;
                    cPAR_avalon_mm_read_data_o(7 downto 4)   <= cPAR_controller_rd_regs.recv_PKG_SEC_HDR1.ack_flags;
                    cPAR_avalon_mm_read_data_o(15 downto 8)  <= cPAR_controller_rd_regs.recv_PKG_SEC_HDR1.service_id;
                    cPAR_avalon_mm_read_data_o(23 downto 16) <= cPAR_controller_rd_regs.recv_PKG_SEC_HDR1.subservice_id;
                when 4 =>
                    -- PKG_SEC_HDR2
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(15 downto 0) <= cPAR_controller_rd_regs.recv_PKG_SEC_HDR2.source_id;
                when 5 =>
                    -- PKG_ADDR
                    cPAR_avalon_mm_read_data_o <= cPAR_controller_rd_regs.recv_pkg_addr.pkg_addr;
                when 6 =>
                    -- STATUS
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(7 downto 0) <= cPAR_controller_rd_regs.recv_status.status_flags;
                when 7 =>
                    -- SEND_PKG_PRIM_HDR1
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(10 downto 0)  <= cPAR_controller_rd_regs.send_PKG_PRIM_HDR1.apid;
                    cPAR_avalon_mm_read_data_o(26 downto 11) <= cPAR_controller_rd_regs.send_PKG_PRIM_HDR1.pkg_data_len;
                when 8 =>
                    -- SEND_PKG_PRIM_HDR2
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(13 downto 0) <= cPAR_controller_rd_regs.send_PKG_PRIM_HDR2.seq_count; 
                when 9 =>
                    -- SEND_PKG_SEC_HDR1
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(3 downto 0)   <= cPAR_controller_rd_regs.send_PKG_SEC_HDR1.spacecraft_time_ref;
                    cPAR_avalon_mm_read_data_o(11 downto 4)  <= cPAR_controller_rd_regs.send_PKG_SEC_HDR1.service_id;
                    cPAR_avalon_mm_read_data_o(19 downto 12) <= cPAR_controller_rd_regs.send_PKG_SEC_HDR1.subservice_id;
                when 10 =>
                    -- SEND_PKG_SEC_HDR2
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(15 downto 0)  <= cPAR_controller_rd_regs.send_PKG_SEC_HDR2.msg_type_counter;
                    cPAR_avalon_mm_read_data_o(31 downto 16) <= cPAR_controller_rd_regs.send_PKG_SEC_HDR2.dest_id;
                when 11 =>
                    -- SEND_PKG_SEC_HDR3
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(15 downto 0) <= cPAR_controller_rd_regs.send_PKG_SEC_HDR3.time;
                when 12 =>
                    -- SEND_PKG_ADDR
                    cPAR_avalon_mm_read_data_o <= cPAR_controller_rd_regs.send_pkg_addr.pkg_addr;
                when 13 =>
                    -- HANDLING SEND
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(0) <= cPAR_controller_rd_regs.handling.irq_send_clr;
                    cPAR_avalon_mm_read_data_o(8 downto 1) <= cPAR_controller_rd_regs.handling.data_send_success_flags;
                    cPAR_avalon_mm_read_data_o(9) <= cPAR_controller_rd_regs.handling.data_send_wr_flag;
                    cPAR_avalon_mm_read_data_o(10) <= cPAR_controller_rd_regs.handling.data_send_rdy_flag;
                when 14 =>
                    -- HANDLING RECV
                    cPAR_avalon_mm_read_data_o <= (others => '0');
                    cPAR_avalon_mm_read_data_o(0) <= cPAR_controller_rd_regs.handling.irq_rcv_clr;
                    cPAR_avalon_mm_read_data_o(1) <= cPAR_controller_rd_regs.handling.data_rcv_rd_flag;
                    cPAR_avalon_mm_read_data_o(2) <= cPAR_controller_rd_regs.handling.data_rcv_rdy_flag;
                when 15 =>
                    -- RECV MEM OFFSET
                    cPAR_avalon_mm_read_data_o <= cPAR_controller_rd_regs.recv_mem_offset.mem_offset;
                when 16 =>
                    -- RECV FIFO SIZE
                    cPAR_avalon_mm_read_data_o <= cPAR_controller_rd_regs.recv_fifo_size.fifo_size;
                when 17 =>
                    -- SEND MEM OFFSET
                    cPAR_avalon_mm_read_data_o <= cPAR_controller_rd_regs.send_mem_offset.mem_offset;
                when 18 =>
                    -- SEND FIFO SIZE
                    cPAR_avalon_mm_read_data_o <= cPAR_controller_rd_regs.send_fifo_size.fifo_size;
   

                when others =>
                    cPAR_avalon_mm_read_data_o <= (others => '0');
            end case;

        end procedure p_read_all_registers;

        variable v_read_address : t_codec_PUS_rd_regs_addr := 0;
    begin
        if (rst_i = '1') then
            cPAR_avalon_mm_read_data_o    <= (others => '0');
            s_int_wait_request <= '1';
            s_data_acquired <= '0';
        elsif (rising_edge(clk_i)) then
            cPAR_avalon_mm_read_data_o    <= (others => '0');
            s_data_acquired <= '0';
            s_int_wait_request <= '1';

            if s_data_acquired = '0' then

                if (cPAR_avalon_mm_read_i = '1') then
                    v_read_address := to_integer(unsigned(cPAR_avalon_mm_address_i));
                    s_int_wait_request <= '0';
                    s_data_acquired <= '1';
                    p_read_all_registers(v_read_address);
                end if;

            else

                s_int_wait_request <= '0';
                s_data_acquired <= '0';

            end if;

        end if;
    end process p_avalon_mm_read;

    cPAR_avalon_mm_wait_request_o <= s_int_wait_request;

end architecture rtl;

--------------------------------------------------------------------------------------------------------------------------------------