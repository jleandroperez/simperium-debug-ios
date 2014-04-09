//
//  SDDetailViewController.h
//  SimperiumDebug
//
//  Created by Jorge Leandro Perez on 12/4/13.
//  Copyright (c) 2013 Lantean. All rights reserved.
//

#import <UIKit/UIKit.h>



@class SDTask;

#pragma mark ====================================================================================
#pragma mark SDDetailViewController
#pragma mark ====================================================================================

@interface SDDetailViewController : UITableViewController
@property (nonatomic, weak) SDTask* task;
@end
