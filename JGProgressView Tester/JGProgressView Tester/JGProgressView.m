//
//  JGProgressView.m
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import "JGProgressView.h"
#import <QuartzCore/QuartzCore.h>

//Shared objects
static NSMutableArray *_animationImages;
static UIImage *_masterImage;
static UIProgressViewStyle _currentStyle;
static BOOL _right;

#define kSignleElementWidth 28.0f


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
    UIImageView *theImageView;
    UIView *host;
    
    CGFloat cachedProgress;
    
    NSMutableArray *images;
    UIProgressViewStyle currentStyle;
    UIImage *master;
    
    BOOL updating;
    
    BOOL absoluteAnimateRight;
}

- (UIImage *)imageForCurrentStyle;
- (void)reloopForInterfaceChange;

- (void)setAnimationImages:(NSMutableArray *)imgs;
- (NSMutableArray *)animationImages;

- (UIImage *)masterImage;
- (void)setMasterImage:(UIImage *)img;

- (UIProgressViewStyle)currentStyle;
- (void)setCurrentStyle:(UIProgressViewStyle)_style;


- (BOOL)currentAnimateToRight;
- (void)setCurrentAnimateToRight:(BOOL)right;

- (void)layoutImageView;

@end

@implementation JGProgressView

@synthesize indeterminate, animationSpeed, useSharedImages, animateToRight;

- (void)setAnimateToRight:(BOOL)_animateToRight {
    animateToRight = _animateToRight;
    [self reloopForInterfaceChange];
}

- (void)beginUpdates {
    updating = YES;
}

- (void)endUpdates {
    updating = NO;
    [self reloopForInterfaceChange];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setClipsToBounds:YES];
        self.animationSpeed = 0.5f;
    }
    return self;
}

- (NSMutableArray *)animationImages {
    return (self.useSharedImages ? _animationImages : images);
}

- (void)setAnimationImages:(NSMutableArray *)imgs {
    if (self.useSharedImages) {
        _animationImages = imgs;
    }
    else {
        images = imgs;
    }
}


- (UIImage *)masterImage {
    return (self.useSharedImages ? _masterImage : master);
}

- (void)setMasterImage:(UIImage *)img {
    if (self.useSharedImages) {
        _masterImage = img;
    }
    else {
        master = img;
    }
}


- (UIProgressViewStyle)currentStyle {
    return (self.useSharedImages ? _currentStyle : currentStyle);
}

- (void)setCurrentStyle:(UIProgressViewStyle)_style {
    if (self.useSharedImages) {
        _currentStyle = _style;
    }
    else {
        currentStyle = _style;
    }
}


- (BOOL)currentAnimateToRight {
    return (self.useSharedImages ? _right : absoluteAnimateRight);
}

- (void)setCurrentAnimateToRight:(BOOL)right {
    if (self.useSharedImages) {
        _right = right;
    }
    else {
        absoluteAnimateRight = right;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
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

- (void)setAnimationSpeed:(NSTimeInterval)_animationSpeed {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        animationSpeed = _animationSpeed*[[UIScreen mainScreen] scale];
    }
    else {
        animationSpeed = _animationSpeed;
    }
    
    if (_animationSpeed >= 0.0f) {
        animationSpeed = _animationSpeed;
    }
    
    if (self.isIndeterminate) {
        [theImageView setAnimationDuration:self.animationSpeed];
    }
}

- (void)setProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    if (progressViewStyle == self.progressViewStyle) {
        return;
    }
    
    [super setProgressViewStyle:progressViewStyle];
    
    if (self.isIndeterminate) {
        [self reloopForInterfaceChange];
    }
}

- (float)progress {
    if (self.isIndeterminate) {
        return cachedProgress;
    }
    else {
        return [super progress];
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (self.isIndeterminate) {
        cachedProgress = progress;
    }
    else {
        [super setProgress:progress animated:animated];
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
    CGFloat border = (9-theImageView.frame.size.height);
    
    theImageView.center = CGPointMake(theImageView.center.x, CGRectGetMidY(self.bounds)-border/2);
    
    theImageView.frame = CGRectMake(border, theImageView.frame.origin.y, theImageView.frame.size.width-border*2, theImageView.frame.size.height);
    
    theImageView.layer.cornerRadius = theImageView.frame.size.height/2;
    
    host.layer.cornerRadius = theImageView.frame.size.height/2;
    
    [host setFrame:self.bounds];
}

- (void)setIndeterminate:(BOOL)_indeterminate {
    if (indeterminate == _indeterminate) {
        if (_indeterminate) {
            [self reloopForInterfaceChange];
        }
        else {
            [theImageView removeFromSuperview];
            theImageView = nil;
        }
        return;
    }
    
    if (_indeterminate) {
        cachedProgress = self.progress;
        self.progress = 0;
    }
    
    indeterminate = _indeterminate;
    
    if (indeterminate) {
        [self reloopForInterfaceChange];
    }
    else {
        self.progress = cachedProgress;
        [theImageView stopAnimating];
        [theImageView removeFromSuperview];
    }
}

- (void)reloopForInterfaceChange {
    if (updating) {
        return;
    }
    UIImage *single = [self imageForCurrentStyle];
    NSMutableArray *imgs = self.animationImages;
    UIImage *masterImage = self.masterImage;
    if (self.animateToRight != self.currentAnimateToRight || self.progressViewStyle != self.currentStyle || !masterImage || ((UIImage *)imgs.lastObject).size.width != self.frame.size.width) {
        CGFloat expectedWidth = self.frame.size.width+kSignleElementWidth;
        BOOL completeReloop = (self.progressViewStyle != self.currentStyle || !masterImage);
        
        if (completeReloop) {
            masterImage = [single copy];
            while (masterImage.size.width-kSignleElementWidth < expectedWidth) {
                masterImage = [masterImage attachImage:single];
            }
        }
        else {
            if (masterImage.size.width-kSignleElementWidth < expectedWidth) {
                while (masterImage.size.width-kSignleElementWidth < expectedWidth) {
                    masterImage = [masterImage attachImage:single];
                }
            }
            else {
                while (masterImage.size.width-kSignleElementWidth > expectedWidth+kSignleElementWidth) {
                    masterImage = [masterImage cropByX:kSignleElementWidth];
                }
            }
        }
        
        [self setMasterImage:[masterImage copy]];
    
        if (!imgs) {
            imgs = [[NSMutableArray alloc] init];
        }
        else {
            [imgs removeAllObjects];
        }
        
        CGSize size = CGSizeMake(self.frame.size.width, masterImage.size.height);
        
        CGFloat pixels = single.size.width*single.scale;
        
        CGFloat anchorX = (self.animateToRight ? -fabsf(masterImage.size.width-size.width) : 0);
        
        for (int i = 0; i <= pixels; i++) {
            UIGraphicsBeginImageContextWithOptions(size, NO, single.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextTranslateCTM(context, 0, masterImage.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextDrawImage(context, CGRectMake(anchorX+(self.animateToRight ? i : -i), 0, masterImage.size.width, masterImage.size.height), masterImage.CGImage);
            
            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [imgs addObject:result];
        }
        
        [self setCurrentAnimateToRight:self.animateToRight];
    }
    
    [self setAnimationImages:[imgs mutableCopy]];
    
    if (!theImageView) {
        theImageView = [[UIImageView alloc] init];
    }
    if (!host) {
        host = [[UIView alloc] initWithFrame:self.bounds];
        host.backgroundColor = [UIColor clearColor];
        host.layer.cornerRadius = theImageView.frame.size.height/2;
        host.clipsToBounds = YES;
    }
    
    theImageView.layer.masksToBounds = YES;
    
    [self setCurrentStyle:self.progressViewStyle];
    
    if (theImageView.superview != host) {
        [host addSubview:theImageView];
    }
    
    if (host.superview != self) {
        [self addSubview:host];
    }
    
    if (![theImageView.animationImages isEqualToArray:imgs]) {
        theImageView.animationImages = imgs;
    }
    
    if (theImageView.animationDuration != self.animationSpeed) {
        theImageView.animationDuration = self.animationSpeed;
    }
    
    [self layoutImageView];
    
    if (!theImageView.isAnimating) {
        [theImageView startAnimating];
    }
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    [super setClipsToBounds:YES];
}

- (NSArray *)subviews {
    NSMutableArray *mutable = [[super subviews] mutableCopy];
    [mutable removeObjectIdenticalTo:host];
    return [[NSArray alloc] initWithArray:mutable];
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oldSize, frame.size)) {
        if (self.isIndeterminate) {
            [self reloopForInterfaceChange];
        }
    }
}

@end
