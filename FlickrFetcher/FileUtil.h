//
//  FileUtil.h
//  FlickrFetcher
//
//  Created by Daniel yu on 12-5-12.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

//directory mean the path save in which directory,so the entire path should be the path of directory + /path
+(BOOL)saveDataToLocal:(NSData *)data ForSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path withFileName:(NSString *)fileName;

+(NSData *)getDataFromLocalForSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path;

+(NSNumber *)getFileSizeFromSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path;

+(void)removeFileFromSearchDirectory:(NSSearchPathDirectory)directory withPath:(NSString *)path;
@end
