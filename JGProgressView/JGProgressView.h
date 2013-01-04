//
//  JGProgressView.h
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGProgressView : UIProgressView

@property (nonatomic, assign) BOOL isIndeterminate; //default NO
@property (nonatomic, assign) NSTimeInterval animationSpeed; //default 0.5, negative values are not allowed and will be ignored

@end
