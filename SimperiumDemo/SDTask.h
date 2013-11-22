//
//  SDTask.h
//  SimperiumDemo
//
//  Created by Jorge Leandro Perez on 7/11/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Simperium/Simperium.h>



@interface SDTask : SPManagedObject
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* payload;
@end
