//
//  ParseLoginViewController.m
//  Petwork
//
//  Created by Xiaorong Zhu on 3/4/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "ParseLoginViewController.h"

@interface ParseLoginViewController ()

@end

@implementation ParseLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logInView.backgroundColor = BLUE_COLOR;
    //self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo"]];
    [self.logInView.facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.logInView.facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    
    CGRect frame = self.logInView.logo.frame;
    frame.origin.y = 200;
    self.logInView.logo.frame = frame;
    
    /*
    frame = self.logInView.usernameField.frame;
    frame.origin.y = 260;
    self.logInView.usernameField.frame = frame;
    frame = self.logInView.logInButton.frame;
    frame.origin.y = 300;
    self.logInView.logInButton.frame = frame;
    */
    
    frame = self.logInView.facebookButton.frame;
    frame.origin.y = 400;
    self.logInView.facebookButton.frame = frame;
    
    
    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
