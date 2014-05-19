//
//  SDAppDelegate.m
//  SimperiumDemo
//
//  Created by Jorge Leandro Perez on 7/17/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SimperiumDemoAppDelegate.h"
#import "SDMasterViewController.h"
#import "SDCoreDataManager.h"



@implementation SimperiumDemoAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1.0];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application
{
	// Not used. For now
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
	// Not used. For now
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
	// Not used. For now
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
	// Not used. For now
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	[[SDCoreDataManager sharedInstance] saveContext];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    Simperium *simperium = [[SDCoreDataManager sharedInstance] simperium];
    
    [simperium backgroundFetchWithCompletion:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
}

@end
