//
//  SDDetailViewController.m
//  SimperiumDebug
//
//  Created by Jorge Leandro Perez on 12/4/13.
//  Copyright (c) 2013 Lantean. All rights reserved.
//

#import "SDDetailViewController.h"
#import "SDTask.h"
#import "SDSubTask.h"
#import "SDCoreDataManager.h"



#pragma mark ====================================================================================
#pragma mark SDDetailViewController
#pragma mark ====================================================================================

@interface SDDetailViewController ()
@property (nonatomic, strong) NSArray* subtasks;
@end


#pragma mark ====================================================================================
#pragma mark SDDetailViewController
#pragma mark ====================================================================================

@implementation SDDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self reloadData];	
}

-(void)reloadData
{
	self.subtasks = self.task.subtasks.allObjects;
	[self.tableView reloadData];
}


#pragma mark ====================================================================================
#pragma mark UITableView Methods
#pragma mark ====================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.subtasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell	= [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text		= [self.subtasks[indexPath.row] valueForKey:@"title"];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SDSubTask *subtask = self.subtasks[indexPath.row];
		[self.task removeSubtasksObject:subtask];
		[[SDCoreDataManager sharedInstance] saveContext];
		[self reloadData];
    }
}

@end
