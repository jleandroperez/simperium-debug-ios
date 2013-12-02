//
//  SDTask.h
//  SimperiumDebug
//
//  Created by Jorge Leandro Perez on 12/2/13.
//  Copyright (c) 2013 Lantean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Simperium/Simperium.h>


@class SDSubTask;

@interface SDTask : SPManagedObject

@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *subtasks;
@end

@interface SDTask (CoreDataGeneratedAccessors)

- (void)addSubtasksObject:(SDSubTask *)value;
- (void)removeSubtasksObject:(SDSubTask *)value;
- (void)addSubtasks:(NSSet *)values;
- (void)removeSubtasks:(NSSet *)values;

@end
