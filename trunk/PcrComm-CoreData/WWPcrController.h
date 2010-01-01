//
//  WWPcrController.h
//  PcrComm-CoreData
//
//  Created by Ward Witt on 12/29/09.
//  Copyright 2009 Filmworkers Club. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"

@interface WWPcrController : NSObject {
	NSUserDefaults *defaults;
	AMSerialPort *port;
	IBOutlet NSArrayController *entryController;
	IBOutlet NSTableView *entryTableView;
	IBOutlet NSLevelIndicator *sMeter;
	IBOutlet NSLevelIndicator *centering;
	IBOutlet NSSlider *volumeSlider;
	IBOutlet NSSlider *squelchSlider;
	NSDictionary *modeTable;
	NSDictionary *filterTable;
}
- (IBAction)afGain:(id)sender;
- (IBAction)squelch:(id)sender;
- (IBAction)power:(id)sender;
- (void)setVolume:(int)vol;
- (void)setSquelch:(int)sq;
- (void)powerUpRadio;
- (void)powerDownRadio;
- (void)commMode;

- (void)setPort:(AMSerialPort *)newPort;
- (void)initPort;
- (void)readRadioInBackground;
- (void)parseRadio;
- (void)parseG;
- (void)parseH;
- (void)parseI;
- (void)parseN;

@end
