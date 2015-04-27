//
//  HomeViewController.m
//  Petwork
//
//  Created by Xiaorong Zhu on 3/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
//#import "LoginViewController.h"
//#import "SignUpViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *followingArray;
@property (nonatomic, strong) NSMutableArray *likePhotoArray;
@property (nonatomic, strong) NSMutableArray *deletePhotoArray; //store the index of the photo that to be deleted
@property (nonatomic, assign) BOOL noMorePhotosDidWarned;
@property (nonatomic, assign) NSInteger blockPhotoIndex;
@end

@implementation HomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"Photo";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        self.noMorePhotosDidWarned = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo"]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self loadObjects];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewDataSource and Delegates
- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if ([PFUser currentUser]) {
        PFQuery *queryFollow = [PFQuery queryWithClassName:@"Activity"];
        [queryFollow whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [queryFollow whereKey:@"type" equalTo:@"follow"];
        [queryFollow includeKey:@"toUser"];
        [queryFollow findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error) {
                self.followingArray = [NSMutableArray array];
                if (objects.count >0) {
                    for (PFObject *activity in objects) {
                        PFUser *user = activity[@"toUser"];
                        [self.followingArray addObject:user.objectId];
                    }
                }
                [self.tableView reloadData];
            }
        }];
    
        PFQuery *queryLike = [PFQuery queryWithClassName:@"PhotoActivity"];
        [queryLike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [queryLike whereKey:@"type" equalTo:@"like"];
        [queryLike includeKey:@"toPhoto"];
        [queryLike findObjectsInBackgroundWithBlock:^(NSArray *likeObjects, NSError *error) {
            if (!error) {
                self.likePhotoArray = [NSMutableArray array];
                if (likeObjects.count > 0) {
                    for (PFObject *activity in likeObjects) {
                        PFObject *photo = activity[@"toPhoto"];
                        if(photo[@"image"])
                            [self.likePhotoArray addObject:photo.objectId];
                    }
                }
                [self.tableView reloadData];
            }
        }];
        
        
        PFQuery *queryBlackList = [PFQuery queryWithClassName:@"PhotoActivity"];
        [queryBlackList whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [queryBlackList whereKey:@"type" equalTo:@"block"];
        [queryBlackList includeKey:@"toPhoto"];
        [queryBlackList findObjectsInBackgroundWithBlock:^(NSArray *blockedPhotos, NSError *error) {
            if(!error) {
                self.blackListPhotoArray = [NSMutableArray array];
                if(blockedPhotos.count > 0) {
                    for (PFObject *activity in blockedPhotos) {
                        PFObject *photo = activity[@"toPhoto"];
                        if(photo[@"image"])
                           [self.blackListPhotoArray addObject:photo.objectId];
                    }
                }
                [self.tableView reloadData];
                //[self loadObjects];
            }
        }];
        
    } else {
        self.deletePhotoArray = [NSMutableArray array];
        self.followingArray = [NSMutableArray array];
        self.likePhotoArray = [NSMutableArray array];
        self.blackListPhotoArray = [NSMutableArray array];
        [self.tableView reloadData];
    }
    
}

// return objects in a different indexpath order. in this case we return object based on the section, not row, the default is row

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    else {
        //Show that no more photos to be loaded
        if (!self.noMorePhotosDidWarned) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you for reviewing" message:@"There is no more photos!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            self.noMorePhotosDidWarned = YES;
        }
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    static NSString *CellIdentifier = @"SectionHeaderCell";
    UITableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFImageView *profileImageView = (PFImageView *)[sectionHeaderView viewWithTag:1];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2;
    profileImageView.layer.masksToBounds = YES;
    
    UILabel *userNameLabel = (UILabel *)[sectionHeaderView viewWithTag:2];
    
    PFObject *photo = [self.objects objectAtIndex:section];
    PFUser *user = [photo objectForKey:@"whoTook"];
    PFFile *profilePicture = [user objectForKey:@"profilePicture"];
    
    userNameLabel.text = user.username;
    profileImageView.file = profilePicture;
    
    [profileImageView loadInBackground];
    
    //follow button
    FollowButton *followButton = (FollowButton *)[sectionHeaderView viewWithTag:3];
    followButton.delegate = self;
    followButton.sectionIndex = section;
    
    if (!self.followingArray || ([PFUser currentUser] && [user.objectId isEqualToString:[PFUser currentUser].objectId])) {
        followButton.hidden = YES;
    }
    else {
        followButton.hidden = NO;
        NSInteger indexOfMatchedObject = [self.followingArray indexOfObject:user.objectId];
        if (indexOfMatchedObject == NSNotFound) {
            followButton.selected = NO;
        }
        else {
            followButton.selected = YES;
        }
    }
    
    return sectionHeaderView;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    static NSString *CellIdentifier = @"SectionFooterCell";
    UITableViewCell *sectionFooterView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *userNameLabel = (UILabel *)[sectionFooterView viewWithTag:1];
    UILabel *commentLabel = (UILabel *)[sectionFooterView viewWithTag:2];
    UILabel *likeNumberLabel = (UILabel *)[sectionFooterView viewWithTag:3];

    
    PFObject *photo = [self.objects objectAtIndex:section];
    PFUser *user = [photo objectForKey:@"whoTook"];
    NSString *title = photo[@"title"];
    
    userNameLabel.text = user.username;
    commentLabel.text = title;
    
    //Like button
    LikeButton *likeButton = (LikeButton *)[sectionFooterView viewWithTag:4];
    likeButton.delegate = self;
    likeButton.sectionIndex = section;
    
    NSInteger indexOfMatchedObject = [self.likePhotoArray indexOfObject:photo.objectId];
    if (indexOfMatchedObject == NSNotFound) {
        likeButton.selected = NO;
    }
    else {
        likeButton.selected = YES;
    }

    PFQuery *likePhotoQuery = [PFQuery queryWithClassName:@"PhotoActivity"];
    [likePhotoQuery whereKey:@"toPhoto" equalTo:photo];
    [likePhotoQuery whereKey:@"type" equalTo:@"like"];
    [likePhotoQuery findObjectsInBackgroundWithBlock:^(NSArray *likePhotoActivities, NSError *error) {
        if (!error) {
            likeNumberLabel.text = [[NSNumber numberWithInteger:likePhotoActivities.count] stringValue];
        }
    }];
    
    DeletePhotoButton *deleteButton = (DeletePhotoButton *)[sectionFooterView viewWithTag:5];
    deleteButton.delegate = self;
    deleteButton.sectionIndex = section;
    
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        deleteButton.hidden = NO;
    }
    else {
        deleteButton.hidden = YES;
    }


    return sectionFooterView;
}
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections > 0) {
        sections++;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    if (indexPath.section == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PFImageView *photo = (PFImageView *)[cell viewWithTag:1];
    photo.file = object[@"image"];
    photo.contentMode = UIViewContentModeScaleAspectFit;
    [photo loadInBackground];
    
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *likeNumberLabel = (UILabel *)[cell viewWithTag:3];
    
    PFUser *user = [object objectForKey:@"whoTook"];
    NSString *title = object[@"title"];
    
    commentLabel.text = title;
    
    //Like button
    LikeButton *likeButton = (LikeButton *)[cell viewWithTag:4];
    likeButton.delegate = self;
    likeButton.sectionIndex = indexPath.section;  //TODO: fix this
    
    NSInteger indexOfMatchedObject = [self.likePhotoArray indexOfObject:object.objectId];
    if (indexOfMatchedObject == NSNotFound) {
        likeButton.selected = NO;
    }
    else {
        likeButton.selected = YES;
    }
    
    PFQuery *likePhotoQuery = [PFQuery queryWithClassName:@"PhotoActivity"];
    [likePhotoQuery whereKey:@"toPhoto" equalTo:object];
    [likePhotoQuery whereKey:@"type" equalTo:@"like"];
    [likePhotoQuery findObjectsInBackgroundWithBlock:^(NSArray *likePhotoActivities, NSError *error) {
        if (!error) {
            likeNumberLabel.text = [[NSNumber numberWithInteger:likePhotoActivities.count] stringValue];
        }
    }];
    
    DeletePhotoButton *deleteButton = (DeletePhotoButton *)[cell viewWithTag:5];
    deleteButton.delegate = self;
    deleteButton.sectionIndex = indexPath.section;  //TODO: fix this
    
    if ([PFUser currentUser] && [user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        deleteButton.hidden = NO;
    }
    else {
        deleteButton.hidden = YES;
    }

    PhotoInfoButton *blockPhotoButton = (PhotoInfoButton *)[cell viewWithTag:6];
    blockPhotoButton.delegate = self;
    blockPhotoButton.sectionIndex = indexPath.section;
    /*
     NSInteger indexOfMatchedObject1 = [self.blackListPhotoArray indexOfObject:object.objectId];
    if (indexOfMatchedObject1 == NSNotFound) {
        blockPhotoButton.hidden = NO;
    }
    else {
        blockPhotoButton.hidden = YES;
    }
    */
    //To hide blocked photo.
    //if ([self.blackListPhotoArray containsObject:object.objectId])
    //    cell.hidden = true;
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    
    //PFObject *photoObject = [self.objects objectAtIndex:section];
    //To hide blocked photo.
    //if ([self.blackListPhotoArray containsObject:photoObject.objectId])
    //    return 0.0f;
    
    return 50.0f;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    PFObject *photo = [self.objects objectAtIndex:section];
   // NSLog(@"--, %@", photo[@"title"]);
    NSString *title = photo[@"title"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    const CGSize textSize = [title sizeWithAttributes: userAttributes];
    float increment = 15 * (textSize.width/self.view.frame.size.width);
    //return 40.0f;
    return 0.0f;
    //return increment + 70.0f;
}
 */

/*- (NSString *)tableView: (UITableView * )tableView comment : (NSInteger)section
 {
 static NSString *CellIdentifier = @"SectionFooterCell";
 UITableViewCell *sectionFooterView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 UILabel *commentLabel = (UILabel *)[sectionFooterView viewWithTag:2];
 
 
 PFObject *photo = [self.objects objectAtIndex:section];
 PFUser *user = [photo objectForKey:@"whoTook"];
 NSString *title = photo[@"title"];
 
 commentLabel.text = title;
 return commentLabel.text;
 }
 
 - (CGFloat)heightForText:(NSString *)comment
 {
 UIFont *cellFont = [UIFont systemFontOfSize:10];
 CGSize constraintSize = CGSizeMake(600, MAXFLOAT);
 CGSize labelSize = [comment sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
 CGFloat height = labelSize.height ;
 NSLog(@"height=%f", height);
 return height;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    // NSString *labelText = [self.comment objectAtIndex:indexPath.row];
    return 100.0f;
    //[self heightForText:labelText];
    
}*/


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.objects.count) {
        return 50.0f;
    }
//    return 320.0f;
    PFObject *photoObject = [self.objects objectAtIndex:indexPath.section];
    
    //To hide blocked photo.
   // if ([self.blackListPhotoArray containsObject:photoObject.objectId])
     //   return 0.0f;
    
    NSString *title = photoObject[@"title"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    const CGSize textSize = [title sizeWithAttributes: userAttributes];
    float increment = 15 * (textSize.width/self.view.frame.size.width);
    
    return increment + 360.0f;
    //return increment + imageHeight + 40.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoadMoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        [self loadNextPage];
    }
}

- (PFQuery *)queryForTable {
    if ([PFUser currentUser]) {
        PFQuery *blockedPhotoQuery = [PFQuery queryWithClassName:@"PhotoActivity"];
        [blockedPhotoQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [blockedPhotoQuery whereKey:@"type" equalTo:@"block"];
        [blockedPhotoQuery includeKey:@"toPhotoObjectId"];
        
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        if(self.blackListPhotoArray)
            [query whereKey:@"objectId" notContainedIn:self.blackListPhotoArray];
        else
            [query whereKey:@"objectId" doesNotMatchKey:@"toPhotoObjectId" inQuery:blockedPhotoQuery];
        [query includeKey:@"whoTook"];
        [query orderByDescending:@"createdAt"];
        return query;
    }
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"whoTook"];
    [query orderByDescending:@"createdAt"];
    return query;
}

- (void)followButton:(FollowButton *)button didTapWithSectionIndex:(NSInteger)index {
    if (![PFUser currentUser]) {
        [self askForLogIn];
        return;
    }
    
    PFObject *photo = [self.objects objectAtIndex:index];
    PFUser *user = photo[@"whoTook"];
    
    if (!button.selected) {
        [self followUser:user];
    }
    else {
        [self unfollowUser:user];
    }
    [self.tableView reloadData];
}

- (void)followUser:(PFUser *)user {
    if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self.followingArray addObject:user.objectId];
        PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
        followActivity[@"fromUser"] = [PFUser currentUser];
        followActivity[@"toUser"] = user;
        followActivity[@"type"] = @"follow";
        if (user[@"isPrivate"]) {
            followActivity[@"isApproved"] = [NSNumber numberWithBool:NO];
        }
        else {
            // the user is not private, so we don't need approval, set isApproved to YES
            followActivity[@"isApproved"] = [NSNumber numberWithBool:YES];
        }
        [followActivity saveEventually];
    }
}

- (void)unfollowUser:(PFUser *)user {
    [self.followingArray removeObject:user.objectId];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:user];
    [query whereKey:@"type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
        
    }];
}

- (void) likeButton:(LikeButton *)button didTapWithSectionIndex:(NSInteger)index {
    if (![PFUser currentUser]) {
        [self askForLogIn];
        return;
    }
    
    PFObject *photo = [self.objects objectAtIndex: index];
    
    NSInteger indexOfMatchedObject = [self.likePhotoArray indexOfObject:photo.objectId];
    if (indexOfMatchedObject == NSNotFound && !button.selected) {
            [self likePhoto:photo];
            button.selected = YES;
    }
    else {
        if(button.selected){
            [self unlikePhoto:photo];
            button.selected = NO;
        }
    }
    [self.tableView reloadData];
}

- (void) likePhoto: (PFObject *) photo {
    NSInteger indexOfMatchedObject = [self.likePhotoArray indexOfObject:photo.objectId];
    if (indexOfMatchedObject == NSNotFound) {
        [self.likePhotoArray addObject:photo.objectId];
        PFObject *likeActivity = [PFObject objectWithClassName:@"PhotoActivity"]; //which is actually a table for like activity
        likeActivity[@"fromUser"] = [PFUser currentUser];
        likeActivity[@"toPhoto"] = photo;
        likeActivity[@"toUser"] = photo[@"whoTook"];
        likeActivity[@"type"] = @"like";
        [likeActivity saveEventually];
    }
}

- (void) unlikePhoto: (PFObject *) photo {
    NSInteger indexOfMatchedObject = [self.likePhotoArray indexOfObject:photo.objectId];
    if (indexOfMatchedObject == NSNotFound) {
        //DO Nothing
    }else {
        [self.likePhotoArray removeObject:photo.objectId];
        PFQuery *query = [PFQuery queryWithClassName:@"PhotoActivity"];
        [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [query whereKey:@"toPhoto" equalTo:photo];
        [query whereKey:@"type" equalTo:@"like"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *likeActivities, NSError *error) {
            if (!error) {
                for (PFObject *likeActivity in likeActivities) {
                    [likeActivity deleteEventually];
                }
            }
        }];
    }
}

- (void) deletePhotoButton:(DeletePhotoButton *)button didTapWithSectionIndex:(NSInteger)index {
    NSLog(@"didTapWithSectionIndex");
    [self.deletePhotoArray addObject:[NSNumber numberWithInteger:index]];
    
    NSString *actionSheetTitle = @"Confirm to delete your photo permanently?"; //Action Sheet Title
    NSString *deletePhoto = @"Delete";
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:deletePhoto
                                                    otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
    NSLog(@"Did finished shown actionsheet");
}

- (void) deletePhoto { //Delete photo that appears in self.deletePhotoArray
    NSNumber *index = [self.deletePhotoArray lastObject];
    if (index) {
        PFObject *photo = [self.objects objectAtIndex:[index integerValue]];
        PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
        [query whereKey:@"objectId" equalTo:photo.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {
            if (!error) {
                for (PFObject *p in photos) {
                    [p deleteEventually];
                }
            }
        }];
        [self.deletePhotoArray removeLastObject];
        [self.tableView reloadData];
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 1) {
        if(buttonIndex == 0) {
            //[self deletePhoto];
            //Delete
            NSNumber *index = [self.deletePhotoArray lastObject];
            PFObject *photo = [self.objects objectAtIndex:[index integerValue]];
            PFQuery *queryLike = [PFQuery queryWithClassName:@"PhotoActivity"];
            [queryLike whereKey:@"toPhoto" equalTo:photo];
            [queryLike whereKey:@"type" equalTo:@"like"];
            [queryLike findObjectsInBackgroundWithBlock:^(NSArray *likeActivities, NSError *error) {
                if (!error) {
                    for (PFObject *likeActivity in likeActivities) {
                        [likeActivity deleteEventually];
                    }
                }
            }];
        
            [self.likePhotoArray removeObject:photo.objectId];
            [self deletePhoto];
        
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successfully deleted!" message:@"Refresh to see changes" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        
        
            [self.tableView reloadData];
            NSLog(@"Did delete from actionsheet");
        }else {
            //Cancel detele
            [self.deletePhotoArray removeLastObject];
            NSLog(@"Did cancel from actionsheet");
        }
        NSLog(@"Did finished actionsheet");
    } else if (actionSheet.tag == 2) {
        if(buttonIndex == 0 || buttonIndex == 1) {
            PFObject *photo = [self.objects objectAtIndex:_blockPhotoIndex];
            [self blockPhoto:photo offensive:(buttonIndex == 0)];
            /*
            NSData *imageData = UIImagePNGRepresentation(self.chosenImageView.image);
            PFFile *photoFile = [PFFile fileWithData: imageData];
            PFObject *photo = [PFObject objectWithClassName:@"Photo"];
            
            photo[@"image"] = photoFile;
            photo[@"user"] = [PFUser currentUser];
            photo[@"whoTook"] = [PFUser currentUser];
            if(self.titleTextField.text)
                photo[@"title"] = self.titleTextField.text;
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    [self showError];
                }
            }];
             */
        }
        else {
            //Cancel flag
            
        }
    }
}

- (void) blockPhoto:(PFObject *) photo  offensive:(BOOL)offensive {
    NSInteger indexOfMatchedObject = [self.blackListPhotoArray indexOfObject:photo.objectId];
    if (indexOfMatchedObject == NSNotFound) {
        [self.blackListPhotoArray addObject:photo.objectId];
        PFObject *blockActivity = [PFObject objectWithClassName:@"PhotoActivity"];
        blockActivity[@"fromUser"] = [PFUser currentUser];
        blockActivity[@"toPhoto"] = photo;
        blockActivity[@"toPhotoObjectId"] = photo.objectId;
        blockActivity[@"toUser"] = photo[@"whoTook"];
        blockActivity[@"type"] = @"block";
        [blockActivity saveEventually];
        
        if (offensive) {
            PFObject *badPhoto = [PFObject objectWithClassName:@"PhotoActivity"];
            badPhoto[@"fromUser"] = [PFUser currentUser];
            badPhoto[@"toPhoto"] = photo;
            badPhoto[@"toUser"] = photo[@"whoTook"];
            badPhoto[@"type"] = @"reportOffensive";
            [badPhoto saveEventually];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfully block photo" message:@"You will not see this photo in the timeline again after refresh" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.tableView reloadData];
    }
}

- (void) askForLogIn {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You haven't logged in" message:@"Please log in to use this function" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate presentLoginControllerAnimated:YES];
}

- (IBAction)logoutButton:(id)sender {
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [[PFFacebookUtils session] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];
    [PFUser logOut];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate presentLoginControllerAnimated:YES];
    //TODO: to present another view
    /*
    LoginViewController *logInViewController = [[LoginViewController alloc] init];
    logInViewController.delegate = self;
    //logInViewController.facebookPermissions = @[@"friends_about_me"];
    //logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook |PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword
     | PFLogInFieldsFacebook
     | PFLogInFieldsSignUpButton];
    
    // Present Log In View Controller
    //logInViewController.delegate = self;
    [self presentViewController:logInViewController animated:YES completion:nil];
    
    //TODO: there is bug here. After logout, user will not be able to login. 
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
     [appDelegate presentLoginControllerAnimated:YES];
     */
}

/*
// to fix floating headers
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint p = scrollView.contentOffset;
    
    CGFloat height = 320.0f;
    
    if (p.y <= height && p.y >= 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-p.y, 0, 0, 0);
    } else if (p.y >= height) {
        self.tableView.contentInset = UIEdgeInsetsMake(-height, 0, 0, 0);
    }
}
*/


- (void)photoInfoButton:(PhotoInfoButton *)button didTapWithSectionIndex:(NSInteger)index {
    if (![PFUser currentUser]) {
        [self askForLogIn];
        return;
    }
    _blockPhotoIndex = index;
    NSString *actionSheetTitle = @"Dislike this photo?"; //Action Sheet Title
    NSString *hatePhotoTitle = @"Hide this from my feed";
    NSString *reportPhotoTitle = @"Report inappropiate";
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:reportPhotoTitle
                                                    otherButtonTitles:hatePhotoTitle, nil];
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
}

- (NSIndexPath *)_indexPathForPaginationCell {
    
    return [NSIndexPath indexPathForRow : 0 inSection:[self.objects count]];
    
}

@end
