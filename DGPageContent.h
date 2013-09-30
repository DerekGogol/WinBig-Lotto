//
//  DGPageContent.h
//  lottosview
//
//  Created by Derek Gogol on 2/15/13.
//  Copyright (c) 2013 CalFX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGPageContent : NSObject

@property (nonatomic, strong)NSString *pageTitle;
@property (nonatomic, strong)NSMutableString *pageText;
@property (nonatomic, strong)NSString *pageInfo;
@property (nonatomic, strong)NSMutableString *pageTextPDF;
@property (nonatomic, strong)NSMutableArray *pageDataArrayPointer;
@property (nonatomic, strong)NSString *errorStatus;

@end
