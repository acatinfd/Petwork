//
//  ParseTableViewController.m
//  Petwork
//
//  Created by Xiaorong Zhu on 3/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "ParseTableViewController.h"
#import <Parse/Parse.h>
@interface ParseTableViewController ()

@property (nonatomic, strong) NSArray *objects;
@end

@implementation ParseTableViewController
-(id) initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if(self){
        //Custom
    }
    return self;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:@"TagsActivity"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Do something with the found objects
            self.objects = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *testObject = [self.objects objectAtIndex:indexPath.row];
    cell.textLabel.text = testObject[@"tags"];
    
    return cell;
}

@end
