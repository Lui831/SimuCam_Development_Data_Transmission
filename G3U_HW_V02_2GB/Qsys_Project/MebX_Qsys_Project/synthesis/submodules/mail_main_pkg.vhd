--------------------------------------------------------------------------------------------------------------------------------------
-- mail_main_pkg.vhd
-- Authors: Luiz H. A. Santos, Pedro A. W. Dian, João P. Fogetti, Rafaella C. Zeron.
-- Date: 30/04/2025
-- Description: this package defines all the important types and constants important to the entire mailbox.
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Important libraries

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Package declaration

package mail_main_pkg is

    -- General Definitions ---------------------------------------------------------------

    -- Avalon MM Interface Definitions --

    -- Avalon Interface Constants --

    constant c_MAIL_AVALON_MM_DATA_WIDTH : integer := 32; -- Data width of the Avalon MM interface
    constant c_MAIL_AVALON_MM_ADDR_WIDTH : integer := 2; -- Address width of the Avalon MM interface

    -- Avalon MM Read Interface Types --

    -- Avalon MM Read Interface input signals
    type t_mail_read_avalon_mm_interface_i is record
        read : std_logic; -- Read signal from the Avalon MM to the module
        address : std_logic_vector(c_MAIL_AVALON_MM_ADDR_WIDTH - 1 downto 0); -- Address to be read
    end record t_mail_read_avalon_mm_interface_i;

    -- Avalon MM Read Interface output signals
    type t_mail_read_avalon_mm_interface_o is record
        read_data : std_logic_vector(c_MAIL_AVALON_MM_DATA_WIDTH - 1 downto 0); -- Data to be read
        wait_request : std_logic; -- Wait request signal from the module to the Avalon MM
    end record t_mail_read_avalon_mm_interface_o;

    -- Avalon MM Write Interface Types --

    -- Avalon MM Write Interface input signals
    type t_mail_write_avalon_mm_interface_i is record
        write : std_logic; -- Write signal from the Avalon MM to the module
        address : std_logic_vector(c_MAIL_AVALON_MM_ADDR_WIDTH - 1 downto 0); -- Address to be written
        write_data : std_logic_vector(c_MAIL_AVALON_MM_DATA_WIDTH - 1 downto 0); -- Data to be written
    end record t_mail_write_avalon_mm_interface_i;

    -- Avalon MM Write Interface output signals
    type t_mail_write_avalon_mm_interface_o is record
        wait_request : std_logic; -- Wait request signal from the module to the Avalon MM
    end record t_mail_write_avalon_mm_interface_o;

    -- Avalon read and write address subtypes
    subtype t_mail_read_address is std_logic_vector(c_MAIL_AVALON_MM_ADDR_WIDTH - 1 downto 0);
    subtype t_mail_write_address is std_logic_vector(c_MAIL_AVALON_MM_ADDR_WIDTH - 1 downto 0);

    -- Avalon MM Output signals RESET Constants --

    -- RESET constant for the Avalon MM Read Interface output signals
    constant c_MAIL_READ_AVALON_MM_INTERFACE_O_RST : t_mail_read_avalon_mm_interface_o := (
        read_data => (others => '0'),
        wait_request => '0'
    );

    -- RESET constant for the Avalon MM Write Interface output signals
    constant c_MAIL_WRITE_AVALON_MM_INTERFACE_O_RST : t_mail_write_avalon_mm_interface_o := (
        wait_request => '0'
    );

    -- Mailbox Main Registers ---------------------------------------------------------------

    -- Important constants

    -- WIDTH of the message num regarding the fifo
    constant c_MAIL_MESSAGE_NUM_WIDTH : integer := 16;

    -- WIDTH of the message num regarding the mailbox
    constant c_MAIL_MESSAGE_WIDTH : integer := 32;


    -- WR Registers --

    -- Recv Registers --

    -- Control Register
    type t_mail_recv_control_reg is record
        proc_rst : std_logic; -- Reset from the processor to the module
        en : std_logic;       -- Enable signal from the processor
        en_irq : std_logic;   -- IRQ en signal from the processor
        clr_irq : std_logic;  -- IRQ clr signal from the processor - Autoreset
    end record t_mail_recv_control_reg;

    -- Message Register
    type t_mail_recv_message_reg is record
        msg : std_logic_vector(c_MAIL_MESSAGE_WIDTH - 1 downto 0); -- Message to be sent
    end record t_mail_recv_message_reg;

    -- Send Registers --

    -- Message Register
    type t_mail_send_message_reg is record
        msg : std_logic_vector(c_MAIL_MESSAGE_WIDTH - 1 downto 0); -- Message to be sent
    end record t_mail_send_message_reg;


    -- RD Register --

    -- Recv Registers --

    -- Status Register
    type t_mail_recv_status_reg is record
        empty : std_logic; -- Empty signal from the module to the processor
        full : std_logic;  -- Full signal from the module to the processor
        msg_num : std_logic_vector(c_MAIL_MESSAGE_NUM_WIDTH - 1 downto 0); -- Message num to be sent
    end record t_mail_recv_status_reg;

    -- Send Registers --

    -- Status Register
    type t_mail_send_status_reg is record
        empty : std_logic; -- Empty signal from the module to the processor
        full : std_logic;  -- Full signal from the module to the processor
        msg_num : std_logic_vector(c_MAIL_MESSAGE_NUM_WIDTH - 1 downto 0); -- Message num to be sent
    end record t_mail_send_status_reg;


    -- Mailbox FIFO -------------------------------------------------------------------


    -- Particular Constants --

    -- Size of the FIFO
    constant c_MAIL_FIFO_SIZE : integer := 255; -- Size of the FIFO

    -- Particular Types --

    -- FIFO data type
    type t_mail_fifo_data_array is array (0 to c_MAIL_FIFO_SIZE - 1) of std_logic_vector(c_MAIL_MESSAGE_WIDTH - 1 downto 0); -- FIFO data type

    -- Particular RESET Constants --

    -- RESET constant for the FIFO data
    constant c_MAIL_FIFO_DATA_RST : t_mail_fifo_data_array := (others => (others => '0')); -- FIFO data RESET constant


    -- External Constants --

    -- External Types --

    -- FIFO from Avalon MM Read module
    type t_mail_fifo_from_avalon_mm_read is record
        rd_en : std_logic; -- Read signal from the Avalon MM to the module
    end record t_mail_fifo_from_avalon_mm_read;

    -- FIFO from Avalon MM Write module
    type t_mail_fifo_from_avalon_mm_write is record
        wr_en : std_logic; -- Write signal from the Avalon MM to the module
        write_data : std_logic_vector(c_MAIL_MESSAGE_WIDTH - 1 downto 0); -- Data to be written
    end record t_mail_fifo_from_avalon_mm_write;

    -- FIFO to Avalon MM Read module
    type t_mail_fifo_to_avalon_mm_read is record
        rd_data : std_logic_vector(c_MAIL_MESSAGE_WIDTH - 1 downto 0); -- Data to be read
        rxvalid : std_logic; -- Valid signal from the module to the Avalon MM
        empty : std_logic; -- Empty signal from the module to the Avalon MM
        full : std_logic; -- Full signal from the module to the Avalon MM
        msg_num : std_logic_vector(c_MAIL_MESSAGE_NUM_WIDTH - 1 downto 0); -- Message num to be sent
    end record t_mail_fifo_to_avalon_mm_read;

    -- FIFO to Avalon MM Write module
    type t_mail_fifo_to_avalon_mm_write is record
        txvalid : std_logic; -- Valid signal from the module to the Avalon MM
        full : std_logic; -- Full signal from the module to the Avalon MM
    end record t_mail_fifo_to_avalon_mm_write;

    -- External RESET Constants --

    -- RESET constant for the Avalon MM Read module
    constant c_MAIL_FIFO_TO_AVALON_MM_READ_RST : t_mail_fifo_to_avalon_mm_read := (
        rd_data => (others => '0'),
        rxvalid => '0',
        empty => '1',
        full => '0',
        msg_num => (others => '0')
    );

    -- RESET constant for the Avalon MM Write module
    constant c_MAIL_FIFO_TO_AVALON_MM_WRITE_RST : t_mail_fifo_to_avalon_mm_write := (
        txvalid => '0',
        full => '0'
    );


    -- Send Avalon MM Read -------------------------------------------------------------------

    -- Particular Constants

    -- Particular Types

    -- Particular RESET Constants


    -- External Constants

    -- External Types

    -- Alias for the Avalon signals
    alias t_mail_send_read_avalon_mm_from_inteface_i is t_mail_read_avalon_mm_interface_i;
    alias t_mail_send_read_avalon_mm_to_inteface_o is t_mail_read_avalon_mm_interface_o;

    -- Alias for the fifo
    alias t_mail_send_read_avalon_mm_from_fifo_i is t_mail_fifo_to_avalon_mm_read;

    -- Aliases for determining the FIFOs input and output ports

    -- External RESET Constants


    -- Send Avalon MM Write -------------------------------------------------------------------

    -- Particular Constants

    -- Particular Types

    -- Particular RESET Constants


    -- External Constants

    -- External Types

    -- Aliases for the Avalon MM signals
    alias t_mail_send_write_avalon_mm_from_interface_i is t_mail_write_avalon_mm_interface_i;
    alias t_mail_send_write_avalon_mm_to_interface_o is t_mail_write_avalon_mm_interface_o;

    -- Alias for the fifo
    alias t_mail_send_write_avalon_mm_from_fifo_i is t_mail_fifo_to_avalon_mm_write;
    alias t_mail_send_write_avalon_mm_to_fifo_o is t_mail_fifo_from_avalon_mm_write;

    -- Aliases for determining the FIFOs input and output ports

    -- External RESET Constants

    -- RESET constant for the FIFO output signals
    constant c_MAIL_SEND_WRITE_AVALON_MM_TO_FIFO_RST : t_mail_send_write_avalon_mm_to_fifo_o := (
        wr_en => '0',
        write_data => (others => '0')
    );


    -- Recv Avalon MM Write -------------------------------------------------------------------

    -- Particular Constants

    -- Particular Types

    -- Particular RESET Constants


    -- External Constants

    -- External Types

    -- Aliases for the Avalon signals
    alias t_mail_recv_write_avalon_mm_from_interface_i is t_mail_write_avalon_mm_interface_i;
    alias t_mail_recv_write_avalon_mm_to_interface_o is t_mail_write_avalon_mm_interface_o;

    -- Aliases for the fifo
    alias t_mail_recv_write_avalon_mm_from_fifo_i is t_mail_fifo_to_avalon_mm_write;
    alias t_mail_recv_write_avalon_mm_to_fifo_o is t_mail_fifo_from_avalon_mm_write;

    -- Alias for the output cntrl reg
    alias t_mail_recv_write_avalon_mm_to_system_o is t_mail_recv_control_reg;

    -- Aliases for determining the FIFOs input and output ports

    -- External RESET Constants

    -- RESET constant for the cntrl reg
    constant c_MAIL_RECV_WRITE_AVALON_MM_CNTRL_REG_RST : t_mail_recv_control_reg := (
        proc_rst => '0',
        en => '0',
        en_irq => '0',
        clr_irq => '0'
    );


    -- Recv Avalon MM Read -------------------------------------------------------------------

    -- Particular Constants

    -- Particular Types

    -- Particular RESET Constants


    -- External Constants

    -- External Types

    -- Alias for the Avalon signals
    alias t_mail_recv_read_avalon_mm_from_inteface_i is t_mail_read_avalon_mm_interface_i;
    alias t_mail_recv_read_avalon_mm_to_inteface_o is t_mail_read_avalon_mm_interface_o;

    -- Aliases for the fifo
    alias t_mail_recv_read_avalon_mm_from_fifo_i is t_mail_fifo_to_avalon_mm_read;
    alias t_mail_recv_read_avalon_mm_to_fifo_o is t_mail_fifo_from_avalon_mm_read;

    -- Alias for the cntrl reg
    alias t_mail_recv_read_avalon_mm_from_system_i is t_mail_recv_control_reg;

    -- Aliases for determining the FIFOs input and output ports

    -- External RESET Constants

end package mail_main_pkg;

--------------------------------------------------------------------------------------------------------------------------------------
-- Package body declaration

package body mail_main_pkg is
end package body mail_main_pkg;

--------------------------------------------------------------------------------------------------------------------------------------