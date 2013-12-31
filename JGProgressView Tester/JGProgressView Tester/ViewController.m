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

@implementation ViewController


- (void)random:(NSTimer *)timer {
    NSUInteger ye = arc4random_uniform(2);
    NSUInteger ye2 = arc4random_uniform(50);
    BOOL ye3 = arc4random_uniform(2);
    BOOL ye4 = arc4random_uniform(2);
    
    [JGProgressView beginUpdatingSharedProgressViews];
    [JGProgressView setSharedProgressViewStyle:ye];
    [JGProgressView setSharedProgressViewImage:(ye3 ? [UIImage imageNamed:@"Alternative.png"] : nil)];
    [JGProgressView setSharedProgressViewAnimationSpeed:(ye4 ? 1.0f : -1.0f)*(25.0f/(CGFloat)ye2)];
    [JGProgressView endUpdatingSharedProgressViews];
    
}

- (void)random2:(NSTimer *)timer {
    JGProgressView *prog = [timer userInfo][@"OBJ"];
    
    NSUInteger ye = arc4random_uniform(2);
    BOOL ye2 = arc4random_uniform(300);
    BOOL ye3 = arc4random_uniform(2);
    NSUInteger width = arc4random_uniform(120)+100;
    
    BOOL ye4 = arc4random_uniform(2);
    
    [prog beginUpdates];
    [prog setProgressViewStyle:ye];
    
    [prog setAnimationImage:(ye3 ? [UIImage imageNamed:@"Alternative.png"] : nil)];
    [prog setAnimationSpeed:(ye4 ? 1.0f : -1.0f)*(25.0f/(CGFloat)ye2)];
    
    CGRect fram = CGRectMake(prog.frame.origin.x, prog.frame.origin.y, width, prog.frame.size.height);
    [prog setFrame:fram];
    prog.center = CGPointMake(CGRectGetMidX(self.view.bounds), prog.center.y);
    [prog endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Set up 5 progress views that share their images and transform their properties andomly every 5 seconds (in random:)
    NSUInteger count = 5;
    NSMutableArray *progressViews = [NSMutableArray arrayWithCapacity:count];
    
    NSUInteger i = 0;
    
    [JGProgressView beginUpdatingSharedProgressViews];
    for (i = 0; i <= count; i++) {
        JGProgressView *p = [[JGProgressView alloc] init];
        [p setIndeterminate:YES];
        p.progress = 0.5f;
        
        p.frame = CGRectMake(50.0f, 40.0f+50.0f*i, 220.0f, p.frame.size.height);
        p.center = CGPointMake(CGRectGetMidX(self.view.bounds), p.center.y);
        
        [self.view addSubview:p];
        [progressViews addObject:p];
        
        p.useSharedProperties = YES;
    }
    
    [JGProgressView setSharedProgressViewStyle:UIProgressViewStyleDefault];
    [JGProgressView setSharedProgressViewAnimationSpeed:-2.0];
    
    [JGProgressView endUpdatingSharedProgressViews];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(random:) userInfo:nil repeats:YES];

    //Set up an individual progress view which doesn't use the shared animation images
    JGProgressView *p = [[JGProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    
    [p setAnimationImage:[UIImage imageNamed:@"Alternative.png"]];
    
    p.animationSpeed = 1.6;
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(random2:) userInfo:@{@"OBJ" : p} repeats:YES];
    
    p.frame = CGRectMake(50.0f, 10.0f+50.0f*(i+1), 220.0f, p.frame.size.height);
    
    [p setIndeterminate:YES];
    
    [self.view addSubview:p];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
