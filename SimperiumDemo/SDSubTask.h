//
//  SDSubTask.h
//  SimperiumDebug
//
//  Created by Jorge Leandro Perez on 12/2/13.
//  Copyright (c) 2013 Lantean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simperium/Simperium.h>

@class SDTask;

@interface SDSubTask : SPManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) SDTask *task;

@end
