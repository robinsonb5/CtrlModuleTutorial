#include "host.h"

#include "osd.h"

int osd_puts(char *str)
{
	int c;
	while((c=*str++))
		OSD_Putchar(c);
	return(1);
}


int main(int argc,char **argv)
{
	int dipsw=0;
	OSD_Clear();
	osd_puts("Hello, world!\n");
	while(1)
	{
		int i,t;
		for(i=0;i<1000000;++i) // Repeat the write simply as a delay.
			HW_HOST(REG_HOST_SW)=dipsw;
		++dipsw;
		dipsw&=3;
		OSD_Show(1);
		
	}
	return(0);
}
