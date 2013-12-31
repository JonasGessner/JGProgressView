//
//  JGProgressView.m
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import "JGProgressView.h"
#import <QuartzCore/QuartzCore.h>

static NSMutableSet *_sharedProgressViews;

static UIImage *_sharedImage;
static UIProgressViewStyle _sharedStyle = UIProgressViewStyleDefault;
static NSTimeInterval _sharedAnimationSpeed = 0.5;
static BOOL _sharedAnimateToRight = NO;
static BOOL _updatingShared = NO;

static NSMutableArray *_sharedAnimationImages;


#if !__has_feature(objc_arc)
#warning JGProgressView requires ARC.
#endif


#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.2
#endif

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)

@interface JGWeakReference : NSObject

@property (nonatomic, weak) id object;

@end

@implementation JGWeakReference

@end


@interface UIImage (JGAddons)

- (UIImage *)attachImage:(UIImage *)image;
- (UIImage *)cropByX:(CGFloat)x;

@end

@implementation UIImage (JGAddons)

- (UIImage *)cropByX:(CGFloat)x {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width-x, self.size.height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0f, self.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    UIImage *result = [UIImage imageWithCGImage:image scale:self.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(image);
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)attachImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width+image.size.width, self.size.height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0f, self.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
    
    CGContextDrawImage(context, CGRectMake(self.size.width, 0.0f, image.size.width, self.size.height), image.CGImage);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

NS_INLINE UIImage *renderAnimationImages(NSMutableArray *container, UIImage *singleImage, BOOL right, CGFloat width, BOOL complete) {
    if (!width) {
        return nil;
    }
    
    CGFloat singleWidth = singleImage.size.width;
    
    UIImage *masterImage = (right ? container.lastObject : container.firstObject);
    
    if (complete || masterImage.size.width != width || !masterImage) {
        CGFloat expectedWidth = width+singleWidth*2.0f;
        
        BOOL completeReloop = (!masterImage || complete);
        
        if (completeReloop) {
            masterImage = [singleImage copy];
            
            while (masterImage.size.width < expectedWidth) {
                masterImage = [masterImage attachImage:singleImage];
            }
        }
        else {
            while (masterImage.size.width < expectedWidth) {
                masterImage = [masterImage attachImage:singleImage];
            }
            while (masterImage.size.width-singleWidth > expectedWidth+singleWidth) {
                masterImage = [masterImage cropByX:singleWidth];
            }
        }
        
        [container removeAllObjects];
        
        CGSize size = CGSizeMake(width, masterImage.size.height);
        
        CGFloat pixels = singleWidth*[UIScreen mainScreen].scale;
        
        CGFloat anchorX = (right ? -fabsf(masterImage.size.width-width) : 0.0f);
        
        for (int i = 0; i <= pixels; i++) {
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
            
            [masterImage drawInRect:(CGRect){{anchorX+(right ? i : -i), 0.0f}, masterImage.size}];
            
            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
            
            if (result) {
                [container addObject:result];
            }
            
            UIGraphicsEndImageContext();
        }
    }
    
    return masterImage;
}

@end

@interface JGProgressView () {
    UIImageView *_imageView;
    
    CGFloat _cachedProgress;
    
    NSMutableArray *_animationImages;
    
    BOOL _updating;
    
    BOOL _animateToRight;
}


@end

@implementation JGProgressView

@synthesize animationImage = _animationImage;

NS_INLINE void updateSharedProgressViewList(BOOL complete) {
    if (_updatingShared) {
        return;
    }
    
    if (!_sharedAnimationImages) {
        _sharedAnimationImages = [NSMutableArray array];
    }
    
    BOOL doneRendering = NO;
    
    for (JGWeakReference *ref in _sharedProgressViews.copy) {
        if (!ref.object) {
            [_sharedProgressViews removeObject:ref];
        }
        else {
            JGProgressView *prog = ref.object;
            
            prog.progressViewStyle = _sharedStyle;
            
            if (!doneRendering) {
                if (!_sharedImage) {
                    if (iOS7) {
                        CGSize size = (CGSize){27.5f, prog.frame.size.height};
                        
                        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
                        
                        [prog.tintColor setFill];
                        
                        [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, {size.width/2.0f, size.height}}] fill];
                        
                        _sharedImage = UIGraphicsGetImageFromCurrentImageContext();
                        
                        UIGraphicsEndImageContext();
                    }
                    else {
                        if (_sharedStyle == UIProgressViewStyleDefault) {
                            _sharedImage = [UIImage imageNamed:@"Indeterminate.png"];
                        }
                        else {
                            _sharedImage = [UIImage imageNamed:@"IndeterminateBar.png"];
                        }
                    }
                }
                
                renderAnimationImages(_sharedAnimationImages, _sharedImage, _sharedAnimateToRight, prog.frame.size.width, complete);
                
                doneRendering = YES;
            }
            
            [prog updateImageView];
        }
    }
    
}


+ (void)beginUpdatingSharedProgressViews {
    _updatingShared = YES;
}

+ (void)endUpdatingSharedProgressViews {
    _updatingShared = NO;
    updateSharedProgressViewList(NO);
}


+ (void)setSharedProgressViewImage:(UIImage *)image {
    _sharedImage = image;
    _sharedAnimationImages = nil;
    
    updateSharedProgressViewList(YES);
}

+ (void)setSharedProgressViewAnimationSpeed:(NSTimeInterval)speed {
    if (_sharedAnimationSpeed == speed) {
        return;
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        _sharedAnimationSpeed = fabs(speed*[[UIScreen mainScreen] scale]);
    }
    else {
        _sharedAnimationSpeed = fabs(speed);
    }
    
    _sharedAnimateToRight = (speed < 0.0);
    
    updateSharedProgressViewList(NO);
}


+ (void)setSharedProgressViewStyle:(UIProgressViewStyle)style {
    if (_sharedStyle == style) {
        return;
    }
    
    _sharedStyle = style;
    
    _sharedImage = nil;
    _sharedAnimationImages = nil;
    
    updateSharedProgressViewList(YES);
}



- (void)setUseSharedProperties:(BOOL)useSharedImages {
    if (_useSharedProperties == useSharedImages) {
        return;
    }
    
    _useSharedProperties = useSharedImages;
    
    if (_useSharedProperties) {
        if (!_sharedProgressViews) {
            _sharedProgressViews = [NSMutableSet set];
        }
        
        JGWeakReference *ref = [JGWeakReference new];
        ref.object = self;
        
        [_sharedProgressViews addObject:ref];
    }
    else {
        for (JGWeakReference *ref in _sharedProgressViews.copy) {
            if (ref.object) {
                if (ref.object == self) {
                    [_sharedProgressViews removeObject:ref];
                    break;
                }
            }
            else {
                [_sharedProgressViews removeObject:ref];
            }
        }
        
        _animationImage = nil;
        _animationImages = nil;
        
        if (self.indeterminate) {
            [self reloopForInterfaceChange:YES];
        }
    }
}


- (void)commonInit {
    [self setClipsToBounds:YES];
    self.animationSpeed = 0.5f;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithProgressViewStyle:(UIProgressViewStyle)style {
    self = [super initWithProgressViewStyle:style];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}



- (void)beginUpdates {
    _updating = YES;
}

- (void)endUpdates {
    _updating = NO;
    if (!_useSharedProperties) {
        [self reloopForInterfaceChange:NO];
    }
}


- (UIImage *)makeAnimationImageForCurrentStyle {
    UIImage *img = nil;
    
    if (iOS7) {
        CGSize size = (CGSize){27.5f, self.frame.size.height};
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        [self.tintColor setFill];
        
        [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, {size.width/2.0f, size.height}}] fill];
        
        img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    else {
        if (self.progressViewStyle == UIProgressViewStyleDefault) {
            img = [UIImage imageNamed:@"Indeterminate.png"];
        }
        else {
            img = [UIImage imageNamed:@"IndeterminateBar.png"];
        }
    }
    
    return img;
}


- (UIImage *)animationImage {
    if (!_useSharedProperties) {
        if (!_animationImage) {
            _animationImage = [self makeAnimationImageForCurrentStyle];
        }
        
        NSParameterAssert(_animationImage);
        
        return _animationImage;
    }
    
    return nil;
}

- (void)setAnimationImage:(UIImage *)animationImage {
    if (!_useSharedProperties) {
        if (animationImage != _animationImage) {
            [self willChangeValueForKey:@"animationImage"];
            _animationImage = animationImage;
            
            _animationImages = nil;
            
            if (self.indeterminate) {
                [self reloopForInterfaceChange:YES];
            }
            
            [self didChangeValueForKey:@"animationImage"];
        }
    }
}

- (void)setAnimationSpeed:(NSTimeInterval)animationSpeed {
    if (!_useSharedProperties) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            _animationSpeed = fabs(animationSpeed*[[UIScreen mainScreen] scale]);
        }
        else {
            _animationSpeed = fabs(animationSpeed);
        }
        
        _animateToRight = (animationSpeed < 0.0);
        
        if (self.isIndeterminate) {
            [_imageView setAnimationDuration:self.animationSpeed];
        }
    }
}

- (void)setProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    if (progressViewStyle == self.progressViewStyle) {
        return;
    }
    
    [super setProgressViewStyle:progressViewStyle];
    
    if (!_useSharedProperties) {
        _animationImage = nil;
        _animationImages = nil;
        
        if (self.isIndeterminate) {
            [self reloopForInterfaceChange:YES];
        }
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if ([tintColor isEqual:self.tintColor]) {
        return;
    }
    
    [super setTintColor:tintColor];
    
    if (!_useSharedProperties) {
        _animationImage = nil;
        _animationImages = nil;
        
        if (self.isIndeterminate) {
            [self reloopForInterfaceChange:YES];
        }
    }
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    [super setClipsToBounds:YES];
}

- (NSArray *)subviews {
    NSMutableArray *mutable = [[super subviews] mutableCopy];
    [mutable removeObjectIdenticalTo:_imageView];
    return [mutable copy];
}

- (void)setFrame:(CGRect)frame {
    if (!_useSharedProperties) {
        CGSize oldSize = self.frame.size;
        
        [super setFrame:frame];
        
        if (!CGSizeEqualToSize(oldSize, frame.size)) {
            if (self.isIndeterminate) {
                [self reloopForInterfaceChange:NO];
            }
        }
    }
    else {
        [super setFrame:frame];
        if (self.isIndeterminate) {
            [self layoutImageView];
        }
    }
}

- (void)layoutImageView {
    [_imageView sizeToFit];
    
    UIEdgeInsets insets = (!iOS7 && self.progressViewStyle == UIProgressViewStyleBar ? UIEdgeInsetsMake(1.0f, 1.0f, 2.0f, 1.0f) : UIEdgeInsetsZero);
    
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, insets);
    
    _imageView.frame = frame;
    
    if (!iOS7) {
        _imageView.layer.cornerRadius = frame.size.height/2.0f;
    }
}

#pragma mark - Progress Handling

- (float)progress {
    if (self.isIndeterminate) {
        return _cachedProgress;
    }
    else {
        return [super progress];
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (self.isIndeterminate) {
        _cachedProgress = progress;
    }
    else {
        [super setProgress:progress animated:animated];
    }
}

- (void)setProgress:(float)progress {
    if (self.isIndeterminate) {
        _cachedProgress = progress;
    }
    else {
        [super setProgress:progress];
    }
}


#pragma mark - Indeterminate Handling


- (void)setIndeterminate:(BOOL)indeterminate {
    if (_indeterminate == indeterminate) {
        return;
    }
    
    if (indeterminate) {
        _cachedProgress = self.progress;
        
        self.progress = 0.0f;
    }
    
    _indeterminate = indeterminate;
    
    if (_indeterminate) {
        if (!_useSharedProperties) {
            [self reloopForInterfaceChange:NO];
        }
        else {
            [self updateImageView];
        }
    }
    else {
        self.progress = _cachedProgress;
        
        [_imageView stopAnimating];
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
}

- (void)renderAnimationImages:(BOOL)complete {
    if (!_animationImages) {
        _animationImages = [NSMutableArray array];
    }
    
    renderAnimationImages(_animationImages, self.animationImage, _animateToRight, self.frame.size.width, complete);
}

- (void)reloopForInterfaceChange:(BOOL)complete {
    if (_updating) {
        return;
    }
    
    [self renderAnimationImages:YES];
    
    [self updateImageView];
}

- (void)updateImageView {
    if (self.indeterminate) {
        if (!_imageView) {
            _imageView = [[UIImageView alloc] init];
            _imageView.layer.masksToBounds = YES;
            _imageView.clipsToBounds = YES;
            
            [self addSubview:_imageView];
        }
        
        
        _imageView.animationImages = (_useSharedProperties ? _sharedAnimationImages : _animationImages);
        
        NSTimeInterval speed = (_useSharedProperties ? _sharedAnimationSpeed : self.animationSpeed);
        
        if (_imageView.animationDuration != speed) {
            _imageView.animationDuration = speed;
        }
        
        [self layoutImageView];
        
        if (!_imageView.isAnimating) {
            [_imageView startAnimating];
        }
    }
    else {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
}

@end
