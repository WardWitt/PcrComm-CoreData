//
//  PcrComm_CoreData_AppDelegate.h
//  PcrComm-CoreData
//
//  Created by Ward Witt on 12/26/09.
//  Copyright Filmworkers Club 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PcrComm_CoreData_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

@end
