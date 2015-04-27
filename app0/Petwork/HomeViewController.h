//
//  HomeViewController.h
//  Petwork
//
//  Created by Xiaorong Zhu on 3/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "FollowButton.h"
#import "LikeButton.h"
#import "DeletePhotoButton.h"
#import "PhotoInfoButton.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface HomeViewController : PFQueryTableViewController <FollowButtonDelegate, LikeButtonDelegate, DeletePhotoButtonDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, PhotoInfoButtonDelegate>

- (IBAction)logoutButton:(id)sender;
@property (nonatomic, strong) NSMutableArray *blackListPhotoArray;
@end

