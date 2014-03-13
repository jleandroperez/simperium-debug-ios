//
//  SDCoreDataManager.h
//  SimperiumDemo
//
//  Created by Jorge Leandro Perez on 7/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simperium/Simperium.h>



@interface SDCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext*			managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel*			managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator*	persistentStoreCoordinator;
@property (readonly, strong, nonatomic) Simperium*						simperium;

+ (instancetype)sharedInstance;

- (void)saveContext;

@end
