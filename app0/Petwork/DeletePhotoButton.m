//
//  DeletePhotoButton.m
//  Petwork
//
//  Created by Xiaorong Zhu on 4/20/15.
//  Copyright (c) 2015 Xiaorong Zhu. All rights reserved.
//

#import "DeletePhotoButton.h"

@implementation DeletePhotoButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}
- (void) buttonPressed {
    [self.delegate deletePhotoButton:self didTapWithSectionIndex:self.sectionIndex];
}

@end
