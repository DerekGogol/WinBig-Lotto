//
//  SS.h
//  lottosview
//
//  Created by Derek Gogol on 10/28/12.
//  Copyright (c) 2012 CalFX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSCoderProtocol
- (void) encodeWithCoder: (NSCoder *) coder;
- (id) initWithCoder: (NSCoder *) decoder;
@end

@interface SS : NSObject <NSCoderProtocol>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *game;
@property (nonatomic, assign) int rating;
@property (nonatomic, copy) NSMutableArray *numbers;

@end
