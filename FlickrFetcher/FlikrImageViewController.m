//
//  imageViewController.m
//  FlickrFetcher
//
//  Created by Daniel yu on 12-4-2.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import "FlkrImageViewController.h"
#import "FlickrFetcher.h"
#import "FlkrTabBarViewController.h"
#import "FileUtil.h"

@interface FlkrImageViewController() <UIScrollViewDelegate>
@property (nonatomic,strong) NSData *photoData;
@property (nonatomic,strong) UIBarButtonItem *aCacheButton;
@end

@implementation FlkrImageViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize refreshButton = _refreshButton;
@synthesize selectPhoto = _selectPhoto;
@synthesize photoData = _photoData;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize aCacheButton = _aCacheButton;


//A method for change the image 's size and return a new image with that size.
//- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height image:(UIImage *)image
//{
//    CGImageRef imageRef = image.CGImage;
//    CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
//    
//    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
//    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
//    UIImage *result = [UIImage imageWithCGImage:ref];
//    CGContextRelease(bitmap);
//    CGImageRelease(ref);
//    return result;
//}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem && toolbarItems.count > 2) [toolbarItems removeObjectAtIndex:0];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = [toolbarItems copy];
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

//mark the recent photo to NSUserDefaults
- (void) setRecentPhoto
{
    NSArray *recentPhotoArray = [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTO_DICTIONARY];
    NSMutableArray *mutableRecentPhotoArray = [recentPhotoArray mutableCopy];
    if (!mutableRecentPhotoArray)  mutableRecentPhotoArray = [[NSMutableArray alloc] init]; 
    
    for (int i = 0;i < mutableRecentPhotoArray.count ; i++) {
        NSDictionary *photoInfo = [mutableRecentPhotoArray objectAtIndex:i];
        if ([[photoInfo objectForKey:FLICKR_PHOTO_ID] isEqualToString:[self.selectPhoto objectForKey:FLICKR_PHOTO_ID]]) {
            [mutableRecentPhotoArray removeObjectAtIndex:i];
        }
    }
    
    [mutableRecentPhotoArray insertObject:self.selectPhoto atIndex:0];
    if (mutableRecentPhotoArray.count > 20) {
        [mutableRecentPhotoArray removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecentPhotoArray forKey:RECENT_PHOTO_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//setup the photo's size to fit the screen to display to user 
- (void)setup
{
    if (self.photoData) {
        [self setRecentPhoto];
    }
    UIImage *photoImage = [[UIImage alloc] initWithData:self.photoData];
    
    self.imageView.image = photoImage;
    
    self.imageView.frame = CGRectMake(0, 0, photoImage.size.width, photoImage.size.height);
    float scale = 0;
    if (photoImage.size.width > photoImage.size.height ){
        scale = self.scrollView.frame.size.width / photoImage.size.width;
    }else {
        scale = self.scrollView.frame.size.height / photoImage.size.height;
    }
    self.scrollView.delegate = self;
    self.scrollView.zoomScale = scale;
    self.scrollView.contentSize = CGSizeMake(photoImage.size.width * scale, photoImage.size.height * scale);
    [self.imageView setCenter:CGPointMake(self.scrollView.bounds.size.width/ 2, self.scrollView.bounds.size.height / 2)];
    
    self.navigationItem.title = [self.selectPhoto objectForKey:FLICKR_PHOTO_TITLE];
}

- (void)setToolbarRefreshButton:(UIBarButtonItem *)refreshButton
{
    if (self.toolbar.items) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (toolbarItems.count > 2) {
            [toolbarItems removeObjectAtIndex:2];
            [toolbarItems insertObject:refreshButton atIndex:2];
        }else{
            [toolbarItems removeObjectAtIndex:1];
            [toolbarItems insertObject:refreshButton atIndex:1];
        }
        self.toolbar.items = [toolbarItems copy];
    }
}

- (void)savePhotoDataToLocal:(NSData *)photoData inPath:(NSString *)path
{
    long fileSize = [[FileUtil getFileSizeFromSearchDirectory:NSDocumentDirectory withPath:FLICKR_LOCAL_DIRECTORY_NAME] longValue];
    
    //use the NSUserDefault to save the sequence of the photoData Cache.
    NSArray *photoCacheArray = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTO_CACHE_ARRAY];
    NSMutableArray *mutablePhotoCacheArray = [photoCacheArray mutableCopy];
    if (!mutablePhotoCacheArray) {
        mutablePhotoCacheArray = [[NSMutableArray alloc] init];
    }
    
    long dataSize = photoData.length / 1024; 
    
    //if fileSize > 10M delete the oldest photo cache file
    while (fileSize + dataSize > 10240) {
        
        NSString *photoID = [mutablePhotoCacheArray objectAtIndex:0];
        //delete the photoID in NSUserDefaults
        [mutablePhotoCacheArray removeObjectAtIndex:0];
        
        //delete the photoData in local file system
        [FileUtil removeFileFromSearchDirectory:NSDocumentDirectory withPath:photoID];
        
        fileSize = [[FileUtil getFileSizeFromSearchDirectory:NSDocumentDirectory withPath:FLICKR_LOCAL_DIRECTORY_NAME] longValue];
    }
    //save the new photo to local file system
    if ([FileUtil saveDataToLocal:photoData ForSearchDirectory:NSDocumentDirectory withPath:FLICKR_LOCAL_DIRECTORY_NAME withFileName:path]) {
        
        //if the photoID has been save to local it will not execute this method,so no need to check if the photoID 
        //existed in NSUserDefaults or not
        NSUInteger index = [mutablePhotoCacheArray indexOfObject:[self.selectPhoto objectForKey:FLICKR_PHOTO_ID]];
        
        //if photoID existed in NSUserDefault,move it to the latest one of the array,else insert it to the array
        if (index == NSNotFound) {
            [mutablePhotoCacheArray addObject:[self.selectPhoto objectForKey:FLICKR_PHOTO_ID]];
        }else{
            [mutablePhotoCacheArray removeObject:[self.selectPhoto objectForKey:FLICKR_PHOTO_ID]];
            [mutablePhotoCacheArray addObject:[self.selectPhoto objectForKey:FLICKR_PHOTO_ID]];
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:mutablePhotoCacheArray forKey:PHOTO_CACHE_ARRAY];
        
    }
    
    //save the NSUserDefaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//initialize the image 's data
- (void)loadPhotoData:(BOOL)refreshData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    //for iphone Device use below command to set the refresh button to spinner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    //for ipad Device use below command to set the splitViewController detail toolbar refresh button to a spinner
    [self setToolbarRefreshButton:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    
    NSString *path = [self.selectPhoto objectForKey:FLICKR_PHOTO_ID];
    
    //check if the photoData existed in local file system
    NSData *photoData = [FileUtil getDataFromLocalForSearchDirectory:NSDocumentDirectory withPath:[FLICKR_LOCAL_DIRECTORY_NAME stringByAppendingFormat:@"/%@", path]];
    
    if (photoData && !refreshData) {
        self.photoData = photoData;
        [self setup];
        //for iphone Device use below command to set the refresh button to a refresh button
        self.navigationItem.rightBarButtonItem = self.refreshButton;
        
    }else{
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("photo downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *url = [FlickrFetcher urlForPhoto:self.selectPhoto format:FlickrPhotoFormatOriginal];
            NSData *photoData = [[NSData alloc] initWithContentsOfURL:url];
            
            if (photoData) {
                //save the photoData to local file system
                [self savePhotoDataToLocal:photoData inPath:path];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoData = photoData;
                [self setup];
                //for iphone Device use below command to set the refresh button to a refresh button
                self.navigationItem.rightBarButtonItem = self.refreshButton;
                
                //for ipad Device use below command to set the splitViewController detail toolbar refresh button
                [self setToolbarRefreshButton:self.refreshButton];
            });
        });
    }
    
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarButtonItem != splitViewBarButtonItem){
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

//Just execute this method for ipad.
- (void)photoDisplayInDetailView
{
    //[self.imageView setNeedsDisplay];
    [self loadPhotoData:NO];
}

- (void)setSelectPhoto:(NSDictionary *)selectPhoto
{
    if(_selectPhoto != selectPhoto){
        _selectPhoto = selectPhoto;
        [self.imageView setNeedsDisplay];
        //[self loadPhotoData:NO];
        
        //set the imageView to nil first for every time display the image view.
        //this is for the splitViewController mode in ipad to reset the imageView.
        //for iphone, imageView will not change the image url when it displaying.
        self.imageView.image = nil;
    }
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setRefreshButton:nil];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.selectPhoto) {
        [self loadPhotoData:NO];
    }
    
}

//refresh the data of this image
- (IBAction)refresh:(id)sender {
    [self loadPhotoData:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

//reset the center point when the screen rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)?
    (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)?
    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
                              self.scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark UIScrollViewDelegate method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    UIImageView *imageView = (UIImageView *)view;
    self.scrollView.contentSize = CGSizeMake(imageView.image.size.width * scale,imageView.image.size.height * scale);
//    if (scale < 1.0) {
//        UIImageView *imageView = [scrollView.subviews lastObject];
//        [imageView setCenter:CGPointMake(scrollView.frame.size.width / 2, scrollView.frame.size.height /2)];
//        //[imageView setNeedsDisplay];
//    }
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    view.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


#pragma mark UISplitViewControllerDelegate method
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return [self.splitViewController.viewControllers lastObject] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"menu";
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

@end
