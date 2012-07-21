JGProgressView
-------------------

![sample image](http://j-gessner.de/general/images/JGProgressView.png)


Setup
=====
1. Add the `JGProgressView` folder to your Project

2. Add the **QuartzCore** framework to your project.

2. `#import "JGProgressView.h"`

Usage
=====

It is used like a UIProgressView (obviously; its a UIProgressView subclass)

To make the Progress View indeterminate simply set the 'isIndeterminate' property to YES

You can adjust the animation speed by changing the Progress Bar's animationSpeed property (default 0.5). The value has to be positive or it will be ignored

###Short demonstration:

	JGProgressView *progressView = [[JGProgressView alloc] initWithFrame:CGRectMake(100, 100, 200, 11)];
	[self.view addSubview:progressView];
	progressView.isIndeterminate = YES;


__*Important note if your project doesn't use ARC*: you must add the `-fobjc-arc` compiler flag to `JGProgressView.m` in Target Settings > Build Phases > Compile Sources.__

License
=====

Copyright (c) 2012 Jonas Gessner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.