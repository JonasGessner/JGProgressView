//
//  JGProgressView.m
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import "JGProgressView.h"

#import <QuartzCore/QuartzCore.h>

@interface UIImage (JGAddons)

- (UIImage *)attachImage:(UIImage *)image;
- (UIImage *)cropByX:(CGFloat)x;

@end

@implementation UIImage (JGAddons)

- (UIImage *)cropByX:(CGFloat)x {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width-x, self.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    UIImage *result = [UIImage imageWithCGImage:image scale:self.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(image);
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)attachImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width+image.size.width, self.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    
    CGContextDrawImage(context, CGRectMake(self.size.width, 0, image.size.width, self.size.height), image.CGImage);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end

@interface JGProgressView () {
    NSMutableArray *animationImages;
    UIImageView *theImageView;
    
    UIImage *masterImage;
    
    CGFloat cachedProgress;
}

- (UIImage *)imageForCurrentStyle;
- (void)reloopForInterfaceChange;
- (void)layoutImageView;

@end

@implementation JGProgressView

@synthesize isIndeterminate, animationSpeed;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.animationSpeed = 0.5f;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationSpeed = 0.5f;
    }
    return self;
}

- (UIImage *)imageForCurrentStyle {
    if (self.progressViewStyle == UIProgressViewStyleDefault) {
        return [UIImage imageNamed:@"Indeterminate.png"];
    }
    else {
        return [UIImage imageNamed:@"IndeterminateBar.png"];
    }
}

- (void)setProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    if (progressViewStyle == self.progressViewStyle) {
        return;
    }
    
    [super setProgressViewStyle:progressViewStyle];
    
    if (self.isIndeterminate)
        [self reloopForInterfaceChange];
}

- (void)setAnimationSpeed:(NSTimeInterval)_animationSpeed {
    if (_animationSpeed >= 0.0f) {
        animationSpeed = _animationSpeed;
    }
    if (self.isIndeterminate)
        [theImageView setAnimationDuration:self.animationSpeed];
}

- (float)progress {
    if (self.isIndeterminate) {
        return cachedProgress;
    }
    else {
        return [super progress];
    }
}

- (void)setProgress:(float)progress {
    if (self.isIndeterminate) {
        cachedProgress = progress;
    }
    else {
        [super setProgress:progress];
    }
}

- (void)layoutImageView {
    [theImageView sizeToFit];
    
    CGFloat border = ([[self.subviews objectAtIndex:0] frame].size.height-theImageView.frame.size.height);
    
    theImageView.center = CGPointMake(theImageView.center.x, CGRectGetMidY(self.bounds)-border/2);
    
    theImageView.frame = CGRectMake(border, theImageView.frame.origin.y, theImageView.frame.size.width-border*2, theImageView.frame.size.height);
    
    theImageView.layer.cornerRadius = theImageView.frame.size.height/2;
}

- (void)setIsIndeterminate:(BOOL)_isIndeterminate {
    if (isIndeterminate == _isIndeterminate) {
        return;
    }
    
    if (_isIndeterminate) {
        cachedProgress = self.progress;
        self.progress = 0;
    }
    
    isIndeterminate = _isIndeterminate;
    
    if (isIndeterminate) {
        [self reloopForInterfaceChange];
    }
    else {
        self.progress = cachedProgress;
        [theImageView stopAnimating];
        [theImageView removeFromSuperview];
    }
}

- (void)reloopForInterfaceChange {
    UIImage *single = [self imageForCurrentStyle];
    
    if ((int)self.progressViewStyle != theImageView.tag || !masterImage) {
        masterImage = [single copy];
        while (masterImage.size.width-single.size.width < self.frame.size.width+single.size.width) {
            masterImage = [masterImage attachImage:single];
        }
    }
    else {
        if (masterImage.size.width-single.size.width < self.frame.size.width) {
            while (masterImage.size.width-single.size.width < self.frame.size.width+single.size.width) {
                masterImage = [masterImage attachImage:single];
            }
        }
        else {
            while (masterImage.size.width-single.size.width > self.frame.size.width+single.size.width) {
                masterImage = [masterImage cropByX:single.size.width];
            }
        }
    }
    
    if (!animationImages) {
        animationImages = [[NSMutableArray alloc] init];
    }
    else {
        [animationImages removeAllObjects];
    }
    
    CGFloat pixels = single.size.width*single.scale;
    
    for (int i = 0; i <= pixels+2*single.scale; i++) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, masterImage.size.height), NO, single.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, 0, masterImage.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextDrawImage(context, CGRectMake(-i, 0, masterImage.size.width+single.size.width, masterImage.size.height), masterImage.CGImage);
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [animationImages addObject:result];
    }
    
    if (!theImageView) {
        theImageView = [[UIImageView alloc] init];
        theImageView.layer.masksToBounds = YES;
    }
    
    theImageView.tag = (int)self.progressViewStyle;
    
    [self addSubview:theImageView];
    
    theImageView.animationImages = animationImages;
    theImageView.animationDuration = self.animationSpeed;
    
    [self layoutImageView];
    
    [theImageView startAnimating];
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oldSize, frame.size)) {
        if (self.isIndeterminate) {
            [self reloopForInterfaceChange];
        }
    }
}

@end
