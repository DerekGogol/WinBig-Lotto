//
//  SS.m
//  lottosview
//
//  Created by Derek Gogol on 10/28/12.
//  Copyright (c) 2012 CalFX. All rights reserved.
//

#import "SS.h"

@implementation SS

@synthesize name;
@synthesize game;
@synthesize rating;
@synthesize numbers;

- (void) encodeWithCoder:(NSCoder *) coder {
    [coder encodeObject: name forKey:@"name"];
    [coder encodeObject: game forKey:@"game"];
    [coder encodeInt: rating forKey:@"rating"];
    [coder encodeObject: numbers forKey:@"numbers"];
}

- (id) initWithCoder:(NSCoder *) decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey: @"name"];
        self.game = [decoder decodeObjectForKey: @"game"];
        self.rating = [decoder decodeIntForKey: @"rating"];
        self.numbers = [decoder decodeObjectForKey: @"numbers"];
    }
    return (self);
}

@end
