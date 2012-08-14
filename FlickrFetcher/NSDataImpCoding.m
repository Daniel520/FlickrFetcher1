//
//  NSDataImpCoding.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-5-12.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "NSDataImpCoding.h"

@implementation NSDataImpCoding

@synthesize data = _data;

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.data forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.data = [coder decodeObjectForKey:@"data"];
    }
    return self;
}

@end
