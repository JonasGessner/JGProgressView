//
//  JGProgressView.h
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGProgressView : UIProgressView


//default is NO, set to YES for better performance when using several indeterminate progress views with the same size at the same time (in a UITableView for example)
//DO NOT set this property to YES on more than 1 progress views if their animation related-properties (bounds, progressViewStyle, animateToRight) are different for each view
//Set this property to YES when using more than 1 progress views with identical animation related-properties (bounds, progressViewStyle, animateToRight) for improved performance
@property (nonatomic, assign) BOOL useSharedImages;


//property for the indeterminate setting, default is NO, set to YES to start the indeterminate animation
@property (nonatomic, assign, getter = isIndeterminate) BOOL indeterminate;


//default is 0.5, negative values are not allowed and will be ignored
@property (nonatomic, assign) NSTimeInterval animationSpeed;


//default is NO, when set to YES the animation switches over to animating to the right instead of left
@property (nonatomic, assign) BOOL animateToRight;


//when changing multiple properties that affect the animation related-properties (frame, progressViewStyle, animateToRight) in one code block, use beginUpdates before applying these changes and endUpdates after applying the changes to increase performance
- (void)beginUpdates;
- (void)endUpdates;

@end
