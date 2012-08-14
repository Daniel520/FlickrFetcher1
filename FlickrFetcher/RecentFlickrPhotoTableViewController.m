//
//  RecentFlickrPhotoTableViewController.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-4-8.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "RecentFlickrPhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "FlkrImageViewController.h"

@implementation RecentFlickrPhotoTableViewController

- (void) loadPhotoData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *recentPhotoArray = [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTO_DICTIONARY];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = recentPhotoArray;
            self.navigationItem.rightBarButtonItem = self.refreshButton;
        });
    });
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    self.cellTitle = FLICKR_PHOTO_TITLE;
    self.cellSubTitle = FLICKR_PHOTO_OWNER;
}

//- (IBAction)refresh:(id)sender {
//    [self loadPhotoData];
//    self.cellTitle = FLICKR_PHOTO_TITLE;
//    self.cellSubTitle = FLICKR_PHOTO_OWNER;
//}

- (IBAction)clearHistroy:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RECENT_PHOTO_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadPhotoData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
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
