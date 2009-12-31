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
	[entryController addObserver:self forKeyPath:@"selection.entry" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	NSArray * selectedObject = [object selectedObjects];
	NSLog(@"Selected item = %@",selectedObject);
}	


@end
