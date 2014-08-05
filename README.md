<h1>JGProgressView</h1><h6>© 2012-2014 Jonas Gessner</h6>

----------------
<br>

<p align="center">
<img src=http://j-gessner.de/general/images/JGProgressView.png>
</p>

Setup
=====
<b>CocoaPods:</b><br>
Add this to your `Podfile`:
```
pod 'JGProgressView', '1.2.1'
```
<p>
OR:
<p>
<b>Add source Files:</b><br>
1. Add the `JGProgressView` folder to your Xcode Project.<br>
2. Add the **QuartzCore** framework to your project.<br>
3. `#import "JGProgressView.h"`.<br>

Basic Usage
===========

JGProgressView is used like a normal UIProgressView with the addition of a few properties:


**BOOL indeterminate**

Property for the indeterminate setting, default is NO, set to YES to start the indeterminate animation.



**UIImage *animationImage**

Use this property to set a custom image to use for the indeterminate animation. Set this to `nil` to use the standard image for the current UIProgressViewStyle.


**NSTimeInterval animationSpeed**

Adjust the speed of the animation. The higher the value is, the slower the animation becomes. The default value is 0.5, negative values will invert the animation direction.


**beginUpdates**

**endUpdates**

Use begin- and endUpdates to increase performance when changing multiple properties of JGProgressView.


<br>
<br>

**BOOL useSharedProperties**

Defaults to NO. Set to YES to use shared image, animation speed and progress view style. This may help increasing performance when using many progress views with the same properties (ex. in a UITableViewCell).

<br>
If `useSharedImages` is `YES`. Setting `animationImage` and `animationSpeed` or calling `beginUpdate`and `endUpdates`has no effects. Instead use the following methods to change the visuals of all JGProgressViews that have `useSharedProperties` set to `YES`.


	+ (void)setSharedProgressViewAnimationSpeed:(NSTimeInterval)speed;
	+ (void)setSharedProgressViewImage:(UIImage *)img;
	+ (void)setSharedProgressViewStyle:(UIProgressViewStyle)style;

	+ (void)beginUpdatingSharedProgressViews;
	+ (void)endUpdatingSharedProgressViews;

Demo
=====
```objc
	JGProgressView *progressView = [[JGProgressView alloc] init];
	
	progressView.frame = CGRectMake(100.0f, 100.0f, 200.0f, progressView.frame.size.height);
	progressView.animationSpeed = 1.5;
	
	[self.view addSubview:progressView];

	progressView.indeterminate = YES;
```

__*Important note if your project doesn't use ARC*: you must add the `-fobjc-arc` compiler flag to `JGProgressView.m` in Target Settings > Build Phases > Compile Sources.__


Credits
======
Created by Jonas Gessner. ©2012-2014


License
=====

JGProgressView is available under the MIT License.
