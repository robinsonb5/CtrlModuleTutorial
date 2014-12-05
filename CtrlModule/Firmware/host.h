#ifndef HOST_H
#define HOST_H

#define HOSTBASE 0xFFFFFFF0
#define HW_HOST(x) *(volatile unsigned int *)(HOSTBASE+x)

/* SPI registers */

/* DIP switches, bits 15 downto 0 */
#define REG_HOST_SW 0x0C

#endif

