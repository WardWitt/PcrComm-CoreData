//
//  WWPcrController.m
//  PcrComm-CoreData
//
//  Created by Ward Witt on 12/29/09.
//  Copyright 2009 Filmworkers Club. All rights reserved.
//

#import "WWPcrController.h"


@implementation WWPcrController

- (void)awakeFromNib{
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
