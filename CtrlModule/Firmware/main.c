#include "host.h"

int main(int argc,char **argv)
{
	int dipsw=0;
	while(1)
	{
		int i,t;
		for(i=0;i<1000000;++i) // Repeat the write simply as a delay.
			HW_HOST(REG_HOST_SW)=dipsw;
		++dipsw;
		dipsw&=3;
	}
	return(0);
}
