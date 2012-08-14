//
//  NSDataImpCoding.h
//  FlickrFetcher
//
//  Created by Daniel yu on 12-5-12.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDataImpCoding : NSObject <NSCoding>

@property (nonatomic,strong) NSData *data;
//- (void)encodeWithCoder:(NSCoder *)coder;
//- (id)initWithCoder:(NSCoder *)coder;

@end
