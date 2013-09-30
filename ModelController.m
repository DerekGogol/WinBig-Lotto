//
//  ModelController.m
//  MyPageView
//
//  Created by Derek Gogol on 2/13/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import <mach/mach.h>
#import <mach/mach_host.h>
#import <UIKit/UIKit.h>
#import "ModelController.h"
#import "DataViewController.h"
#import "DGPageContent.h"
#import "RootViewController.h"
#import "DGCalc.h"
#import "DGSet.h"
#import "SS.h"

@interface ModelController()
@end

@implementation ModelController

@synthesize pageDataArray = _pageDataArray;
@synthesize numbersArray = _numbersArray;
@synthesize dgCalc = _dgCalc;
@synthesize ss = _ss;
@synthesize progressBar = _progressBar;
@synthesize rootView = _rootView;
@synthesize rootViewController = _rootViewController;
@synthesize modelVC = _modelVC;
@synthesize testDataGenerated = _testDataGenerated;
@synthesize skipCounter;

int iMemoryWarning = 0;     //keep track of how many memory warnings we got and abort on #3 (arbitrary number, but it should be a conservative, safe number)


- (void)dealloc
{
    [_pageDataArray removeAllObjects];
    _pageDataArray = nil;
    _ss = nil;
    _numbersArray = nil;
    NSLog(@"Released ModelController memory in dealloc");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pageDataArray removeAllObjects];
    _pageDataArray = nil;
    _ss = nil;
    _numbersArray = nil;
    NSLog(@"Released memory in MC.m");
}

- (void)createThreadForProgressBar2:(id)spaceFillObj
{
        if (_progressBar != nil) {
            float spaceFill = [spaceFillObj floatValue];
            [_progressBar updateProgressBarByAmount:spaceFill];
        }
}

- (void)makeMyProgressBar2 {
    
    UIImage *calcScreen;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        calcScreen = [UIImage imageNamed: @"WBcalcscreen4@2.png"];
    } else {
        calcScreen = [UIImage imageNamed: @"WBcalcscreen.png"];
    }
    UIImageView *calcScreenView = [[UIImageView alloc] initWithImage: calcScreen];
    
    CGRect rootVCFrame = CGRectMake(0, 0, _rootViewController.view.frame.size.width, _rootViewController.view.frame.size.height);
    calcScreenView.frame = rootVCFrame;
    
    [_rootViewController.view addSubview: calcScreenView];
    
    _progressBar = [[ProgressBar alloc] init:1 delegate:self];
    [_rootViewController.view addSubview:_progressBar.view];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Cancel"]) {
        _testDataGenerated = true;
        NSLog(@"CANCEL in MC.m");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"vewi will appear");
}

- (void)viewDidLoad
{
    NSLog(@"ModelController didLoad");
    [super viewDidLoad];
}


- (void)generateTestDataContinued
{
    //immediately display cancel button and progress bar only on bigger sets (over 17 numbers in play)
    if ([self.ss.numbers count] > 17) {
        [self performSelectorOnMainThread:@selector(makeMyProgressBar2) withObject:nil waitUntilDone:true];
        NSNumber *spaceFillObj = [NSNumber numberWithFloat:0.00312];
        [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:false];
    }

    _testDataGenerated = false;
    
    //create dgCalculator instance and do temporary test numbers
    _dgCalc = [[DGCalc alloc] init];
    NSLog(@"new DGCalc in generateTestDataContinued()");
    
    //pass pointer to our true/false variable in case user taps Cancel while [_dgCalc calcResultThread] is still running
    _dgCalc.testDataGenerated = &(_testDataGenerated);
    
    [_dgCalc.dgSet setControlArray: self.ss.rating: 0: [self.ss.numbers count]];   //[example: 5: 0: 8] == 5 balls game, 0 powerballs, 8 of my picked numbers;
    [_dgCalc.dgSet setInputArray2:(NSMutableArray *)self.ss.numbers];

    //calculate set!
    [_dgCalc calcResultThread];
    
    _pageDataArray = [[NSMutableArray alloc] initWithCapacity:50000];       //50K pages of 40 number sets, for max of 2,000,000 generated number sets (allocated in DGSet.h in struct)

    //how many lines of text can we fit on device's screen (40 for iPhone 4 and earlier or 50 for 4" Retina iPhone 5)
    int maxTextLines;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        maxTextLines = 48;
    } else {
        maxTextLines = 40;
    }

    struct task_basic_info taskinfo;
    struct host_basic_info hostinfo;
    int i = 0;
    NSString *stringTotalNumberSets, *stringTotalNumberSetsPDF;
    NSString *stringNextNumberSet = [[NSString alloc] init];
    NSString *stringLastNumberSet = [[NSString alloc] init];
    
    //---------------------------------------------------------------------------------------------------------------------------------------//
    // while() loop will iterate through all elements of the C structure contained within the "_dgCalc" object and will exit when the string //
	// returned from an element of this C structure equals "end-of-results".  I decided to use C structure because it should be faster       //
    // than storing large data set in an object like an instance of NSObject.  C struct should also take less memory to store all of         //
	// our data than an object.                                                                                                              //
    //---------------------------------------------------------------------------------------------------------------------------------------//
    //
    while (![stringNextNumberSet isEqual: @"end-of-results"]) {

        //allocate Page Content object - create instance of "DGPageContent" object (see DGPageContent.h) named "pContent"
        DGPageContent *pContent = [[DGPageContent alloc] init];
        
        //further in this while() loop we will populate "pContent" object's properties with strings, some of which are in plain text for display in
        //the PDF file while others are in HTML format for later display in the UIWebView inside DataViewController.
        
        //update our Progress Bar view
        if (_progressBar != nil && (i % 10) == 0) {
            if (_testDataGenerated == true) {
                //zero-out _pageDataArray ---> make program immediately return to the original page that called this method, see DataViewController.m
                [_pageDataArray removeAllObjects];
                pContent.pageText = [NSMutableString stringWithFormat:@"CANCELED-BY-USER"];
                [_pageDataArray addObject:pContent];
                pContent = nil;
                break;
            }
            if ([self.ss.numbers count] > 17) {
                float spaceFill = (10.0f / (float)(1+[_dgCalc.dgSet arrOutputPointerGet]/maxTextLines));
                NSNumber *spaceFillObj = [NSNumber numberWithFloat:spaceFill];
                [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:true];
            }
        }
        
        //page textPDF
        pContent.pageTextPDF = [NSMutableString stringWithFormat:@""];

        //page title
        pContent.pageTitle = [NSString stringWithFormat:@"Page %d of %d", ++i, (int)(1+[_dgCalc.dgSet arrOutputPointerGet]/maxTextLines)];
        
        //page text
        float fontSize = 1.0;
        if(self.ss.rating == 7) {
            fontSize = 0.95;
        }
        pContent.pageText = [NSMutableString stringWithFormat:@"<html><meta name='viewport' content='width=300' /><head><style type=\"text/css\"> tr.l td {background-color: #FFFFFF;text-align:center;} tr.d td {background-color: #CFCFCF;text-align:center;} tr.f td {border: 1px solid black;text-align:center;overflow:hidden;display:inline-block;white-space:nowrap;} table { font-size:%fem; } hr.fade {border: 0; height: 1px; background: #333; background-image: -webkit-linear-gradient(left, #ccc, #333, #ccc); background-image: -moz-linear-gradient(left, #ccc, #333, #ccc); background-image: -ms-linear-gradient(left, #ccc, #333, #ccc); background-image: -o-linear-gradient(left, #ccc, #333, #ccc); }</style></head><body>", fontSize];
        
        [pContent.pageText appendString:@"<hr class=\"fade\">"];
        [pContent.pageText appendString:@"<table colspan=\"2\" border=\"0\" width=\"100%\">"];
        
        int n;
        for(n=0; n<maxTextLines; n++) {
            
            if (n == 0) {
                [pContent.pageText appendString:@"<tr><td align=\"center\" valign=\"top\"><table width=\"50%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">"];
            }else
            if (n == maxTextLines / 2) {
                [pContent.pageText appendString:@"</table></td><td align=\"center\" valign=\"top\"><table width=\"50%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">"];
            }
            
            stringLastNumberSet = [stringNextNumberSet copy];
            stringNextNumberSet = [_dgCalc.dgSet arrOutputGetNextNumberSet];
            if ([stringNextNumberSet isEqual: @"end-of-results"]) {
                if ([_dgCalc.dgSet arrControlGet:0] < 4) {
                    [pContent.pageText appendString:@"<tr class=\"f\"><td>-- end --<br>"];
                    [pContent.pageTextPDF appendString:@"--- end ---\n"];
                    stringTotalNumberSets = [NSString stringWithFormat:@"Total: %d</tr></td>", [_dgCalc.dgSet arrOutputPointerGet]];
                    stringTotalNumberSetsPDF = [NSString stringWithFormat:@"Total %d", [_dgCalc.dgSet arrOutputPointerGet]];
                }else if ([_dgCalc.dgSet arrControlGet:0] == 4) {
                    [pContent.pageText appendString:@"<tr class=\"f\"><td>---- end ----<br>"];
                    [pContent.pageTextPDF appendString:@"----- end -----\n"];
                    stringTotalNumberSets = [NSString stringWithFormat:@"Total: %d</tr></td>", [_dgCalc.dgSet arrOutputPointerGet]];
                    stringTotalNumberSetsPDF = [NSString stringWithFormat:@"Total %d sets", [_dgCalc.dgSet arrOutputPointerGet]];
                }else{
                    [pContent.pageText appendString:@"<tr class=\"f\"><td>----- end -----<br>"];
                    [pContent.pageTextPDF appendString:@"------- end ------\n"];
                    stringTotalNumberSets = [NSString stringWithFormat:@"Total sets: %d</tr></td>", [_dgCalc.dgSet arrOutputPointerGet]];
                    stringTotalNumberSetsPDF = [NSString stringWithFormat:@"Total: %d sets", [_dgCalc.dgSet arrOutputPointerGet]];
                }
                [pContent.pageText appendString:stringTotalNumberSets];
                [pContent.pageTextPDF appendString:stringTotalNumberSetsPDF];
                break;
            }
            
            //print color-coded number sets
            if (n % 2) {
                [pContent.pageText appendString:@"<tr class=\"l\"><td>"];
            }else{
                [pContent.pageText appendString:@"<tr class=\"d\"><td>"];
            }
            [pContent.pageText appendString:stringNextNumberSet];
            [pContent.pageText appendString:@"</tr></td>"];
            
            [pContent.pageTextPDF appendString:stringNextNumberSet];
            [pContent.pageTextPDF appendString:@"\n"];
        }
        if (n < (maxTextLines/2)) {
            [pContent.pageText appendString:@"</table></td><td align=\"center\" valign=\"top\"><table width=\"50%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">"];
            [pContent.pageText appendString:@"<tr class=\"l\"><td><div style=\"visibility:hidden\">"];
            [pContent.pageText appendString:stringLastNumberSet];
            [pContent.pageText appendString:@"</div>"];
            [pContent.pageText appendString:@"</tr></td>"];
        }
        [pContent.pageText appendString:@"</table></td></tr></table></body></html>"];
        
        //check available memory status every 100th page we generate and abort with Alert View if
        //we start running too low on memory
        //
        if( i % 100 == 0) {
            NSLog(@"P# %d of %d", i, (int)(1+[_dgCalc.dgSet arrOutputPointerGet]/maxTextLines));
            
            //monitor the avaliable memory!
            mach_msg_type_number_t tsize = sizeof(taskinfo);
            kern_return_t tkerr = task_info(mach_task_self(),
                                            TASK_BASIC_INFO,
                                            (task_info_t)&taskinfo,
                                            &tsize);
            
            mach_msg_type_number_t hsize = sizeof(hostinfo);
            kern_return_t hkerr = host_info(mach_host_self(),
                                            HOST_BASIC_INFO,
                                            (host_info_t)&hostinfo,
                                            &hsize);
            //LOG memory to NSLog()
            if( tkerr == KERN_SUCCESS ) {
                NSLog(@"MemoryR used: %u", taskinfo.resident_size); //in bytes
            } else {
                NSLog(@"Error: %s", mach_error_string(tkerr));
            }
            if( hkerr == KERN_SUCCESS ) {
                NSLog(@"Memoryh size: %u", hostinfo.memory_size); //in bytes
                NSLog(@"MemoryF FREE: %u", freeMemory()); //in bytes
            } else {
                NSLog(@"Error: %s", mach_error_string(hkerr));
            }

            //Memory too low - stop the program now!
            if(freeMemory() < 2850000 || iMemoryWarning > 2)
            {
                iMemoryWarning = 0;
                
                NSLog(@"120MB>M WARN: %u", hostinfo.memory_size - taskinfo.resident_size); //in bytes
                NSLog(@"FreeMem WARN: %u", freeMemory()); //in bytes
                
                //close progress bar
                [_progressBar cancelAlertView];

                NSString *errMessage = [NSString stringWithFormat:
                                        @"Program stopped calculations because your device was running out of memory. Only %d out of %d total pages were generated. See help section for more info.", i, (int)(1+[_dgCalc.dgSet arrOutputPointerGet]/maxTextLines)];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Low on Memory"
                                      message:errMessage
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                
                //page info (has user chosen name & numbers) - THIS GOES ON THE LAST PAGE in PDF!
                pContent.errorStatus = [NSString stringWithFormat:@"ATTENTION! INCOMPLETE SET! Program stopped calculations because your device was running out of memory. Only %d out of %d total number sets were generated. (Showing %d pages out of %d total pages). See help section for more info.", i*40, [_dgCalc.dgSet arrOutputPointerGet], i/4, (int)(1+[_dgCalc.dgSet arrOutputPointerGet]/160)];
                
                //add last page
                [_pageDataArray addObject:pContent];
                pContent = nil;

                [alert show];
                
                break;
            }
        }

        //error status so far
        pContent.errorStatus = [NSString stringWithFormat:@"ok"];
                             
        //page info (has user chosen name & numbers)
        pContent.pageInfo = [NSString stringWithFormat:@"%@ (%d-ball game)  \n%@ (%d numbers)", self.ss.name,
                             self.ss.rating,
                             [[self.ss.numbers valueForKey:@"description"] componentsJoinedByString:@", " ],
                             [self.ss.numbers count]];

        //add just formatted above page now in "pContent" to our mutable array named "_pageDataArray" which
        //will hold all of our pages we need to display to the user before the while() loop ends.
        [_pageDataArray addObject:pContent];
        pContent = nil;
        
    } //while
    
    //close progress bar
    if ([self.ss.numbers count] > 17) {
        NSNumber *spaceFillObj = [NSNumber numberWithFloat:1.0f];
        [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:true];
        [_progressBar cancelAlertView];
    }
}

// ---------------------------------------------------------
// This function will return the available memory in bytes:
// ---------------------------------------------------------
natural_t  freeMemory(void) {
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    
    host_page_size(host_port, &pagesize);
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    
    natural_t   mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t   mem_free = vm_stat.free_count * pagesize;
    natural_t   mem_total = mem_used + mem_free;
    
    return mem_free;
}

- (id)initWithSS:(SS *)ss progressBar:(ProgressBar *)pb view:rootViewController;
{
    self = [super init];
    if (self) {
        _rootViewController = rootViewController;
        _progressBar = pb;
        _ss = ss;
        skipCounter = 0;
        
        [self generateTestDataContinued];
        return self;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
// programmatically instantiate Data View Controller which will display our pages to the user       //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////
- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if (([self.pageDataArray count] == 0) || (index >= [self.pageDataArray count])) {
        return nil;
    }
    
    // Create a new "DataViewController" defined in storyboard file and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    
    //pass pointer to rootViewController because in dataViewController we need to do "_rootViewController.didFinishAnimation = true;" when the webView fully loads
    dataViewController.rootViewController = _rootViewController;
    dataViewController.dataObject = self.pageDataArray[index];
    
    //pass our page data to dataObject inside the DataViewController (see DataViewController.h)
    dataViewController.dataObject.pageDataArrayPointer = self.pageDataArray;
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{   
    // Return the index of the given data view controller
    return [self.pageDataArray indexOfObject:viewController.dataObject];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (skipCounter > 2) {
        _rootViewController.didFinishAnimation = true;
    }
    
    if (_rootViewController.didFinishAnimation) {
        _rootViewController.didFinishAnimation = false;
        skipCounter = 0;
        
        NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
        if ((index == 0) || (index == NSNotFound)) {
            _rootViewController.didFinishAnimation = true;
            return nil;
        }
    
        index--;
        return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
    }
    skipCounter++;
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSLog(@"%d",skipCounter);
    
    if (skipCounter > 2) {
        _rootViewController.didFinishAnimation = true;
    }
    
    if (_rootViewController.didFinishAnimation) {
        _rootViewController.didFinishAnimation = false;
        skipCounter = 0;
        
        NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
        if (index == NSNotFound) {
            _rootViewController.didFinishAnimation = true;
            return nil;
        }
    
        index++;
    
        if (index == [self.pageDataArray count]) {
            _rootViewController.didFinishAnimation = true;
            return nil;
        }
        return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
    }
    skipCounter++;
    return nil;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MC.c - didReceiveMemoryWarning (%d)", ++iMemoryWarning);
    [super didReceiveMemoryWarning];
}

@end
