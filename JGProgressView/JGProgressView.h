//
//  JGProgressView.h
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGProgressView : UIProgressView


/**
 Defaults to \c NO. Set to \c YES to use shared image, animation speed and progress view style. This may help increasing performance when using many progress views with the same properties (ex. in a UITableViewCell).
 */
@property (nonatomic, assign) BOOL useSharedProperties;





/**
 Property for the indeterminate setting, default is NO, set to YES to start the indeterminate animation.
 */
@property (nonatomic, assign, getter = isIndeterminate) BOOL indeterminate;






/**
 Defaults to 0.5, negative values will reverse the direction of the animation.
 */
@property (nonatomic, assign) NSTimeInterval animationSpeed;

+ (void)setSharedProgressViewAnimationSpeed:(NSTimeInterval)speed;





/**
 Use this property to set a custom image to use for the indeterminate animation. Set to \c nil to use the standard image for the current UIProgressViewStyle
 */
@property (nonatomic, strong) UIImage *animationImage;

+ (void)setSharedProgressViewImage:(UIImage *)img;



/**
 Set the \c UIProgressViewStyle of all progress views that use shared images.
 */
+ (void)setSharedProgressViewStyle:(UIProgressViewStyle)style;




//---------------------------------------------
//Use begin- and endUpdates to increase performance when changing multiple properties of JGProgressView
//----------------------------------------------


- (void)beginUpdates;
+ (void)beginUpdatingSharedProgressViews;



- (void)endUpdates;
+ (void)endUpdatingSharedProgressViews;

@end
