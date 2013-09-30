//
//  SSViewController.m
//  lottosview
//
//  Created by Derek Gogol on 10/28/12.
//  Copyright (c) 2012 CalFX. All rights reserved.
//

#import "SSViewController.h"
#import "SS.h"
#import "SSCell.h"
#import "RootViewController.h"
#import "RankingViewController.h"
#import "ProgressBar.h"

@interface SSViewController ()
@end

@implementation SSViewController
@synthesize savedSets;
@synthesize selectedItem = _selectedItem;
@synthesize displayNumberSetNow = _displayNumberSetNow;
@synthesize editNumberSetNow = _editNumberSetNow;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _displayNumberSetNow = false;
    _editNumberSetNow = false;
    
    // Info button
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(displayHelp) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    [self.tableView addGestureRecognizer:lpgr];
}

- (void)displayHelp
{
    //call "HelpPage" segue here:
    [self performSegueWithIdentifier: @"DisplayHelpPage" sender:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

// ----------------------------------//
// number of sections in Table
// ----------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// ----------------------------------//
// number of rows in a Table section //
// ----------------------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.savedSets count];
}

// ----------------------------------//
// select proper image for rating
// ----------------------------------//
- (UIImage *)imageForRating:(int)rating
{
	switch (rating)
	{
		case 1: return [UIImage imageNamed:@"1.png"];
		case 2: return [UIImage imageNamed:@"2.png"];
		case 3: return [UIImage imageNamed:@"3.png"];
		case 4: return [UIImage imageNamed:@"4.png"];
		case 5: return [UIImage imageNamed:@"5.png"];
		case 6: return [UIImage imageNamed:@"6.png"];
		case 7: return [UIImage imageNamed:@"7.png"];
		case 8: return [UIImage imageNamed:@"8.png"];
		case 9: return [UIImage imageNamed:@"9.png"];
	}
	return nil;
}

- (UIImage *)imageForUserNumbers:(int)rating
{
	switch (rating)
	{
		case 0: return [UIImage imageNamed:@"0n.png"];
		case 1: return [UIImage imageNamed:@"1n.png"];
		case 2: return [UIImage imageNamed:@"2n.png"];
		case 3: return [UIImage imageNamed:@"3n.png"];
		case 4: return [UIImage imageNamed:@"4n.png"];
		case 5: return [UIImage imageNamed:@"5n.png"];
		case 6: return [UIImage imageNamed:@"6n.png"];
		case 7: return [UIImage imageNamed:@"7n.png"];
		case 8: return [UIImage imageNamed:@"8n.png"];
		case 9: return [UIImage imageNamed:@"9n.png"];
		case 10: return [UIImage imageNamed:@"10n.png"];
		case 11: return [UIImage imageNamed:@"11n.png"];
		case 12: return [UIImage imageNamed:@"12n.png"];
		case 13: return [UIImage imageNamed:@"13n.png"];
		case 14: return [UIImage imageNamed:@"14n.png"];
		case 15: return [UIImage imageNamed:@"15n.png"];
		case 16: return [UIImage imageNamed:@"16n.png"];
		case 17: return [UIImage imageNamed:@"17n.png"];
		case 18: return [UIImage imageNamed:@"18n.png"];
		case 19: return [UIImage imageNamed:@"19n.png"];
		case 20: return [UIImage imageNamed:@"20n.png"];
		case 21: return [UIImage imageNamed:@"21n.png"];
		case 22: return [UIImage imageNamed:@"22n.png"];
		case 23: return [UIImage imageNamed:@"23n.png"];
		case 24: return [UIImage imageNamed:@"24n.png"];
		case 25: return [UIImage imageNamed:@"25n.png"];
		case 26: return [UIImage imageNamed:@"26n.png"];
		case 27: return [UIImage imageNamed:@"27n.png"];
		case 28: return [UIImage imageNamed:@"28n.png"];
		case 29: return [UIImage imageNamed:@"29n.png"];
		case 30: return [UIImage imageNamed:@"30n.png"];
		case 31: return [UIImage imageNamed:@"31n.png"];
		case 32: return [UIImage imageNamed:@"32n.png"];
		case 33: return [UIImage imageNamed:@"33n.png"];
		case 34: return [UIImage imageNamed:@"34n.png"];
		case 35: return [UIImage imageNamed:@"35n.png"];
		case 36: return [UIImage imageNamed:@"36n.png"];
		case 37: return [UIImage imageNamed:@"37n.png"];
		case 38: return [UIImage imageNamed:@"38n.png"];
		case 39: return [UIImage imageNamed:@"39n.png"];
		case 40: return [UIImage imageNamed:@"40n.png"];
		case 41: return [UIImage imageNamed:@"41n.png"];
		case 42: return [UIImage imageNamed:@"42n.png"];
		case 43: return [UIImage imageNamed:@"43n.png"];
		case 44: return [UIImage imageNamed:@"44n.png"];
		case 45: return [UIImage imageNamed:@"45n.png"];
		case 46: return [UIImage imageNamed:@"46n.png"];
		case 47: return [UIImage imageNamed:@"47n.png"];
		case 48: return [UIImage imageNamed:@"48n.png"];
		case 49: return [UIImage imageNamed:@"49n.png"];
		case 50: return [UIImage imageNamed:@"50n.png"];
		case 51: return [UIImage imageNamed:@"51n.png"];
		case 52: return [UIImage imageNamed:@"52n.png"];
		case 53: return [UIImage imageNamed:@"53n.png"];
		case 54: return [UIImage imageNamed:@"54n.png"];
		case 55: return [UIImage imageNamed:@"55n.png"];
		case 56: return [UIImage imageNamed:@"56n.png"];
		case 57: return [UIImage imageNamed:@"57n.png"];
		case 58: return [UIImage imageNamed:@"58n.png"];
		case 59: return [UIImage imageNamed:@"59n.png"];
		case 60: return [UIImage imageNamed:@"60n.png"];
	}
	return nil;
}

// --------------------------------------------//
// populate Table Cell elements from "ss" object
// --------------------------------------------//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SSCell *cell = (SSCell *)[tableView dequeueReusableCellWithIdentifier:@"SSCell"];
    
	SS *ss = [self.savedSets objectAtIndex:indexPath.row];
	cell.nameLabel.text = ss.name;
    
    NSString *thisNumberSet=@"";
    for (int i=0; i<[ss.numbers count]; i++) {
        id object = [ss.numbers objectAtIndex:i];
        int iTag = [object integerValue];
        if (i > 0) {
            thisNumberSet = [thisNumberSet stringByAppendingFormat:@", "];
        }
        thisNumberSet = [thisNumberSet stringByAppendingFormat:@"%i", iTag];
    }
	cell.gameLabel.text = thisNumberSet;
    UIImage *ballImage = [self imageForRating:ss.rating];
	cell.ratingImageView.image = [UIImage imageWithCGImage:[ballImage CGImage] scale:(ballImage.scale * 2.0)
                                               orientation:(ballImage.imageOrientation)];
    UIImage *numbersImage = [self imageForUserNumbers:[ss.numbers count]];
	cell.numbersImageView.image = [UIImage imageWithCGImage:[numbersImage CGImage] scale:(numbersImage.scale * 1.2)
                                               orientation:(numbersImage.imageOrientation)];
    return cell;
}

////////////////////////
// LONG-PRESS HANDLING:
////////////////////////

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        
        //put the index of pressed item in the global ivar
        _selectedItem = [self.tableView indexPathForRowAtPoint:p];
        if (_selectedItem == nil) {
            NSLog(@"long press on table view but not on a row");
        } else {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedItem];
            if (cell.isHighlighted) {
                NSLog(@"long press on table view at section %d row %d", _selectedItem.section, _selectedItem.row);
                
                SS *ss = [self.savedSets objectAtIndex:_selectedItem.row];
                NSString *name;
                if ([ss.name isEqualToString:@""]) {
                    name = @"Untitled";
                }else{
                    name = ss.name;
                }
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:name message:nil delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Edit", @"Delete", nil];
                [alertView show];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    NSString *nameNumberSet = [NSString stringWithFormat:@"\"%@\"", alertView.title];
    
    if([buttonTitle isEqualToString:@"Edit"]) {
        NSLog(@"Edit pressed");
        
        //call "EditNumberSet" segue here:
        //--------------------------------
        //but first choose the correct View Controller for the screen size (for iPhone 4 and earlier or for 4" Retina iPhone 5)
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            [self performSegueWithIdentifier: @"EditNumberSetRetina" sender:_selectedItem];
        } else {
            [self performSegueWithIdentifier: @"EditNumberSet" sender:_selectedItem];
        }
    }
    
    if([buttonTitle isEqualToString:@"Delete"]) {
        NSLog(@"Delete pressed");
        UIAlertView *alert2View = [[UIAlertView alloc]
                                   initWithTitle:@"Delete?" message:nameNumberSet delegate:self
                                   cancelButtonTitle:@"No"
                                   otherButtonTitles:@"Yes", nil];
        [alert2View show];
    }
    
    if([buttonTitle isEqualToString:@"Yes"]) {
        NSLog(@"Yes pressed");
        [self.savedSets removeObjectAtIndex:_selectedItem.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_selectedItem] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)buttonAddSet:(id)sender
{
    //choose the correct View Controller for the screen size (for iPhone 4 and earlier or for 4" Retina iPhone 5)
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        [self performSegueWithIdentifier: @"AddNumberSetRetina" sender:self];
    }else{
        [self performSegueWithIdentifier: @"AddNumberSet" sender:self];
    }
}

#pragma mark - SSDetailsViewControllerDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddNumberSet"])
	{
        UINavigationController *navigationController = segue.destinationViewController;
        SSDetailsViewController *ssDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
        ssDetailsViewController.delegate = self;
        ssDetailsViewController.contentSizeForViewInPopover = CGSizeMake(320, 460);
        
        //this only works on iPad in potrait mode...
        ssDetailsViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
    } else if ([segue.identifier isEqualToString:@"AddNumberSetRetina"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
 		SSDetailsViewController *ssDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
		ssDetailsViewController.delegate = self;
        ssDetailsViewController.contentSizeForViewInPopover = CGSizeMake(320, 460);
        
        //this only works on iPad in potrait mode...
        ssDetailsViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        
    } else if ([segue.identifier isEqualToString:@"EditNumberSet"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SSDetailsViewController *ssDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
        
        ssDetailsViewController.delegate = self;
        
        ssDetailsViewController.ssToEdit = [self.savedSets objectAtIndex:_selectedItem.row];
    
    } else if ([segue.identifier isEqualToString:@"EditNumberSetRetina"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SSDetailsViewController *ssDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
        
        ssDetailsViewController.delegate = self;
        
        ssDetailsViewController.ssToEdit = [self.savedSets objectAtIndex:_selectedItem.row];
        
	} else if ([segue.identifier isEqualToString:@"DisplayNumberSet"])
	{
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        _selectedItem = indexPath;

        RootViewController *rootViewController =
            segue.destinationViewController;
        rootViewController.delegate = self;
        
        SS *ss = [self.savedSets objectAtIndex:indexPath.row];
        rootViewController.setName = ss.name;
        rootViewController.ss = ss;
        
	}else if ([segue.identifier isEqualToString:@"DisplayNumberSetFromEditView"])
	{
        //trigger "EditNumberSet" segue here:
        _editNumberSetNow = true;
        
        NSIndexPath *indexPath = _selectedItem;
        RootViewController *rootViewController =
            segue.destinationViewController;
        rootViewController.delegate = self;
        
        SS *ss = [self.savedSets objectAtIndex:indexPath.row];
        rootViewController.setName = ss.name;
        rootViewController.ss = ss;
	}
    
    else if ([segue.identifier isEqualToString:@"RateNumberSet"])
    {
        RateNumberSetViewController *rateNumberSetViewController =
            segue.destinationViewController;
        rateNumberSetViewController.delegate = self;
        
        NSIndexPath *indexPath =
            [self.tableView indexPathForCell:sender];
        SS *ss = [self.savedSets objectAtIndex:indexPath.row];
        rateNumberSetViewController.ss = ss;
    }
    else if ([segue.identifier isEqualToString:@"DisplayHelpPage"])
    {
        RankingViewController *rankingViewController =
            segue.destinationViewController;
        
        rankingViewController.title = @"Help";
        NSLog(@"Help Page Displayed");
   }
}

- (void)ssDetailsViewControllerDidCancel:(SSDetailsViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

// -------------------------------------------//
// add new row to (self) --> SSViewController //
// -------------------------------------------//
- (void)ssDetailsViewController:(SSDetailsViewController *)controller didAddNumberSet:(SS *)ss
{
    //add new item to the array
	[self.savedSets addObject:ss];
    
    //tell table view the new row was added (at the bottom) -- table view and its data must be in sync, always!
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.savedSets count] - 1 inSection:0];
    _selectedItem = indexPath;
    
    @try {
        //UITableViewRowAnimationAutomatic is a constant that picks the proper animation -- very handy!
        [self.tableView insertRowsAtIndexPaths:
         [NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"An error has occurred adding new Number Set."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        //this will be executed whether exception is thrown or not --->
        //close the Add Number Set screen now
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    //trigger "DisplayNumberSetFromEditView" segue here:
    _displayNumberSetNow = true;
}

// --------------------------------------------//
// reload the cell (self) --> SSViewController //
// --------------------------------------------//
- (void)ssDetailsViewController: (SSDetailsViewController *)controller didEditNumberSet:(SS *)ss
{
    //trigger "DisplayNumberSetFromEditView" segue here:
    _displayNumberSetNow = true;

    NSUInteger index = [self.savedSets indexOfObject:ss];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    @try {
    [self.tableView reloadRowsAtIndexPaths:
             [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"An error has occurred while editing this Number Set."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        //this will be executed whether exception is thrown or not --->
        //close the Add Number Set screen now
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditNumberSet" sender:indexPath];
}

#pragma mark - RatePlayerViewControllerDelegate

- (void)rateNumberSetViewController: (RateNumberSetViewController *)controller
          didPickRatingForNumberSet:(SS *)ss
{
    NSLog(@"Redraw-0");
    if (ss.rating > 0) {
        NSUInteger index = [self.savedSets indexOfObject:ss];
        NSIndexPath *indexPath =
            [NSIndexPath indexPathForRow:index inSection:0];
    
        // redraw the table view cell for the player that was changed (by using "reloadRowsAtIndexPaths"):
        //
        NSLog(@"Redraw");
        [self.tableView reloadRowsAtIndexPaths:
                [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)rateNumberSetViewControllerDidCancel:(RateNumberSetViewController *)controller
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - RootViewControllerDelegate

- (void)rootViewController: (RootViewController *)controller didCancel:(SS *)ss
{
    [controller.view removeFromSuperview];
    [controller.pageViewController removeFromParentViewController];
    controller.pageViewController = nil;
    controller = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    if(_editNumberSetNow) {
        //choose the correct View Controller for the screen size (for iPhone 4 and earlier or for 4" Retina iPhone 5)
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            [self performSegueWithIdentifier: @"EditNumberSetRetina" sender:_selectedItem];
        }else{
            [self performSegueWithIdentifier: @"EditNumberSet" sender:_selectedItem];
        }
        _editNumberSetNow = false;
    }
}

- (void)viewDidLayoutSubviews
{
    if(_displayNumberSetNow) {
        [self performSegueWithIdentifier: @"DisplayNumberSetFromEditView" sender:self];
        _displayNumberSetNow = false;
    }
}

- (void)viewWillAppear: (BOOL) animated
{
    [self.tableView reloadData];

    if(_displayNumberSetNow || _editNumberSetNow) {
        self.view.hidden = YES;
    }
    else {
        self.view.hidden = NO;
    }
}

@end








