//
//  JGProgressView.h
//
//  Created by Jonas Gessner on 20.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGProgressView : UIProgressView

@property (nonatomic, unsafe_unretained) BOOL isIndeterminate; //default NO
@property (nonatomic, unsafe_unretained) float animationSpeed; //default 0.5, allowed range: 0.0 - 1.0

@end
