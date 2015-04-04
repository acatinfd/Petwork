//
//  LikeButton.h
//  Petwork
//
//  Created by Xiaorong Zhu on 4/3/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LikeButton;
@protocol LikeButtonDelegate
- (void) likeButton:(LikeButton *)button didTapWithSectionIndex:(NSInteger)index;
@end

@interface LikeButton : UIButton

@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <LikeButtonDelegate> delegate;
@end
