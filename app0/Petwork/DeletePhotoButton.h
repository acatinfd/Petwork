//
//  DeletePhotoButton.h
//  Petwork
//
//  Created by Xiaorong Zhu on 4/20/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeletePhotoButton;
@protocol DeletePhotoButtonDelegate
- (void) deletePhotoButton:(DeletePhotoButton *)button didTapWithSectionIndex:(NSInteger)index;
@end

@interface DeletePhotoButton : UIButton
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <DeletePhotoButtonDelegate> delegate;
@end