//
//  FatherTableViewController.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-3-31.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "FatherTableViewController.h"
#import "FlickrFetcher.h"

@implementation FatherTableViewController

@synthesize refreshButton = _refreshButton;
@synthesize photos = _photos;
@synthesize cellTitle = _cellTitle;
@synthesize cellSubTitle = _cellSubTitle;
@synthesize userSelected = _userSelected;

- (void)loadPhotoData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            self.navigationItem.rightBarButtonItem = self.refreshButton;
        });
    });
    
}

- (IBAction)refreshData:(id)sender
{
    [self loadPhotoData];
}


- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPhotoData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.refreshButton = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *photoTitle = [photo objectForKey:self.cellTitle];
    NSString *photoOwner = [photo objectForKey:self.cellSubTitle];
    if ([photoTitle isEqualToString:@""] || photoTitle == nil) {
        cell.textLabel.text = @"Unknow";
    }else{
        cell.textLabel.text = photoTitle;
    }
    
    if ([photoOwner isEqualToString:@""] || photoOwner == nil) {
        cell.detailTextLabel.text = @"Unknow";
    }else{
        cell.detailTextLabel.text = photoOwner;
    }
    

    return cell;
}

#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.userSelected = [self.photos objectAtIndex:indexPath.row];
    return indexPath;
}

@end
