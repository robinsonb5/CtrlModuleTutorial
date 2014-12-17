#include "host.h"

#include "osd.h"
#include "keyboard.h"
#include "ps2.h"


int OSD_Puts(char *str)
{
	int c;
	while((c=*str++))
		OSD_Putchar(c);
	return(1);
}


int main(int argc,char **argv)
{
	int dipsw=0;
	int osd_enabled=1;
	PS2Init();
	EnableInterrupts();
	OSD_Clear();
	OSD_Puts("Press F1-F4 to change pattern\n");
	OSD_Puts("Press F12 to show/hide the OSD\n");
	while(1)
	{
		HandlePS2RawCodes();
		if(TestKey(KEY_F12)&2) // Has the key been pressed since the last test (as opposed to being held down)
			osd_enabled^=1;
		OSD_Show(osd_enabled);		

		if(TestKey(KEY_F1))
			dipsw=0;
		if(TestKey(KEY_F2))
			dipsw=1;
		if(TestKey(KEY_F3))
			dipsw=2;
		if(TestKey(KEY_F4))
			dipsw=3;
		HW_HOST(REG_HOST_SW)=dipsw;
	}
	return(0);
}
