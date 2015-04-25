//
//  AppDelegate.h
//  Petwork
//
//  Created by Xiaorong Zhu on 3/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseLoginViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableData *profilePictureData;

- (void)presentLoginControllerAnimated:(BOOL)animated;
- (void)enableProfileTab: (BOOL)enable;

@end

