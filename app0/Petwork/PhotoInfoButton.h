//
//  PhotoInfoButton.h
//  Petwork
//
//  Created by Xiaorong Zhu on 4/25/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoInfoButton;
@protocol PhotoInfoButtonDelegate
- (void) photoInfoButton:(PhotoInfoButton *)button didTapWithSectionIndex:(NSInteger) index;
@end

@interface PhotoInfoButton : UIButton
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <PhotoInfoButtonDelegate> delegate;
@end

