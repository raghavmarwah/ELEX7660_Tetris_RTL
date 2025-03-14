// breakout.c - initialize ST7735S LCD Controller and fill framebuffer with an image

#include "image.h"		// image to write to display
#include "system.h"		// peripheral base addresses
#include <altera_avalon_spi.h> // function to control altera SPI IP
#include <unistd.h>     // usleep()

// delays to be used with usleep() in LCD initialization
#define _10ms (10000)
#define _120ms (120000)

// max dimensions of LCD
#define LCD_MAX_X 127
#define LCD_MAX_Y 127

// ST7735 LCD controller Command Set (from TI sample code)
#define CM_NOP             0x00
#define CM_SWRESET         0x01
#define CM_RDDID           0x04
#define CM_RDDST           0x09
#define CM_SLPIN           0x10
#define CM_SLPOUT          0x11
#define CM_PTLON           0x12
#define CM_NORON           0x13
#define CM_INVOFF          0x20
#define CM_INVON           0x21
#define CM_GAMSET          0x26
#define CM_DISPOFF         0x28
#define CM_DISPON          0x29
#define CM_CASET           0x2A
#define CM_RASET           0x2B
#define CM_RAMWR           0x2C
#define CM_RGBSET          0x2d
#define CM_RAMRD           0x2E
#define CM_PTLAR           0x30
#define CM_MADCTL          0x36
#define CM_COLMOD          0x3A
#define CM_SETPWCTR        0xB1
#define CM_SETDISPL        0xB2
#define CM_FRMCTR3         0xB3
#define CM_SETCYC          0xB4
#define CM_SETBGP          0xb5
#define CM_SETVCOM         0xB6
#define CM_SETSTBA         0xC0
#define CM_SETID           0xC3
#define CM_GETHID          0xd0
#define CM_SETGAMMA        0xE0
#define CM_MADCTL_MY       0x80
#define CM_MADCTL_MX       0x40
#define CM_MADCTL_MV       0x20
#define CM_MADCTL_ML       0x10
#define CM_MADCTL_BGR      0x08
#define CM_MADCTL_MH       0x04

// Correction factors for display offsets (deduced from TI sample code, but not sure why)
#define X_CORRECTION_OFFSET 2
#define Y_CORRECTION_OFFSET 1

// Argument for isData in lcdWrite function
#define DATA 1
#define CMD 0

#define LCD_RS  0x01   // LCD Register Select bit (1 for data, 0 for command)
#define LCD_RST 0x02   // LCD Reset (active low)


///////////////////////////////////////////////////////////////////////
// lcdWrite - Sends a command/data byte to the LCD.
// Arguments: byte - value to be sent to the LCD
//            isData - true if byte is data, false if byte is a command
// Return Value: none
///////////////////////////////////////////////////////////////////////
void lcdWrite(unsigned char byte, int isData);

int main()
{
	int x, y ; // array indices used to access pixel data in image array

	// send controller initialization sequence (deduced from TI Sample Code)
	(*(int*)PIO_BASE) &= ~LCD_RST;
	usleep(_120ms);
	(*(int*)PIO_BASE) |= LCD_RST;
	usleep(_120ms);

	lcdWrite(CM_SLPOUT, CMD);
	usleep(_120ms);

	lcdWrite(CM_GAMSET, CMD);
	lcdWrite(0x04, DATA);

	lcdWrite(CM_SETPWCTR, CMD);
	lcdWrite(0x0A, DATA);
	lcdWrite(0x14, DATA);

	lcdWrite(CM_SETSTBA, CMD);
	lcdWrite(0x0A, DATA);
	lcdWrite(0x00, DATA);

	lcdWrite(CM_COLMOD, CMD);
	lcdWrite(0x05, DATA);
	usleep(_10ms);

	lcdWrite(CM_MADCTL, CMD);
	lcdWrite(CM_MADCTL_BGR, DATA);

	lcdWrite(CM_NORON, CMD);

    usleep(_10ms);
	lcdWrite(CM_DISPON, CMD);

	// display image

	// set x range
	lcdWrite(CM_CASET, CMD);
	lcdWrite(0, DATA);
	lcdWrite(X_CORRECTION_OFFSET, DATA);
	lcdWrite(0, DATA);
	lcdWrite(LCD_MAX_X + X_CORRECTION_OFFSET, DATA);

	// set y range
    lcdWrite(CM_RASET, CMD);
	lcdWrite(0, DATA);
	lcdWrite(Y_CORRECTION_OFFSET, DATA);
	lcdWrite(0, DATA);
	lcdWrite(LCD_MAX_Y + Y_CORRECTION_OFFSET, DATA);

	// set RAM for writing
    lcdWrite(CM_RAMWR, CMD);

    // fill framebuffer
    for ( x = IMAGE_WIDTH ; x > 0  ; x-- ) {
      for ( y = IMAGE_HEIGHT ; y > 0  ; y-- ) {
    	  // send 16 bits representing the pixel colour: RRRRRGGG_GGGBBBBB
          lcdWrite(image[(x*IMAGE_HEIGHT+y)*BYTES_PER_PIXEL], DATA);
          lcdWrite(image[(x*IMAGE_HEIGHT+y)*BYTES_PER_PIXEL+1], DATA);
       }
	}
    while(1);
}


///////////////////////////////////////////////////////////////////////
// lcdWrite - Sends a command/data byte to the LCD.
// Arguments: byte - value to be sent to the LCD
//            isData - true if byte is data, false if byte is a command
// Return Value: none
///////////////////////////////////////////////////////////////////////
void lcdWrite(unsigned char byte, int isData)
{
	unsigned char data;

	data = byte;

    // set/clear register select pin
    if (isData)
    	(*(int*)PIO_BASE) |= LCD_RS;
    else
    	(*(int*)PIO_BASE) &= ~LCD_RS;

    // Transmit data/command
	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &data, 0, NULL, 0) ;
}
