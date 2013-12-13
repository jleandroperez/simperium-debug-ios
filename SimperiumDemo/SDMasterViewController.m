
//  SDMasterViewController.m
//  SimperiumDemo
//
//  Created by Jorge Leandro Perez on 7/17/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SDMasterViewController.h"
#import "SDDetailViewController.h"

#import "SDCoreDataManager.h"
#import "SDTask.h"
#import "SDSubTask.h"



#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

//NSString* const kAppId				= @"possessions-consideration-f1f";
//NSString* const kAPIKey				= @"3d783f77d20843438124fabcee85b767";

NSString* const kAppId				= @"donor-date-4b8";
NSString* const kAPIKey				= @"7b5e3fc0763f4287b22cf1a872942651";

NSInteger const kEntitiesBlast		= 10;
NSInteger const kSubEntitiesRatio	= 1;
NSInteger const kEntityByteSize		= 1;
NSInteger const kEntitiesToDelete	= 1;

BOOL const kPushDetails				= false;


#pragma mark ====================================================================================
#pragma mark Private Properties
#pragma mark ====================================================================================

@interface SDMasterViewController () <NSFetchedResultsControllerDelegate, SimperiumDelegate, SPBucketDelegate>
@property (strong, nonatomic, readwrite) IBOutlet UILabel			*numberLabel;
@property (strong, nonatomic, readwrite) IBOutlet UITableView		*tableView;
@property (strong, nonatomic, readwrite) NSDateFormatter			*timeFormat;
@property (strong, nonatomic, readwrite) NSFetchedResultsController	*fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext		*privateContext;
@property (strong, nonatomic, readwrite) NSManagedObjectContext		*interfaceContext;
@end


#pragma mark ====================================================================================
#pragma mark SDMasterViewController
#pragma mark ====================================================================================

@implementation SDMasterViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Validate the required setup
	NSAssert( (kAppId != nil),  @"Please, specify your appId");
	NSAssert( (kAPIKey != nil), @"Please, specify your API Key");
	
	// TimeFormat
	self.timeFormat								= [[NSDateFormatter alloc] init];
	self.timeFormat.dateFormat					= @"HH:mm:ss";

	// Setup the UI
	UIBarButtonItem* networkButton				= [[UIBarButtonItem alloc] initWithTitle:@"NW Off"		style:UIBarButtonItemStyleBordered target:self action:@selector(toggleNetwork:)];
	UIBarButtonItem* interfaceButton			= [[UIBarButtonItem alloc] initWithTitle:@"UI Off"		style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFetch:)];
	
	UIBarButtonItem* singleAddButton			= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay		target:self action:@selector(insertItemSingle:)];
	UIBarButtonItem* batchAddButton				= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(insertItemBatch:)];
	UIBarButtonItem* delAllButton				= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash		target:self action:@selector(delAllItems:)];

	self.navigationItem.leftBarButtonItems		= @[networkButton, interfaceButton];
	self.navigationItem.rightBarButtonItems		= @[batchAddButton, singleAddButton, delAllButton];
	
	// Start Simperium
	SDCoreDataManager* coreDataManager			= [SDCoreDataManager sharedInstance];
	[coreDataManager startupSimperiumWithAppId:kAppId APIKey:kAPIKey rootViewController:self];
	coreDataManager.simperium.networkEnabled	= NO;
	coreDataManager.simperium.verboseLoggingEnabled	= YES;
	
	// New local private MOC: Insertions / Update's
	NSManagedObjectContext* privateContext		= [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	privateContext.parentContext				= coreDataManager.managedObjectContext;
	self.privateContext							= privateContext;
	
	// Interface MOC
//	NSManagedObjectContext* interfaceContext	= [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//	interfaceContext.parentContext				= coreDataManager.managedObjectContext;
	self.interfaceContext						= coreDataManager.managedObjectContext;
	
	// Refresh the counter each time an object changes
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(refreshCounter:) name:NSManagedObjectContextObjectsDidChangeNotification object:coreDataManager.simperium.writerManagedObjectContext];
	
	// Refresh the counter now please!
	[self refreshCounter:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Details"])
	{
        NSIndexPath *indexPath			= [self.tableView indexPathForSelectedRow];
        SDDetailViewController* details = (SDDetailViewController*)segue.destinationViewController;
		details.task					= [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}


#pragma mark ====================================================================================
#pragma mark Button Delegates
#pragma mark ====================================================================================

-(IBAction)toggleNetwork:(id)sender
{
	Simperium* simperium			= [[SDCoreDataManager sharedInstance] simperium];
	BOOL enabled					= !simperium.networkEnabled;

	simperium.networkEnabled		= enabled;
	UIBarButtonItem* networkButton	= (UIBarButtonItem*)sender;
	networkButton.title				= (enabled ? @"NW On" : @"NW Off");
}

-(IBAction)toggleFetch:(id)sender
{
	UIBarButtonItem* fetchButton	= (UIBarButtonItem*)sender;
	BOOL enabled					= (self.tableView.dataSource != nil);
	
	if(enabled)
	{
		fetchButton.title				= @"UI Off";
		self.tableView.dataSource		= nil;
		self.fetchedResultsController	= nil;
		[self.tableView reloadData];
	}
	else
	{
		fetchButton.title			= @"UI On";
		self.tableView.dataSource	= (id<UITableViewDataSource>)self;
		[self.tableView reloadData];
	}
	
	[self.tableView reloadData];
}

-(void)insertEntities:(NSUInteger)number
{
	[self.privateContext performBlock:^{
		for(NSInteger count = -1; ++count < number; )
		{
			SDTask* task	= [NSEntityDescription insertNewObjectForEntityForName:@"SDTask" inManagedObjectContext:self.privateContext];
			task.title		= [NSString stringWithFormat:@"Task [%@]", [self.timeFormat stringFromDate:[NSDate date]]];
			task.payload	= [self payload];
			
			for(NSInteger count = -1; ++count < kSubEntitiesRatio; )
			{
				SDSubTask* subtask = [NSEntityDescription insertNewObjectForEntityForName:@"SDSubTask" inManagedObjectContext:self.privateContext];
				subtask.title = [NSString stringWithFormat:@"Subtask [%d]", count];
				[task addSubtasksObject:subtask];
			}
		}
	}];
}

-(IBAction)insertItemSingle:(id)sender
{
	NSLog(@"<> Inserting Model Object");
	
	[self insertEntities:1];
	[self save];
}

-(IBAction)insertItemBatch:(id)sender
{
	NSLog(@"<> Inserting %d Model Object. Total: %d KB", kEntitiesBlast, (kEntityByteSize * kEntitiesBlast / 1024));
		
	[self insertEntities:kEntitiesBlast];
	[self save];
}

-(IBAction)delAllItems:(id)sender
{
	NSLog(@"<> Deleting All Objects");
	[self deleteObjects:NSIntegerMax];
}

-(void)refreshCounter:(id)sender
{
	[self.privateContext performBlock:^{
		
		NSFetchRequest* request	= [[NSFetchRequest alloc] init];
		request.entity			= [NSEntityDescription entityForName:NSStringFromClass([SDTask class]) inManagedObjectContext:self.privateContext];
		
		NSArray* fetchedObjects = [self.privateContext executeFetchRequest:request error:nil];

		dispatch_async(dispatch_get_main_queue(), ^{
			self.numberLabel.text = [NSString stringWithFormat:@"Number of Objects: %d", fetchedObjects.count];
		});
	}];
}



#pragma mark ====================================================================================
#pragma mark Helpers
#pragma mark ====================================================================================

-(void)updateObjectWithID:(NSManagedObjectID*)objectID
{
	NSLog(@"<> Updating Model Object");
	
	[self.privateContext performBlock:^{
		SDTask* task	= (SDTask*)[self.privateContext objectWithID:objectID];
		task.title		= [NSString stringWithFormat:@"Updated at [%@]", [self.timeFormat stringFromDate:[NSDate date]]];
		[self save];
	}];
}

-(void)deleteObjects:(NSInteger)max
{
	[self.privateContext performBlock:^{
		
		NSFetchRequest* request = [[NSFetchRequest alloc] init];
		request.entity			= [NSEntityDescription entityForName:NSStringFromClass([SDTask class]) inManagedObjectContext:self.privateContext];
		request.fetchLimit		= max;
		
		NSArray* result			= [self.privateContext executeFetchRequest:request error:nil];
		
		for(NSManagedObject* mo in result)
		{
			[self.privateContext deleteObject:mo];
		}
		
		[self save];
		
		NSLog(@"<> Deleted %d Objects", result.count);
	}];
}

-(NSString*)payload
{
	NSMutableString* longString = [NSMutableString string];
	for(NSInteger len = -1; ++len < kEntityByteSize; )
	{
		[longString appendString:@"Z"];
	}
	return longString;
}


-(void)save
{
	NSLog(@"<> Saving Context's");
	
	[self.interfaceContext performBlock:^{
		[self.interfaceContext save:nil];
		
		[self.privateContext performBlock:^{
			[self.privateContext save:nil];
			[[SDCoreDataManager sharedInstance] saveContext];
		}];
	}];
}


#pragma mark ====================================================================================
#pragma mark UITableView Methods
#pragma mark ====================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell	= [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];	
    SDTask* task			= [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text		= [[task valueForKey:@"title"] description];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		[self save];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject* object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if(kPushDetails)
	{
		[self performSegueWithIdentifier:@"Details" sender:self];
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self updateObjectWithID:object.objectID];
	}
}


#pragma mark ====================================================================================
#pragma mark NSFetchedResultsController Methods
#pragma mark ====================================================================================

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
	{
        return _fetchedResultsController;
    }
    
	NSManagedObjectContext* context	= self.interfaceContext;

    NSFetchRequest* fetchRequest	= [[NSFetchRequest alloc] init];
    fetchRequest.entity				= [NSEntityDescription entityForName:@"SDTask" inManagedObjectContext:context];
	fetchRequest.sortDescriptors	= @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO] ];
    fetchRequest.fetchBatchSize		= 50;

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController* fetched		= [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController			= fetched;
	self.fetchedResultsController.delegate	= self;

	NSError* error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
			[self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
