//
//  HydrateWithLBBSecondViewController.h
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/25/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTDBeanManager.h"

@interface HydrateWithLBBSecondViewController : UIViewController <PTDBeanManagerDelegate, PTDBeanDelegate>

@property PTDBeanManager *beanManager;
// all the beans returned from a scan
@property (nonatomic, strong) NSMutableDictionary *beans;
@property PTDBean *theBean; //THE bean I want
@property NSNumber *temp; //temperature?

@property (weak, nonatomic) IBOutlet UILabel *beanNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *allBeansLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatus;
@property (weak, nonatomic) IBOutlet UILabel *incomingLabel;



@end
