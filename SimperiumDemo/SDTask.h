//
//  SDTask.h
//  SimperiumDebug
//
//  Created by Jorge Leandro Perez on 4/16/14.
//  Copyright (c) 2014 Lantean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Simperium/Simperium.h>

@class SDSubTask;

@interface SDTask : SPManagedObject

@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSSet *subtasks;
@property (nonatomic, retain) SDSubTask *oneSubtask;
@end

@interface SDTask (CoreDataGeneratedAccessors)

- (void)addSubtasksObject:(SDSubTask *)value;
- (void)removeSubtasksObject:(SDSubTask *)value;
- (void)addSubtasks:(NSSet *)values;
- (void)removeSubtasks:(NSSet *)values;

@end
