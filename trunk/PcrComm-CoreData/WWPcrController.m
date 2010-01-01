//
//  WWPcrController.m
//  PcrComm-CoreData
//
//  Created by Ward Witt on 12/29/09.
//  Copyright 2009 Filmworkers Club. All rights reserved.
//

#import "WWPcrController.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"


@implementation WWPcrController
int volume;
int squelch;
BOOL scanEnabled = FALSE;

- (id)init
{
	[super init];
	modeTable = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath]
															stringByAppendingString:@"/Contents/Resources/ModeTable.plist"]];
	if (modeTable == nil)
	{
		NSLog (@"Error unable to open ModeTable.plist");
		[modeTable release];
	} 
	else 
	{
		[modeTable retain];
	}
	filterTable = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath]
															  stringByAppendingString:@"/Contents/Resources/FilterTable.plist"]];
	if (filterTable == nil)
	{
		NSLog (@"Error unable to open FilterTable.plist");
		[filterTable release];
	} 
	else 
	{
		[filterTable retain];
	}
	return self;
}

- (void)awakeFromNib{
	defaults = [NSUserDefaults standardUserDefaults];
    [[entryTableView window]setFrameAutosaveName:@"appWindow"];	// save and restore the location of the window
	[entryController addObserver:self forKeyPath:@"selection.entry" options:NSKeyValueObservingOptionNew context:NULL];
	[self initPort];
	[self readRadioInBackground];
}

- (void)initPort
{
	//NSString *deviceName = @"/dev/cu.KeySerial1";
	NSString *deviceName = @"/dev/cu.usbserial-A20e1rUS";
	[self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
	
	// register as self as delegate for port
	[port setDelegate:self];
	
	// open port - may take a few seconds ...
	if ([port open]) {
		
	} else { // an error occured while creating port
		[self setPort:nil];
	}
}

- (AMSerialPort *)port
{
    return port;
}

- (void)setPort:(AMSerialPort *)newPort
{
    id old = nil;
	
    if (newPort != port) {
        old = port;
        port = [newPort retain];
        [old release];
    }
}

- (void)commMode
{
	Delay(10,NULL);
	if(!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@"G301\r\n" usingEncoding:NSUTF8StringEncoding error:NULL];
	}
}

- (IBAction)afGain:(id)sender
{
	volume = [sender intValue];
	[defaults setInteger:volume forKey:@"savedVolume"];
	[self setVolume:volume];
}

- (IBAction)squelch:(id)sender
{
	squelch = [sender intValue];
	[defaults setInteger:squelch forKey:@"savedSquelch"];
	[self setSquelch:squelch];
}

- (void)powerUpRadio
{
	NSError *theError;
	if(!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@" H101\r\n" usingEncoding:NSUTF8StringEncoding error:&theError];
	}
	[self commMode];
	//	[self bandScopeOn];
}

- (void)powerDownRadio
{
	NSError *theError;
	if(!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@" H100\r\n" usingEncoding:NSUTF8StringEncoding error:&theError];
	}
}

- (IBAction)power:(id)sender
{
	if ([sender intValue])
	{
		int volume = [defaults integerForKey:@"savedVolume"];
		int squelch = [defaults integerForKey:@"savedSquelch"];
		[self powerUpRadio];
		[self setVolume:volume];
		[volumeSlider setIntValue:volume];
		[self setSquelch:squelch];
		[squelchSlider setIntValue:squelch];
	}
	
	else
		[self powerDownRadio];
}

- (void)setVolume:(int)vol
{
	if(!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		NSString * volumeCommand = [NSString stringWithFormat:@"J40%02X", vol];
		[port writeString:volumeCommand usingEncoding:NSUTF8StringEncoding error:NULL];
	}
	
}

- (void)setSquelch:(int)sq
{
	if(!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		NSString * squelchCommand = [NSString stringWithFormat:@"J41%02X", sq];
		[port writeString:squelchCommand usingEncoding:NSUTF8StringEncoding error:NULL];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	NSArray * selectedObject = [[object selectedObjects] objectAtIndex:0];
	
	if(!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	
	NSString *selectedFrequency = [selectedObject valueForKey:@"Frequency"];
	NSString *selectedMode = [selectedObject valueForKey:@"Mode"];
	NSString *selectedFilter = [selectedObject valueForKey:@"Filter"];
	
	// strip decimal point
	NSString *intFreq = [selectedFrequency stringByReplacingOccurrencesOfString:@"." withString:@""];
	NSRange frqRange = NSMakeRange(10 - [intFreq length], [intFreq length]);
	NSString *paddedFreq = [@"0000000000" stringByReplacingCharactersInRange:frqRange withString:intFreq];
	NSString *selMode = [modeTable objectForKey:selectedMode];
	NSString *selFilter = [filterTable objectForKey:selectedFilter];
	NSString *tuning = [NSString stringWithFormat:@"K0%@%@%@00\r\n",paddedFreq, selMode, selFilter];
	NSLog(@"Radio tuned to %@", tuning);
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:tuning usingEncoding:NSUTF8StringEncoding error:NULL];
	}
}


// ============================================================
#pragma mark -
#pragma mark Threaded methods
// ============================================================

- (void)readRadioInBackground
{
	[NSThread detachNewThreadSelector:@selector(parseRadio) toTarget:self withObject:nil];
}

- (void)parseRadio
{
	NSAutoreleasePool *localAutoreleasePool = [[NSAutoreleasePool alloc] init];
	NSError *theError;
	while(1)
	{
		char prefix = 0;
		NSData *firstByte = [port readBytes:1 error:&theError];
		[firstByte getBytes:&prefix length:1];
		// pitch anything thats not a command
		while (prefix <= 'F')
		{
			NSData *firstByte = [port readBytes:1 error:&theError];
			[firstByte getBytes:&prefix length:1];
			//NSLog(@"Lost sync with radio");
		}
		switch (prefix) {
			case 'G': 
				[self parseG];
				break;
			case 'H': 
				[self parseH];
				break;
			case 'I': 
				[self parseI];
				break;
			case 'N':
				[self parseN];
				break;
			default:
				NSLog(@"Unknown command %c",prefix);
		}
		//		// Flush and create a new autorelease pool ever so often
		//		c++;
		//		NSString *count = [NSString stringWithFormat:@"Count = %i", c];
		//		[outputTextView setString:count];
		//		if (c > 1024)
		//		{
		//			[localAutoreleasePool release];
		//			NSAutoreleasePool *localAutoreleasePool = [[NSAutoreleasePool alloc] init];
		//			NSLog(@"Just purged the autoReleasePool");
		//			c = 0;
		//		}
	}
}

- (void) parseG
{
	NSError *theError;
	unsigned char buffer[3];
	NSData *reply = [port readBytes:3 error:&theError];
	[reply getBytes:&buffer length:3];
	switch (buffer[0]) {
		case '0':
			if (buffer[2] == '1')
				NSLog(@"Bad command");
			if (buffer[2] == '0')
				NSLog(@"Good Command");
			break;
		case '2':
			NSLog(@"Protocol %c%c",buffer[1],buffer[2]);
			break;
		case 'D':
			if (buffer[2] == 0)
				NSLog(@"No options");
			if (buffer[2] == 1)
				NSLog(@"DSP Installed");
			if (buffer[2] == 8)
				NSLog(@"DARC Installed");
			break;
		case 'E':
			switch (buffer[2]) {
				case '8':
					NSLog(@"Japan");
					break;
				case '1':
					NSLog(@"USA");
					break;
				case 'A':
					NSLog(@"EUR/AUS/CAN");
					break;
				case 'B':
					NSLog(@"FGA");
					break;
				case 'C':
					NSLog(@"DEN");
					break;
				default:
					NSLog(@"Reserved Country code");
			}
		default:
			NSLog(@"Unknown G responce");
	}
}

- (void)parseH
{
	NSError *theError;
	unsigned char buffer[3];
	NSData *reply = [port readBytes:3 error:&theError];
	[reply getBytes:&buffer length:3];
	switch (buffer[0]) {
		case '1':
			if (buffer[2] == '1')
				NSLog(@"Radio power on");
			if (buffer[2] == '0')
				// NSLog(@"Radio power off");
				break;	
		case '9':
			switch (buffer[2]) {
				case '0':
					NSLog(@"Not in scan mode");
					break;
				case '1':
					NSLog(@"Ready to move the next Freq");
					break;
				case '2':
					NSLog(@"Waiting for squelch");
					break;
				case '3':
					NSLog(@"Reviewing Squelch");
					break;
				case '4':
					NSLog(@"Evaluatig tone squelch");
					break;
				case '5':
					NSLog(@"Evaluating VSC");
					break;
				default:
					NSLog(@"Unknown H9 command");
			}
			if (buffer[1] == 1)
				NSLog(@"Halt due to Busy");
		default:
			NSLog(@"Unknown H response");
	}
}

- (void)parseI
{
	NSError *theError;
	unsigned char buffer[3];
	int i;
	NSData *reply = [port readBytes:3 error:&theError];
	[reply getBytes:&buffer length:3];
	switch (buffer[0]) {
		case '0':
			i = buffer[2] - '0';
			if (i & 1)
			{
				NSLog(@"Busy");
				scanEnabled = FALSE;
			}
			else
			{
				NSLog(@"Not Busy");
				scanEnabled = TRUE;
			}
			if (i & 2)
				NSLog(@"CTSS Open");
			else
				NSLog(@"CTSS Closed");
			if (i & 4)
				NSLog(@"VSC Open");
			else
				NSLog(@"VSC Closed");
			if (i & (1<<7))
				NSLog(@"Receive Error");
			break;
		case '1':
			// hex to decimal conversion
			if (buffer[1] >= 'A')
				buffer[1] = buffer[1] - 55;
			else
				buffer[1] = buffer[1] - 48;
			if (buffer[2] >= 'A')
				buffer[2] = buffer[2] - 55;
			else
				buffer[2] = buffer[2] - 48;
			int s = ((buffer[1] * 16) + buffer[2]);
			[sMeter setIntValue:s];
			break;
		case '2':
			// hex to decimal conversion
			if (buffer[1] >= 'A')
				buffer[1] = buffer[1] - 55;
			else
				buffer[1] = buffer[1] - 48;
			if (buffer[2] >= 'A')
				buffer[2] = buffer[2] - 55;
			else
				buffer[2] = buffer[2] - 48;
			int f = ((buffer[1] * 16) + buffer[2]);
			[centering setIntValue:f];
			break;
		case '3':
			NSLog(@"DTMF Code %c",buffer[2]);
			break;
		default:
			NSLog(@"Unknown I response");
	}
}

- (void)parseN
{
	NSError *theError;
	unsigned char buffer[36];
	NSData *reply = [port readBytes:36 error:&theError];
	[reply getBytes:&buffer length:36];
	NSLog(@"N=%@",reply);
}


@end
