//
//  PlacePhotosTableViewController.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-4-1.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "PlacePhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "FlkrImageViewController.h"

@implementation PlacePhotosTableViewController

@synthesize place = _place;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.cellTitle = FLICKR_PHOTO_TITLE;
    self.cellSubTitle = FLICKR_PHOTO_OWNER;
}

- (void)setPlace:(NSDictionary *)place
{
    if (_place != place) {
        _place = place;
        self.place = _place;  
    }
}

- (void)loadPhotoData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            self.navigationItem.rightBarButtonItem = self.refreshButton;
        });
    });
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showPhotos"]){
        [segue.destinationViewController setSelectPhoto:self.userSelected];
    }
}

#pragma mark UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (detailVC) {
        if ([detailVC isKindOfClass:[FlkrImageViewController class]]) {
            FlkrImageViewController *imageDetailVC = detailVC;
            [imageDetailVC setSelectPhoto:self.userSelected];
            [imageDetailVC photoDisplayInDetailView];
        }
    }
}

@end
