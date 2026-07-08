/*
 * libftdi1_stub.c — link-time stub for libftdi1 on hosts without the library.
 *
 * opentitantool links its FTDI transport unconditionally, but in simulation
 * (dvsim sw_build: image assembly only) no FTDI code path is ever executed.
 * This stub satisfies the linker; if any function is actually called it
 * aborts loudly so misuse cannot go unnoticed.
 *
 * Symbol list: undefined ftdi_* references across libftdi1-sys 1.1.3 consumers
 * (ftdi-0.1.3, ftdi-embedded-hal, opentitanlib ftdi transport).
 */
#include <stdio.h>
#include <stdlib.h>

#define FTDI_STUB(name)                                              \
    int name(void)                                                   \
    {                                                                \
        fprintf(stderr, "FATAL: libftdi1 stub called: %s\n", #name); \
        abort();                                                     \
    }

FTDI_STUB(ftdi_free)
FTDI_STUB(ftdi_get_error_string)
FTDI_STUB(ftdi_get_latency_timer)
FTDI_STUB(ftdi_new)
FTDI_STUB(ftdi_read_data)
FTDI_STUB(ftdi_read_data_get_chunksize)
FTDI_STUB(ftdi_read_data_set_chunksize)
FTDI_STUB(ftdi_set_baudrate)
FTDI_STUB(ftdi_set_bitmode)
FTDI_STUB(ftdi_set_error_char)
FTDI_STUB(ftdi_set_event_char)
FTDI_STUB(ftdi_setflowctrl)
FTDI_STUB(ftdi_set_interface)
FTDI_STUB(ftdi_set_latency_timer)
FTDI_STUB(ftdi_set_line_property)
FTDI_STUB(ftdi_usb_close)
FTDI_STUB(ftdi_usb_open_bus_addr)
FTDI_STUB(ftdi_usb_open_desc_index)
FTDI_STUB(ftdi_usb_purge_buffers)
FTDI_STUB(ftdi_usb_purge_tx_buffer)
FTDI_STUB(ftdi_usb_reset)
FTDI_STUB(ftdi_write_data)
FTDI_STUB(ftdi_write_data_get_chunksize)
FTDI_STUB(ftdi_write_data_set_chunksize)
