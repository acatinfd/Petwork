//
//  SettingsViewController.m
//  Petwork
//
//  Created by Xiaorong Zhu on 4/27/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)readTermsOfUse:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://petworkapp.weebly.com/terms-of-use.html"]];
}

- (IBAction)readPrivacyPolicy:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://petworkapp.weebly.com/privacy-policy.html"]];
}


@end
