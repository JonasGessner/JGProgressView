//
//  JGProgressView.h
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGProgressView : UIProgressView

#if !__has_feature(objc_arc)
#warning JGProgressView requires ARC.
#endif




/**
 @discussion Defaults to NO, set to YES for better performance when using several indeterminate progress views with identical animation related-properties (bounds, progressViewStyle, animateToRight), for example in multiple cells in a UITableView.
 
 @warning DO NOT set this property to YES on more than 1 progress views if their animation related-properties (bounds, progressViewStyle, animateToRight) are different for each view.
 
 */
@property (nonatomic, assign) BOOL useSharedImages;


/**
 Property for the indeterminate setting, default is NO, set to YES to start the indeterminate animation
 */
@property (nonatomic, assign, getter = isIndeterminate) BOOL indeterminate;


/**
 Defaults to 0.5, negative values will be ignored.
 */
@property (nonatomic, assign) NSTimeInterval animationSpeed;


/**
 Defaults to NO, when set to YES the animation switches over to animating to the right instead of left.
 */
@property (nonatomic, assign) BOOL animateToRight;


/**
 Use this property to set a custom image to use for the indeterminate animation. Becomes nil after changing progressViewStyle
 */
@property (nonatomic, strong) UIImage *animationImage;


//---------------------------------------------
//when changing multiple properties that affect the animation related-properties (frame, progressViewStyle, animateToRight) in one code block, use beginUpdates before applying these changes and endUpdates after applying the changes to increase performance
//----------------------------------------------


- (void)beginUpdates;
- (void)endUpdates;

@end
