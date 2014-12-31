#include "host.h"

#include "osd.h"
#include "keyboard.h"
#include "menu.h"
#include "ps2.h"


int OSD_Puts(char *str)
{
	int c;
	while((c=*str++))
		OSD_Putchar(c);
	return(1);
}


void TriggerEffect(int row)
{
	int i,v;
	Menu_Hide();
	for(v=0;v<=16;++v)
	{
		for(i=0;i<4;++i)
			PS2Wait();

		HW_HOST(REG_HOST_SCALERED)=v;
		HW_HOST(REG_HOST_SCALEGREEN)=v;
		HW_HOST(REG_HOST_SCALEBLUE)=v;
	}
	Menu_Show();
}



static struct menu_entry topmenu[]; // Forward declaration.

// RGB scaling submenu
static struct menu_entry rgbmenu[]=
{
	{MENU_ENTRY_SLIDER,"Red",MENU_ACTION(16)},
	{MENU_ENTRY_SLIDER,"Green",MENU_ACTION(16)},
	{MENU_ENTRY_SLIDER,"Blue",MENU_ACTION(16)},
	{MENU_ENTRY_SUBMENU,"Exit",MENU_ACTION(topmenu)},
	{MENU_ENTRY_NULL,0,0}
};


// Test pattern names
static char *testpattern_labels[]=
{
	"Test pattern 1",
	"Test pattern 2",
	"Test pattern 3",
	"Test pattern 4"
};

// Our toplevel menu
static struct menu_entry topmenu[]=
{
	{MENU_ENTRY_CYCLE,(char *)testpattern_labels,MENU_ACTION(4)},
	{MENU_ENTRY_SUBMENU,"RGB Scaling \x10",MENU_ACTION(rgbmenu)},
	{MENU_ENTRY_TOGGLE,"Scanlines",MENU_ACTION(0)},
	{MENU_ENTRY_CALLBACK,"Animate",MENU_ACTION(&TriggerEffect)},
	{MENU_ENTRY_CALLBACK,"Exit",MENU_ACTION(&Menu_Hide)},
	{MENU_ENTRY_NULL,0,0}
};


int main(int argc,char **argv)
{
	int i;
	int dipsw=0;
	PS2Init();
	EnableInterrupts();
	OSD_Clear();
	Menu_Set(topmenu);
	for(i=0;i<4;++i)
	{
		PS2Wait();	// Wait for an interrupt - most likely VBlank, but could be PS/2 keyboard
		OSD_Show(1);	// Call this over a few frames to let the OSD figure out where to place the window.
	}
	MENU_SLIDER_VALUE(&rgbmenu[0])=8;
	MENU_SLIDER_VALUE(&rgbmenu[1])=8;
	MENU_SLIDER_VALUE(&rgbmenu[2])=8;
	Menu_Show();
	while(1)
	{
		struct menu_entry *m;
		HandlePS2RawCodes();
		Menu_Run();

		dipsw=MENU_CYCLE_VALUE(&topmenu[0]);	// Take the value of the TestPattern cycle menu entry.
		if(MENU_TOGGLE_VALUES&1)
			dipsw|=4;	// Add in the scanlines bit.
		HW_HOST(REG_HOST_SW)=dipsw;	// Send the new values to the hardware.
		HW_HOST(REG_HOST_SCALERED)=MENU_SLIDER_VALUE(&rgbmenu[0]);
		HW_HOST(REG_HOST_SCALEGREEN)=MENU_SLIDER_VALUE(&rgbmenu[1]);
		HW_HOST(REG_HOST_SCALEBLUE)=MENU_SLIDER_VALUE(&rgbmenu[2]);
	}
	return(0);
}
