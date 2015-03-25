//
//  HomeViewController.h
//  Petwork
//
//  Created by Xiaorong Zhu on 3/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "FollowButton.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface HomeViewController : PFQueryTableViewController <FollowButtonDelegate>

@end

