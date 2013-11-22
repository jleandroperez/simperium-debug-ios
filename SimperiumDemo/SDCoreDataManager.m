//
//  SDCoreDataManager.m
//  SimperiumDemo
//
//  Created by Jorge Leandro Perez on 7/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SDCoreDataManager.h"



@interface SDCoreDataManager ()

@property (readwrite, strong, nonatomic) NSManagedObjectContext*		managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel*			managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator*	persistentStoreCoordinator;
@property (readwrite, strong, nonatomic) Simperium*						simperium;

@end


@implementation SDCoreDataManager

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
	static dispatch_once_t pred;
	static SDCoreDataManager* _instance = nil;
	
	dispatch_once(&pred, ^{
		_instance = [[[self class] alloc] init];
	});
	
	return _instance;
}

- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel != nil)
	{
        return _managedObjectModel;
    }
	
    NSURL* modelURL		= [[NSBundle mainBundle] URLForResource:@"SimperiumDemo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil)
	{
        return _managedObjectContext;
    }

    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    return _managedObjectContext;
}


- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
	{
        return _persistentStoreCoordinator;
    }
    
    NSURL* storeURL	= [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimperiumDemo.sqlite"];
    NSError* error	= nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (void)startupSimperiumWithAppId:(NSString*)appId APIKey:(NSString*)APIKey rootViewController:(UIViewController*)rootViewController
{
	self.simperium = [[Simperium alloc] initWithRootViewController:rootViewController];
	self.simperium.verboseLoggingEnabled = YES;
	[self.simperium startWithAppID:appId APIKey:APIKey model:self.managedObjectModel context:self.managedObjectContext coordinator:self.persistentStoreCoordinator];
}

- (void)saveContext
{
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
	{
		[self.managedObjectContext performBlock:^{
			
			NSError* error = nil;
			if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
			{
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}
		}];
    }
}


#pragma mark - Application's Documents directory

- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
