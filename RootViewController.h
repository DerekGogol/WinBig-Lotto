//
//  RootViewController.h
//  MyPageView
//
//  Created by Derek Gogol on 2/13/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressBar.h"

@protocol RootViewControllerDelegate <NSObject>
- (void)rootViewController:(RootViewController *)controller
                 didCancel:(SS *)ss;
@end

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (nonatomic, weak) id <RootViewControllerDelegate> delegate;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) IBOutlet UILabel *setLabel;
@property (nonatomic, strong) NSString *setName;
@property (nonatomic, strong) SS *ss;

@property (strong, nonatomic) NSArray *resultsArray;

@property (strong, nonatomic) ProgressBar *progressBar;

@property (nonatomic, assign) BOOL didFinishAnimation;

@end
