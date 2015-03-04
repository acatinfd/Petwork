//
//  AppDelegate.m
//  Petwork
//
//  Created by Xiaorong Zhu on 3/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"tT6QNQQAWKECbETgCjvAT6KonDidkpOdCnTUfXKP"
                  clientKey:@"BXh54eaTKobw6AnYuZsf8eEd61IgSothgMGumgu5"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    PFObject *supermarket = [PFObject objectWithClassName:@"Supermarket"];
    [supermarket setObject:@"apple" forKey:@"fruitItem1"];
    [supermarket saveInBackground];
    [self.window makeKeyAndVisible];

    [PFFacebookUtils initializeFacebook];
    
    if (![PFUser currentUser]){
        [self presentLoginControllerAnimated:NO];
        
    }
    return YES;
}

- (void)presentLoginControllerAnimated:(BOOL)animated {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    //    [self.window.rootViewController presentViewController:loginNavigationController animated:animated completion:nil];
    ParseLoginViewController *loginViewController = [[ParseLoginViewController alloc] init];
    loginViewController.delegate = self;
    [loginViewController setFields:PFLogInFieldsFacebook];
    [self.window.rootViewController presentViewController:loginViewController animated:animated completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

@end
