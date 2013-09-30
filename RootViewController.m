//
//  RootViewController.m
//  MyPageView
//
//  Created by Derek Gogol on 2/13/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "RootViewController.h"
#import "ModelController.h"
#import "DataViewController.h"
#import "SS.h"

@interface RootViewController ()
@property (readonly, strong, nonatomic) ModelController *modelController;
@end

@implementation RootViewController

@synthesize modelController = _modelController;
@synthesize delegate;
@synthesize setLabel;
@synthesize setName;

@synthesize resultsArray = _resultsArray;
@synthesize progressBar = _progressBar;
@synthesize didFinishAnimation;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didFinishAnimation = true;
    
    NSOperationQueue *queueRVC = [[NSOperationQueue alloc] init];
    queueRVC.name = @"viewDidLoadContinued Queue";
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                    selector:@selector(viewDidLoadContinued) object:nil];
    [queueRVC addOperation:operation];
    [operation setQueuePriority:NSOperationQueuePriorityNormal];

}

- (void)viewDidLoadContinued
{
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    //This line creates ModelController object (ModelController.m) and initializes it with date - look at ModelController init below first! run in debug if still unclear!
    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    
    //IMPORTANT:
    //----------
    //deallocate, destroy dgSet and dgCalc that holds data inside struct, as we don't need this data any more because
    //the results are now inside the "dataObject" and everything is now formatted as web pages ready to be displayed.
    _modelController.dgCalc.dgSet = nil;
    _modelController.dgCalc = nil;
    
    [self performSelectorOnMainThread:@selector(viewDidLoadContinued2:) withObject:startingViewController waitUntilDone:true];
}

- (void)viewDidLoadContinued2:(DataViewController *) startingViewController
{
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    //set Model Controller as the data source
    self.pageViewController.dataSource = self.modelController;

    //add Page View Controller as the child view controller
    [self addChildViewController:self.pageViewController];

    //add Page View Controller as the root controller's subview to actually SEE IT ON THE SCREEEN <--- IMPORTANT!!!
    [self.view addSubview:self.pageViewController.view];
    
    //SET Page View Controller's POSITION <--- IMPORTANT!!!
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)dealloc
{
    self.resultsArray = nil;
    [_modelController.pageDataArray removeAllObjects];
    _modelController.pageDataArray = nil;
    [self.delegate rootViewController:self didCancel:self.ss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (ModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
    if (!_modelController) {
        _modelController = [[ModelController alloc] initWithSS:(SS *)self.ss progressBar:(ProgressBar *)_progressBar view:self];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.didFinishAnimation = true;
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    DataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];


    return UIPageViewControllerSpineLocationMid;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

@end
