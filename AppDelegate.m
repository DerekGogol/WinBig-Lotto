//
//  AppDelegate.m
//  lottosview
//
//  Created by Derek Gogol on 10/27/12.
//  Copyright (c) 2012 CalFX. All rights reserved.
//

#import "AppDelegate.h"
#import "SS.h"
#import "SSViewController.h"

@implementation AppDelegate {
	NSMutableArray *savedSets;
}

- (NSString *)ssdataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *ssfilePath = [self ssdataFilePath];
    NSLog(ssfilePath);
    
    //LOAD SAVED SETS DATA FROM FILE, IF IT EXISTS
    
    //check if file with our data sets already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:ssfilePath]) {
        
        //YES:
        //use NSKeyedUnarchiver to load data from file, put it in mutable array savedSets, look for errors loading data

        @try {
            //retrieve saved sets data from our "ssdata.plist" file
            savedSets = [NSKeyedUnarchiver unarchiveObjectWithFile:ssfilePath];
        }
        @catch (NSException *exception) {
            NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Critical Error"
                                  message:@"A critical error has occurred while loading Saved Number Sets from storage. The data file appears to be corrupt and will be deleted."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            savedSets = [NSMutableArray arrayWithCapacity:20];
            SS *ss = [[SS alloc] init];
            ss.name = @"Example";
            ss.game = @"Example number set";
            ss.rating = 5;
            ss.numbers = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
            [savedSets addObject:ss];
        }
        @finally {
            //this will be executed whether exception is thrown or not
        }
    } else{
        
        //NO:
        //data file doesn't exist yet (user ran the app first time), create one sample data set
        
        savedSets = [NSMutableArray arrayWithCapacity:200];
        SS *ss = [[SS alloc] init];
        ss.name = @"Example Five-Number Lottery Game";
        ss.game = @"Example number set";
        ss.rating = 5;
        ss.numbers = [[NSMutableArray alloc] initWithObjects:@"1",@"12",@"17",@"24",@"28",@"32",@"37", nil];
        [savedSets addObject:ss];
    }
    
    UINavigationController *navigationController;
    SSViewController *savedSetsViewController;
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        //give loaded data to SSViewController
        navigationController =
            (UINavigationController *)self.window.rootViewController;
        savedSetsViewController = [[navigationController viewControllers] objectAtIndex:0];
        savedSetsViewController.savedSets = savedSets;
    
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:app];
        
        //set the application background color (for example will be visible during Flip Horizontal transitions)
        UIColor *col = [[UIColor alloc] initWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 1.0];
        self.window.backgroundColor = col;

    }else{
        UISplitViewController *splitViewController =
            (UISplitViewController *)self.window.rootViewController;
        
        //load iPhone's storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"MainStoryboard_iPhone" bundle:nil];
        
        //InitialViewController in this case is the TabBarController
        navigationController = [storyboard instantiateInitialViewController];
        
        //add TabBarController to the SplitViewController's viewControllers property
        //so that our iPhone's TabBarController appears in the split view on iPad:
        NSArray *viewControllers = [NSArray arrayWithObjects: navigationController,
                                    [splitViewController.viewControllers lastObject],
                                    nil];
        
        splitViewController.viewControllers = viewControllers;
        splitViewController.delegate = [splitViewController.viewControllers lastObject];
        
        savedSetsViewController = [[navigationController viewControllers] objectAtIndex:0];
        savedSetsViewController.savedSets = savedSets;
        
        navigationController.contentSizeForViewInPopover = CGSizeMake(320, 460);
    }
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
//(either user pressed Home button, or the application was put in the background by iOS)
{
    //Save our user-created number sets
    //
    NSLog(@"Save File:");
	UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
	SSViewController *savedSetsViewController = [[navigationController viewControllers] objectAtIndex:0];
    NSLog([self ssdataFilePath]);

    NSData *saveToPlist;
    
    //use NSKeyedArchiver's archivedDataWithRootObject method which will call our encodeWithCoder method (see SS.m)
	//and transfer the data that's currently in "savedSets" mutable array into NSData object "saveToPlist"
    saveToPlist = [NSKeyedArchiver archivedDataWithRootObject: savedSetsViewController.savedSets];
    
    //call saveToPlist object's writeToFile method to atomically write our data to file.
    if (![saveToPlist writeToFile:[self ssdataFilePath] atomically:YES]) {
        NSLog(@"Error Coder writing to file");
    }
}

@end
