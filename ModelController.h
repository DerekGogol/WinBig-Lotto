//
//  ModelController.h
//  MyPageView
//
//  Created by Derek Gogol on 2/13/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGCalc.h"
#import "SS.h"
#import "ProgressBar.h"
#import "RootViewController.h"

@interface ModelController : UIViewController <UIAlertViewDelegate, UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;
- (id)initWithSS:(SS *)ss progressBar:(ProgressBar *)pb view:(id)rootViewController;

@property (strong, nonatomic) NSArray *numbersArray;
@property (strong, nonatomic) DGCalc *dgCalc;
@property (nonatomic, strong) SS *ss;
@property (strong, nonatomic) NSMutableArray *pageDataArray;

@property (strong, nonatomic) UIView *rootView;
@property (strong, nonatomic) UIViewController *modelVC;
@property (strong, nonatomic) ProgressBar *progressBar;

@property (strong, nonatomic) RootViewController *rootViewController;

@property (nonatomic, assign) BOOL testDataGenerated;

@property (nonatomic, assign) int skipCounter;

@end
