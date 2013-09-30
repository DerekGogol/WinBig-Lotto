//
//  SSViewController.h
//  lottosview
//
//  Created by Derek Gogol on 10/28/12.
//  Copyright (c) 2012 CalFX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSDetailsViewController.h"
#import "RateNumberSetViewController.h"
#import "RootViewController.h"

@interface SSViewController : UITableViewController <SSDetailsViewControllerDelegate, RateNumberSetViewControllerDelegate, RootViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *savedSets;
@property (nonatomic, strong) NSIndexPath *selectedItem;
@property (nonatomic, assign) BOOL displayNumberSetNow, editNumberSetNow;

- (IBAction)buttonAddSet:(id)sender;

@end
