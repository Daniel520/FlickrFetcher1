//
//  imageViewController.h
//  FlickrFetcher
//
//  Created by Daniel yu on 12-4-2.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlkrImageViewController : UIViewController <UISplitViewControllerDelegate>
#define RECENT_PHOTO_DICTIONARY @"recentPhoto"
#define PHOTO_CACHE_ARRAY @"photoCacheArray"
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic,strong) NSDictionary *selectPhoto;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIBarButtonItem *splitViewBarButtonItem;

//execute this method if it's from the ipad SplitViewController and want to update the detailViewController to display a different photo
- (void)photoDisplayInDetailView;
@end
