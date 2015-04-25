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
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    
    [Parse enableLocalDatastore];
        NSLog(@"didFinishLaunchWithOptions");
    // Initialize Parse.
    [Parse setApplicationId:@"tT6QNQQAWKECbETgCjvAT6KonDidkpOdCnTUfXKP"
                  clientKey:@"BXh54eaTKobw6AnYuZsf8eEd61IgSothgMGumgu5"];
    
    // [Optional] Track statistics around application opens.
    
    
    //NSLog(@"didFinishLaunchWithOptions: makeKeyAndVisible");
    [self.window makeKeyAndVisible];
    NSLog(@"didFinishLaunchWithOptions: didmakeKeyAndVisible");
    [PFFacebookUtils initializeFacebook];
    
    if (![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self enableProfileTab:NO];
        [self presentLoginControllerAnimated:NO];
        NSLog(@"didFinishLaunchWithOptions: had facebook user");
        
    }
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    return YES;
}

- (void)presentLoginControllerAnimated:(BOOL)animated {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    //    [self.window.rootViewController presentViewController:loginNavigationController animated:animated completion:nil];
    //ParseLoginViewController *loginViewController = [[ParseLoginViewController alloc] init];
    //loginViewController.delegate = self;
    //[loginViewController setFields:PFLogInFieldsFacebook];
    ParseLoginViewController *loginViewController = [[ParseLoginViewController alloc] init];
    loginViewController.delegate = self;
    [loginViewController setFields: ( PFLogInFieldsDismissButton | PFLogInFieldsFacebook )];
    NSLog(@"presentLoginControllerAnimated");
    [self.window.rootViewController presentViewController:loginViewController animated:animated completion:nil];
}


/*
- (void)presentLoginControllerAnimated:(BOOL)animated {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
      //  [self.window.rootViewController presentViewController:loginNavigationController animated:animated completion:nil];
    LoginViewController *logInViewController = [[LoginViewController alloc] init];
    logInViewController.delegate = self;
    //logInViewController.facebookPermissions = @[@"friends_about_me"];
    //logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook |PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword
     | PFLogInFieldsFacebook
     | PFLogInFieldsSignUpButton];
    
    // Customize the Sign Up View Controller
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    signUpViewController.delegate = self;
    signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
    logInViewController.signUpController = signUpViewController;
    
    // Present Log In View Controller
    [self.window.rootViewController presentViewController:logInViewController animated:animated completion:nil];
}
*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
            NSLog(@"applicationDidEnterBackground");
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
     NSLog(@"openURL");
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
     NSLog(@"applicationDidBecomeActive");
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
    
}

- (void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error){
            //handle result;
            [self enableProfileTab:YES];
             NSLog(@"didLogInUser: no error");
            [self facebookRequestDidLoad:result];
        }else{
                 NSLog(@"didLogInUser: error");
            [self showErrorAndLogout];
        }
    }];
}
- (void) logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error{
         NSLog(@"didFailToLogInWithError");
    [self showErrorAndLogout];
}

- (void) showErrorAndLogout {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [PFUser logOut];
}

- (void) facebookRequestDidLoad:(id)result{
    PFUser *user = [PFUser currentUser];
    NSLog(@"facebookRequestDidLoad");
    if (user){
    NSLog(@"facebookRequestDidLoad: find user");
        //update current user with facebook name and id
        NSString *facebookName = result[@"name"];
        user.username = facebookName;
        NSString *facebookId = result[@"id" ];
        user[@"facebookId"] = facebookId;
        
        //download user profile picture from facebook
        NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", facebookId]];
        NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
        [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    }
}


- (void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
        NSLog(@"didFailWithError");
    [self showErrorAndLogout];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
            NSLog(@"didReceiveResponse");
    _profilePictureData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
                NSLog(@"didReceiveData");
    [self.profilePictureData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
                    NSLog(@"connectionDidFinishLoading");
    if (self.profilePictureData.length == 0 || !self.profilePictureData){
        [self showErrorAndLogout];
    }else{
        PFFile *profilePictureFile = [PFFile fileWithData:self.profilePictureData];
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded){
                [self showErrorAndLogout];
            } else {
                PFUser *user = [PFUser currentUser];
                user[@"profilePicture"] = profilePictureFile;
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!succeeded){
                        [self showErrorAndLogout];
                    }else{
                        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
        }];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

- (void)enableProfileTab: (BOOL)enable {
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabs = (UITabBarController *)[del.window rootViewController];
    [[[[tabs tabBar] items] objectAtIndex:2] setEnabled:enable];
}

@end
