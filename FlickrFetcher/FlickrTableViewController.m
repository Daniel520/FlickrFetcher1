//
//  FlickrTableViewController.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-4-1.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "FlickrTableViewController.h"
#import "FlickrFetcher.h"
#import "PlacePhotosTableViewController.h"

@interface FlickrTableViewController()
@property (nonatomic,strong) NSDictionary *selectPlace;

@end


@implementation FlickrTableViewController
@synthesize selectPlace = _selectPlace;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.cellTitle = @"timezone";
    self.cellSubTitle = FLICKR_PLACE_NAME;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoPlacePhotos"]) {
        [segue.destinationViewController setPlace:self.userSelected];
    }
}

@end
