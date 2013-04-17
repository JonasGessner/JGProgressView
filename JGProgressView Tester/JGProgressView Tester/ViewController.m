//
//  ViewController.m
//  Image tester
//
//  Created by Jonas Gessner on 18.07.12.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import "ViewController.h"
#import "JGProgressView.h"

@interface ViewController ()

@end

@interface PTImage : UIImage

@end
@implementation PTImage

@end

@implementation ViewController


- (void)random:(NSTimer *)timer {
    NSArray *progss = [timer userInfo][@"OBJ"];
    
    NSUInteger ye = arc4random_uniform(2);
    BOOL ye2 = arc4random_uniform(2);
    NSUInteger width = 200;//arc4random_uniform(100)+100;
    
    for (JGProgressView *prog in progss) {
        [prog beginUpdates];
        [prog setProgressViewStyle:ye];
        [prog setAnimateToRight:ye2];
        CGRect fram = CGRectMake(prog.frame.origin.x, prog.frame.origin.y, width, prog.frame.size.height);
        [prog setFrame:fram];
        prog.center = CGPointMake(CGRectGetMidX(self.view.bounds), prog.center.y);
        [prog endUpdates];
    }
}

- (void)random2:(NSTimer *)timer {
    JGProgressView *prog = [timer userInfo][@"OBJ"];
    
    NSUInteger ye = arc4random_uniform(2);
    BOOL ye2 = arc4random_uniform(2);
    NSUInteger width = 200;//arc4random_uniform(100)+100;
    
    [prog beginUpdates];
    [prog setProgressViewStyle:ye];
    [prog setAnimateToRight:ye2];
    CGRect fram = CGRectMake(prog.frame.origin.x, prog.frame.origin.y, width, prog.frame.size.height);
    [prog setFrame:fram];
    prog.center = CGPointMake(CGRectGetMidX(self.view.bounds), prog.center.y);
    [prog endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Set up 7 progress views that share their images and transform their properties andomly every 5 seconds (in random:)
    NSUInteger count = 7;
    NSMutableArray *progressViews = [NSMutableArray arrayWithCapacity:count];
    
    NSUInteger i = 0;
    for (i = 0; i <= count; i++) {
        JGProgressView *p = [[JGProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [p setUseSharedImages:YES];
        p.frame = CGRectMake(50, 10+50*i, 230, p.frame.size.height);
        p.center = CGPointMake(CGRectGetMidX(self.view.bounds), p.center.y);
        
        [self.view addSubview:p];
        p.animationSpeed = 1.5;
        [p setIndeterminate:YES];
        
        [progressViews addObject:p];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(random:) userInfo:@{@"OBJ" : progressViews} repeats:YES];
    
    //Set up an individual progress view which doesn't use the shared animation images
    JGProgressView *p = [[JGProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    p.frame = CGRectMake(50, 10+50*i, 230, p.frame.size.height);
    p.center = CGPointMake(CGRectGetMidX(self.view.bounds), p.center.y);
    
    [self.view addSubview:p];
    p.animationSpeed = 1.5;
    [p setIndeterminate:YES];
    
    [progressViews addObject:p];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(random2:) userInfo:@{@"OBJ" : p} repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
