//
//  CameraViewController.m
//  Petwork
//
//  Created by Xiaorong Zhu on 3/4/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Parse/Parse.h>

@interface CameraViewController ()
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *chosenImageView;
@property (nonatomic, assign) BOOL imagePickerIsDisplayed;
@property (nonatomic, assign) BOOL imageSource; //true: camera; false: library

@end

@implementation CameraViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    _imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    
    self.imagePicker.allowsEditing = YES;
    if(!self.imagePickerIsDisplayed && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSString *actionSheetTitle = @"Pick a photo source"; //Action Sheet Title
        NSString *camera = @"Take photo";
        NSString *library = @"Choose from library";
        NSString *cancelTitle = @"Cancel";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:camera, library, nil];
        
        [actionSheet showInView:self.view];
    }else{
        [self pickImageSource:1]; //from library
    }
    [super viewWillAppear:animated];
}

-(void) pickImageSource:(NSInteger ) source {
    switch (source) {
        case 0:
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        default:
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    if (!self.imagePickerIsDisplayed) {
        [self presentViewController:self.imagePicker animated:NO completion:nil];
        self.imagePickerIsDisplayed = YES;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 2) {
        //Cancel taking photo
        [self viewWillDisappear:YES];
        [self.tabBarController setSelectedIndex:0];
        self.imagePickerIsDisplayed = NO;
    }else {
        [self pickImageSource:buttonIndex];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clear];
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.chosenImageView.image = chosenImage;
    self.chosenImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self dismissViewControllerAnimated:YES completion:^{self.imagePickerIsDisplayed = NO;}];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
    self.imagePickerIsDisplayed = NO;
}

- (void) clear {
    self.chosenImageView.image = nil;
    self.titleTextField.text = nil;
}

- (IBAction)share:(id)sender {
    if (self.chosenImageView.image) {
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
    }else{
        [self showError];
    }
    [self clear];
    [self.tabBarController setSelectedIndex:0];
}

- (void) showError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not post your photo, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleTextField resignFirstResponder];
}


- (IBAction)cancelButton:(id)sender {
    [self clear];
    [self.tabBarController setSelectedIndex:0];
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
