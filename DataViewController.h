//
//  DataViewController.h
//  MyPageView
//
//  Created by Derek Gogol on 2/13/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "DGPageContent.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ProgressBar.h"

@interface DataViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWebView *dataView;
@property (strong, nonatomic) DGPageContent * dataObject;
@property (strong, nonatomic) NSString *pdfFileName;

@property (assign, nonatomic) CGContextRef currentContext;

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)emailAction:(UIButton *)sender;

@property (strong, nonatomic) ProgressBar *progressBar;

@property (nonatomic, assign) BOOL testDataGenerated;

@property (strong, nonatomic) RootViewController *rootViewController;

@end
