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
    
    CGImageRef finalImage = CGBitmapContextCreateImage(context);
    
    UIImage *result = [UIImage imageWithCGImage:finalImage scale:self.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(finalImage);
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end

@interface JGProgressView () {
    NSMutableArray *animationImages;
    UIImageView *theImageView;
    
    UIImage *masterImage;
}

- (void)reloopForFrameChange;

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

- (void)setAnimationSpeed:(float)_animationSpeed {
    if (_animationSpeed > 1.0f) {
        animationSpeed = 1.0f;
    }
    else if (_animationSpeed < 0.0f) {
        animationSpeed = 0.0f;
    }
    else {
        animationSpeed = _animationSpeed;
    }
    [theImageView setAnimationDuration:self.animationSpeed];
}

- (void)setIsIndeterminate:(BOOL)_isIndeterminate {
    if (isIndeterminate == _isIndeterminate) {
        return;
    }
    
    isIndeterminate = _isIndeterminate;
    
    if (isIndeterminate) {
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 0.5f;
        
        UIImage *single = [UIImage imageNamed:@"Indeterminate.png"];
        masterImage = [single copy];
        
        while (masterImage.size.width-single.size.width < self.frame.size.width+single.size.width) {
            masterImage = [masterImage attachImage:single];
        }
        
        if (!animationImages) {
            animationImages = [[NSMutableArray alloc] init];
        }
        else {
            [animationImages removeAllObjects];
        }
        
        for (int i = 0; i < single.size.width; i++) {
            UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextTranslateCTM(context, 0, masterImage.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextDrawImage(context, CGRectMake(-i, 0, masterImage.size.width-single.size.width, masterImage.size.height), masterImage.CGImage);
            
            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [animationImages addObject:result];
        }
        
        if (!theImageView) {
            theImageView = [[UIImageView alloc] init];
        }
        
        [self addSubview:theImageView];
        
        theImageView.animationImages = animationImages;
        theImageView.animationDuration = self.animationSpeed;
        
        [theImageView startAnimating];
        
        [theImageView sizeToFit];
    }
    else {
        [theImageView stopAnimating];
        [theImageView removeFromSuperview];
        
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = NO;
        self.layer.borderWidth = 0.0f;
    }
}

- (void)reloopForFrameChange {
    UIImage *single = [UIImage imageNamed:@"Indeterminate.png"];
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
    
    [animationImages removeAllObjects];
    
    for (int i = 0; i < single.size.width; i++) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, 0, masterImage.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextDrawImage(context, CGRectMake(-i, 0, masterImage.size.width, masterImage.size.height), masterImage.CGImage);
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [animationImages addObject:result];
    }
    
    theImageView.animationImages = animationImages;
    theImageView.animationDuration = self.animationSpeed;
    
    [theImageView startAnimating];
    
    [theImageView sizeToFit];
}

- (void)setFrame:(CGRect)frame {
    if (!CGSizeEqualToSize(self.frame.size, frame.size)) {
        if (self.isIndeterminate) {
            [self reloopForFrameChange];
        }
    }
    [super setFrame:frame];
}

@end
