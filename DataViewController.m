//
//  DataViewController.m
//  MyPageView
//
//  Created by Derek Gogol on 2/13/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import "DataViewController.h"
#import "RootViewController.h"
#import "DGPageContent.h"

//Constants for PDF:
static const CGSize pageSize = {612.0, 792.0};   //pixel dimensions for 8.5 x 11.0 at 72dpi
static const float kBorderInset = 0;
static const float kBorderWidth = 0;
static const float kMarginInset = 50;
static const float kLineWidth = 1;

@interface DataViewController ()
@end

@implementation DataViewController
@synthesize pdfFileName = _pdfFileName;
@synthesize progressBar = _progressBar;
@synthesize testDataGenerated = _testDataGenerated;
@synthesize currentContext = _currentContext;
@synthesize rootViewController = _rootViewController;

- (void)createThreadForProgressBar2:(id)spaceFillObj
{
    if (_progressBar != nil) {
        float spaceFill = [spaceFillObj floatValue];
        [_progressBar updateProgressBarByAmount:spaceFill];
    }
}

- (void)makeMyProgressBar2 {
    _progressBar = [[ProgressBar alloc] init:2 delegate:self];
    [self.view addSubview:_progressBar.view];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Cancel"]) {
        _testDataGenerated = true;
        NSLog(@"CANCEL in DVC.m");
    }
}

- (void)viewDidLoad
{
    NSLog(@"DVC - viewDidLoad");
    [super viewDidLoad];
    self.dataView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"DVC - didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    NSLog(@"DVC - viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
    
    //check if used hit the CANCEL BUTTON:
    if ([self.dataObject.pageText isEqualToString:@"CANCELED-BY-USER"]) {
        [self cancelAction:(UIButton *) self];
        
    //if not, display the page:
    }else{
        self.dataLabel.text = self.dataObject.pageTitle;

        //separate actual set name from other stuff and display it on the left in PageViewController
        NSArray *stringArray = [self.dataObject.pageInfo componentsSeparatedByString:@" ("];
        NSString *actualSetName = [stringArray objectAtIndex:0];
        actualSetName = [actualSetName substringToIndex: MIN(12, [actualSetName length])];
        if([actualSetName isEqualToString:@""]) {
            self.nameLabel.text = @"Untitled";
        }else{
            self.nameLabel.text = actualSetName;
        }
        //display our HTML-formatted page contained in self.dataObject.pageText in dataView
        //which is our WebView inside our DataViewController
        [self.dataView loadHTMLString:self.dataObject.pageText baseURL:nil];
    }
}

- (IBAction)cancelAction:(UIButton *)sender
{
    //delete the temporary PDF file we created
    if (_pdfFileName != nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        BOOL fileExists = [fileManager fileExistsAtPath:_pdfFileName];
        NSLog(@"Path to file: %@", _pdfFileName);
        NSLog(@"File exists: %d", fileExists);
        NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:_pdfFileName]);
        if (fileExists)
        {
            BOOL success = [fileManager removeItemAtPath:_pdfFileName error:&error];
            if (!success) {
                NSLog(@"Error: %@", [error localizedDescription]);
            }else{
                NSLog(@"File [%@] was deleted", _pdfFileName);
            }
        }else{
            NSLog(@"File [%@] cannot be deleted because it does't exist", _pdfFileName);
        }
    }

    //release memory and close this view <--------------------------------- release memory before exit!
    [self.dataObject.pageDataArrayPointer removeAllObjects];
    self.dataObject.pageDataArrayPointer  = nil;
    self.dataObject  = nil;
    NSLog(@"DVC.C - RELEASED ALL MEMORY!");
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)emailAction:(UIButton *)sender
{
    NSString *fileName = @"winbig_lotto_number_set.pdf";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [self generatePdfWithFilePath];
}

- (void)mailData:(NSData *)data
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Sending Mail", @"")
                                                        message:NSLocalizedString(@"Your device cannot send mail.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
	//create our MFMailComposeViewController view
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
	picker.mailComposeDelegate = self;
    
    NSString *actualSubject = [NSString stringWithFormat:@"WinBig Lotto numbers for %@", self.dataObject.pageInfo];
    NSArray *stringArray = [actualSubject componentsSeparatedByString:@" ("];
    actualSubject = [stringArray objectAtIndex:0];
	[picker setSubject:actualSubject];

    //attach our PDF file which by now has been generated and is sitting on disk
    NSString *actualFilename = [NSString stringWithFormat:@"%@.pdf", actualSubject];
	[picker addAttachmentData:data mimeType:@"application/pdf" fileName:actualFilename];
    
	// Set up the recipients.
	NSArray *toRecipients = [NSArray arrayWithObjects:nil];
	[picker setToRecipients:toRecipients];
    
	// Fill out the email body text.
    NSString *actualBody = [NSString stringWithFormat:@"This is the number set for:\n\n%@", self.dataObject.pageInfo];
    
    //check if we need to add the warning text
    DGPageContent *lastObjectInPageDataArray = [self.dataObject.pageDataArrayPointer objectAtIndex:([self.dataObject.pageDataArrayPointer count]-1)];
    NSString *warningText = [NSString stringWithFormat:@"%@", lastObjectInPageDataArray.errorStatus];
    
    if (![warningText isEqualToString:@"ok"]) {
        actualBody = [actualBody stringByAppendingString:@"\n\n"];
        actualBody = [actualBody stringByAppendingString:warningText];
    }

    //add message body now
	[picker setMessageBody:actualBody isHTML:NO];
    
	// Present the mail composition interface.
	[self presentModalViewController:picker animated:YES];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"DVC - webViewDidStartLoad");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //_rootViewController.didFinishAnimation = true;
    NSLog(@"DVC - webViewDidFinishLoad");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"DVC - didFailLoadWithError");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"DVC - shouldAutorotateToInterfaceOrientation");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

// Caller function for Progress Bar and then for PDF file generator:
//
- (void) generatePdfWithFilePath
{
    NSOperationQueue *queueDVC = [[NSOperationQueue alloc] init];
    queueDVC.name = @"reallyGeneratePdfWithFilePath Queue";
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(reallyGeneratePdfWithFilePath) object:nil];
    [queueDVC addOperation:operation];
    [operation setQueuePriority:NSOperationQueuePriorityNormal];

}

//////////////////////////////////
// Real PDF file generator loop:
//////////////////////////////////
- (void) reallyGeneratePdfWithFilePath
{
    //immediately display cancel button and progress bar only on bigger sets (over 50 pages in PDF file)
    if ([self.dataObject.pageDataArrayPointer count] > 50) {
        [self performSelectorOnMainThread:@selector(makeMyProgressBar2) withObject:nil waitUntilDone:false];
        NSNumber *spaceFillObj = [NSNumber numberWithFloat:0.00312];
        [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:false];
    }
    _testDataGenerated = false;

    //call UIGraphicsBeginPDFContextToFile function on the main thread to create PDF
    //graphics context and associate it with our PDF file
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        UIGraphicsBeginPDFContextToFile(_pdfFileName, CGRectZero, nil);
        _currentContext = UIGraphicsGetCurrentContext();
    });
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL done = NO;
    int currentPage=0, i=0;
    
    //do() loop, inside which we will generate the whole PDF file which we need to attach to email.
    do
    {
        if (_testDataGenerated == true) {
            //zero-out _pageDataArray ---> make program immediately return to the original page that called this method, see DataViewController.m
            done = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // Mark the beginning of a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        });
        
        // Draw a page number at the top-right of each page.
        currentPage++;
        
        //------------//
        // IMPORTANT: //
        //------------------------------------------------------------------------------------------//
        // Call methods writing to PDF on the main thread, because UIGraphicsGetCurrentContext() in //
        // these methods requires to be executed on the main thread (otherwise it won't work)       //
        //------------------------------------------------------------------------------------------//
        
        //Draw a border for each page.
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self drawBorder];
        });

        //Draw text fo our header.
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self drawHeader:i pageNumber:currentPage];
        });
        
        //Draw a line below the header.
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self drawLine:40];
        });
        
        //Draw some text for the page.
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self drawText:i verticalOffset:(float)40 horizontalOffset:(float)0];
        });
        
        //Draw a line below the header.
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self drawLine:657];
        });
        
        //Draw an image
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self drawImage];
        });
        
        //we always format 4 device screen pages on one PDF page, so increment our i variable by 4
        i+=4;
        if ([self.dataObject.pageDataArrayPointer count] <= i) {
            
            //if our i variable is greater or equal to the total number of pages we have in our set, we are done
            done = YES;
            
            //-----------------------------------------
            //we are done -> set Progress Bar to "done"
            //-----------------------------------------
            //Note: the code below *must* be executed to immediatelly dismiss the Progress bar, whether it's visible or not (it doesn't matter how many pages we have)
            //
            float spaceFill = 1.0f;
            NSNumber *spaceFillObj = [NSNumber numberWithFloat:spaceFill];
            [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:true];
        }else if ([self.dataObject.pageDataArrayPointer count] > 50) {
            //increase our Progress Bar by specific amount calclulated each time right here, inside this loop (so lame!)
            if ([self.dataObject.pageDataArrayPointer count] < 200) {
                float spaceFill = (4.0f / (float)[self.dataObject.pageDataArrayPointer count]);
                NSNumber *spaceFillObj = [NSNumber numberWithFloat:spaceFill];
                //[NSThread detachNewThreadSelector:@selector(createThreadForProgressBar:) toTarget:self withObject:spaceFillObj];
                [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:false];
                NSLog(@"%f", spaceFill);
            }else if (currentPage % 10 == 0){
                float spaceFill = (40.0f / (float)[self.dataObject.pageDataArrayPointer count]);
                NSNumber *spaceFillObj = [NSNumber numberWithFloat:spaceFill];
                //[NSThread detachNewThreadSelector:@selector(createThreadForProgressBar:) toTarget:self withObject:spaceFillObj];
                [self performSelectorOnMainThread:@selector(createThreadForProgressBar2:) withObject:spaceFillObj waitUntilDone:false];
                NSLog(@"%f", spaceFill);
            }

            //NSlog current PDF page
            if(currentPage % 100 == 0) {
                NSLog(@"Generating PDF page# %d", currentPage);
            }
        }
    }
    while (!done);
    
    //close progress bar
    [_progressBar cancelAlertView];
    
    //now let's jump on the main thread!
    [self performSelectorOnMainThread:@selector(reallyGeneratePdfWithFilePath2:) withObject:fileManager waitUntilDone:false];
}

- (void) reallyGeneratePdfWithFilePath2:(NSFileManager *) fileManager
{
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    if (_testDataGenerated == true) {
        
        //delete the temporary PDF file we created
        if (_pdfFileName != nil) {
            NSError *error;
            BOOL fileExists = [fileManager fileExistsAtPath:_pdfFileName];
            NSLog(@"Path to file: %@", _pdfFileName);
            NSLog(@"File exists: %d", fileExists);
            NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:_pdfFileName]);
            if (fileExists)
            {
                BOOL success = [fileManager removeItemAtPath:_pdfFileName error:&error];
                if (!success) {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }else{
                    NSLog(@"File [%@] was deleted", _pdfFileName);
                }
            }else{
                NSLog(@"File [%@] cannot be deleted because it does't exist", _pdfFileName);
            }
        }
    }else{
        BOOL fileExists = [fileManager fileExistsAtPath:_pdfFileName];
        NSLog(@"Path to file: %@", _pdfFileName);
        NSLog(@"File exists: %d", fileExists);
        NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:_pdfFileName]);
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:_pdfFileName];
        [self mailData:data];
        NSLog(@"File now attached: %@", _pdfFileName);
    }
}



- (void) drawText2
{
    int index=0;
    float yOffset=40;
    float xOffset = 0;
    
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    UIColor *color = [UIColor colorWithRed:255.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    
    for (int i=0; i<4; i++) {
        
        //stop if we go beyond the last element of this array
        if ([self.dataObject.pageDataArrayPointer count] <= (i + index)) {
            break;
        }
        
        DGPageContent *dgPageContent = [self.dataObject.pageDataArrayPointer objectAtIndex:(i + index)];
        
        NSString *textToDraw = dgPageContent.pageTextPDF;
        
        UIFont *font = [UIFont systemFontOfSize:12.0];
        
        CGSize stringSize = [textToDraw sizeWithFont:font
                                   constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                       lineBreakMode:UILineBreakModeWordWrap];
        
        NSArray *stringArray = [textToDraw componentsSeparatedByString:@"\n"];
        NSString *firstSet = [stringArray objectAtIndex:0];
        
        int pixels;
        if([firstSet length] < 18) {
            pixels = 138;
        }else{
            pixels = 133;
        }
        
        CGRect renderingRect =
        CGRectMake(xOffset + kBorderInset + kMarginInset + i*pixels,
                   yOffset + kBorderInset + kMarginInset + 10.0,
                   xOffset + pageSize.width - 2*kBorderInset - 2*kMarginInset,
                   yOffset + stringSize.height);
        
        [textToDraw drawInRect:renderingRect
                      withFont:font
                 lineBreakMode:UILineBreakModeWordWrap
                     alignment:UITextAlignmentLeft];
    }
}

//---------------------------------------------------------------------



- (void) drawBorder
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor brownColor];
    CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width-kBorderInset*2, pageSize.height-kBorderInset*2);
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
}


- (void) drawLine:(float)yStartPosition
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(currentContext, kLineWidth);
    
    CGContextSetStrokeColorWithColor(currentContext, [UIColor blueColor].CGColor);
    
    CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, yStartPosition + kMarginInset + kBorderInset + 1.0);
    CGPoint endPoint = CGPointMake(pageSize.width - kMarginInset -2*kBorderInset, yStartPosition + kMarginInset + kBorderInset + 1.0);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}

- (void) drawText:(int)index verticalOffset:(float)yOffset horizontalOffset:(float)xOffset
{
    //create graphics context for drawing this page
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    UIFont *font;
    
    //if Retina 4" then there will be 48 lines of text, otherwise 40 lines of text.
    //so make font smaller for 4" retina to fit all 48 lines of text.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        font = [UIFont systemFontOfSize:9.0];
    } else {
        font = [UIFont systemFontOfSize:12.0];
    }
    
    //this for() loop formats 4 device pages to one PDF page
    for (int i=0; i<4; i++) {

        //stop if we go beyond the last element of this array
        if ([self.dataObject.pageDataArrayPointer count] <= (i + index)) {
            break;
        }
        
        DGPageContent *dgPageContent = [self.dataObject.pageDataArrayPointer objectAtIndex:(i + index)];
        
        //put the string to draw inside textToDraw NSString object
        NSString *textToDraw = dgPageContent.pageTextPDF;
    
        CGSize stringSize = [textToDraw sizeWithFont:font
                               constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                   lineBreakMode:UILineBreakModeWordWrap];
        
        NSArray *stringArray = [textToDraw componentsSeparatedByString:@"\n"];
        NSString *firstSet = [stringArray objectAtIndex:0];

        int pixels;
        if([firstSet length] < 18) {
            pixels = 138;
        }else{
            pixels = 133;
        }
    
        //set the text rendering rectangle
        CGRect renderingRect =
            CGRectMake(xOffset + kBorderInset + kMarginInset + i*pixels,
                       yOffset + kBorderInset + kMarginInset + 10.0,
                       xOffset + pageSize.width - 2*kBorderInset - 2*kMarginInset,
                       yOffset + stringSize.height);
        
        //draw the text inside the rendering rectangle using the above font
        [textToDraw drawInRect:renderingRect
                      withFont:font
                 lineBreakMode:UILineBreakModeWordWrap
                     alignment:UITextAlignmentLeft];
    }
}

- (void) drawHeader:(int)index pageNumber:(int)pageNumber
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    DGPageContent *dgPageContent = [self.dataObject.pageDataArrayPointer objectAtIndex:index];
    
    //print name of the set and numbers selected by the user
    NSString *textToDraw = [NSString stringWithFormat:@"%@", dgPageContent.pageInfo];
    
    //find out how long is our pageInfo string
    NSArray *ttdParts = [textToDraw componentsSeparatedByString:@"\n"];
    int yShift = 0;
    if ([ttdParts[1] length] < 102) {
        yShift = 15;
    }
    
    UIFont *fontForPageInfo;
    //if we have 3 lines of text, just make the font smaller to fit it on 2 lines
    if ([ttdParts[1] length] > 203) {
        fontForPageInfo = [UIFont systemFontOfSize:10.0];
    }else{
        fontForPageInfo = [UIFont systemFontOfSize:12.0];
    }

    //print page numbers
    NSString *textToDraw2 = [NSString stringWithFormat:@"Page %d of %d", pageNumber,
                             1+((int)([self.dataObject.pageDataArrayPointer count]-1)/4)];
    
    UIFont *font = [UIFont systemFontOfSize:12.0];
        
    CGSize stringSize = [textToDraw sizeWithFont:font
                               constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                   lineBreakMode:UILineBreakModeWordWrap];
    CGRect renderingRect =
        CGRectMake(kBorderInset + kMarginInset,
                   kBorderInset + kMarginInset - 5.0 + yShift,
                   pageSize.width - 2*kBorderInset - 2*kMarginInset,
                   stringSize.height);
        
    [textToDraw drawInRect:renderingRect
                  withFont:fontForPageInfo
             lineBreakMode:UILineBreakModeWordWrap
                 alignment:UITextAlignmentLeft];
    
    //textToDraw2 (page number):
    CGSize stringSize2 = [textToDraw2 sizeWithFont:font
                               constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                   lineBreakMode:UILineBreakModeWordWrap];
    CGRect renderingRect2 =
        CGRectMake(440 + kBorderInset + kMarginInset,
                   kBorderInset + kMarginInset - 5.0 + yShift,
                   440 + pageSize.width - 2*kBorderInset - 2*kMarginInset,
                   stringSize2.height);
    
    [textToDraw2 drawInRect:renderingRect2
                  withFont:font
             lineBreakMode:UILineBreakModeWordWrap
                 alignment:UITextAlignmentLeft];
}


- (void) drawImage
{
    UIImage * logoImage = [UIImage imageNamed:@"WinBig_CalFX_Signature.png"];
    
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();

    //make kind of red color for the WARNING font
    UIColor *color = [UIColor colorWithRed:255.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    CGContextSetFillColorWithColor(currentContext, color.CGColor);

    //check if we need to draw the warning text
    DGPageContent *lastObjectInPageDataArray = [self.dataObject.pageDataArrayPointer objectAtIndex:([self.dataObject.pageDataArrayPointer count]-1)];
    NSString *textToDrawBelowImage = [NSString stringWithFormat:@"%@", lastObjectInPageDataArray.errorStatus];
    
    //if anything but "ok", draw the warning text on the page...
    if (![textToDrawBelowImage isEqualToString:@"ok"]) {
    
        UIFont *font = [UIFont systemFontOfSize:11.0];
    
        CGSize stringSize = [textToDrawBelowImage sizeWithFont:font
                               constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                   lineBreakMode:UILineBreakModeWordWrap];
        CGRect renderingRect =
            CGRectMake(kBorderInset + kMarginInset,
                       kBorderInset + kMarginInset + 660,
                       pageSize.width - 2*kBorderInset - 2*kMarginInset,
                       stringSize.height);
    
        [textToDrawBelowImage drawInRect:renderingRect
                  withFont:font
             lineBreakMode:UILineBreakModeWordWrap
                 alignment:UITextAlignmentLeft];
        
        //draw image, slightly lower...
        [logoImage drawInRect:CGRectMake( (pageSize.width - logoImage.size.width/2)/2, 755, logoImage.size.width/2, logoImage.size.height/2)];
        
    }else{
        //draw image in usual position
        [logoImage drawInRect:CGRectMake( (pageSize.width - logoImage.size.width/2)/2, 730, logoImage.size.width/2, logoImage.size.height/2)];
    }
}

@end





