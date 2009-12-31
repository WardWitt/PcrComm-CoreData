//
//  WWPcrController.h
//  PcrComm-CoreData
//
//  Created by Ward Witt on 12/29/09.
//  Copyright 2009 Filmworkers Club. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WWPcrController : NSObject {
	NSUserDefaults *defaults;
	IBOutlet NSArrayController *entryController;
	NSDictionary *modeTable;
	NSDictionary *filterTable;

}

@end
