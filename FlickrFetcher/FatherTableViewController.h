//
//  FatherTableViewController.h
//  FlickrFetcher
//
//  Created by Daniel yu on 12-3-31.
//  Copyright (c) 2012年 广工. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FatherTableViewController : UITableViewController

@property (strong,nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic,strong) NSDictionary *userSelected;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) NSString *cellTitle;
@property (nonatomic,strong) NSString *cellSubTitle;
- (void)loadPhotoData;
- (IBAction)refreshData:(id)sender;

@end
