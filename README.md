JGProgressView
-------------------

<p align="center">
<img src=http://j-gessner.de/general/images/JGProgressView.png>
</p>

Setup
=====
1. Add the `JGProgressView` folder to your Xcode Project

2. Add the **QuartzCore** framework to your project

3. `#import "JGProgressView.h"`

Basic Usage
===========

JGProgressView is used like a normal UIProgressView with the addition of a few properties:


**BOOL indeterminate**

- Property for the indeterminate setting, default is NO, set to YES to start the indeterminate animation


**NSTimeInterval animationSpeed**

- Adjust the speed of the animation. The higher the value is, the slower the animation becomes. Default value is 0.5, negative values will be ignored


**BOOL animateToRight**

- Default value is NO, when set to YES the animation switches over to animating to the right instead of left


**BOOL useSharedImages**

- Set this property to YES when using more than 1 progress views with identical animation related-properties (bounds, progressViewStyle, animateToRight) for improved performance (ex. in several UITableViewCells)
- DO NOT set this property to YES on more than 1 progress views if their animation related-properties (bounds, progressViewStyle, animateToRight) are different for each view.


###Additional Functionality

`beginUpdates`

`endUpdates`

when changing multiple properties that affect the animation related-properties (frame, progressViewStyle, animateToRight) in one code block, use beginUpdates before applying these changes and endUpdates after applying the changes to increase performance




###Short demonstration:

	JGProgressView *progressView = [[JGProgressView alloc] initWithFrame:CGRectMake(100, 100, 200, 11)];
	[self.view addSubview:progressView];
	progressView.useSharedImages = NO;
	progressView.animateToRight = YES;
	progressView.animationSpeed = 1.5f;
	progressView.indeterminate = YES;


__*Important note if your project doesn't use ARC*: you must add the `-fobjc-arc` compiler flag to `JGProgressView.m` in Target Settings > Build Phases > Compile Sources.__


License
=====

 

Copyright (c) 2012-2013 Jonas Gessner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
