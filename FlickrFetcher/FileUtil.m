//
//  FileUtil.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-5-12.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

//directory mean the path save in which directory,so the entire path should be the path of directory + /path
+(BOOL)saveDataToLocal:(NSData *)data ForSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path withFileName:(NSString *)fileName
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    }
    url = [url URLByAppendingPathComponent:fileName];
    return [data writeToURL:url atomically:YES];
}

+(NSData *)getDataFromLocalForSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:path];
    //NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:&error];
    return data;
}

+(NSNumber *)getFileSizeFromSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask] lastObject];
    if (path) {
        url = [url URLByAppendingPathComponent:path];
    }
    NSError *error = nil;
    NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:&error];
    
    return [attribute objectForKey:NSFileSize];
}

+(void)removeFileFromSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:path];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
}


@end
