//
//  DailyDrinkSummary.h
//  HydrateWithLBB
//
//  Created by Janette Fong on 8/7/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DailyDrinkSummary : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * amount;

@end
