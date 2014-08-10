//
//  HydrateWithLBBFirstViewController.h
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/25/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTDBeanManager.h"

@interface HydrateWithLBBFirstViewController : UIViewController <PTDBeanManagerDelegate, PTDBeanDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *drinkAmtLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastDataUpdateLabel;


//------- Bean stuff -------

@property PTDBeanManager *beanManager;
@property (nonatomic, strong) NSMutableDictionary *beans; //all beans returned from scan
@property PTDBean *theBean; //THE bean I want
@property NSNumber *temp; //temperature?

@end
