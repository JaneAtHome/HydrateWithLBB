//
//  MyTableViewController.h
//  HydrateWithLBB
//
//  Created by Janette Fong on 8/7/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MyTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *drinkAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *drinkDateLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
