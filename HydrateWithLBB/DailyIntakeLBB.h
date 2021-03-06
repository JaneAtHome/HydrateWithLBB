//
//  DailyIntakeLBB.h
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/29/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyIntakeLBB : NSObject {
    NSString *someProperty;
}


@property (strong) NSNumber *numOunces; //total ounces drank today
@property (strong) NSDate *todaysDate; //todaysDAte

@property (nonatomic, retain) NSString *someProperty;

//necessary for singleton status!
+(id)sharedDailyIntake;

//special init that makes sure that stored values are taken into acct
-(DailyIntakeLBB*)init;

//increment intake by a specific amount
//for use by manual input
-(void)incrementIntake:(int)cumulativeOunces by:(int)ounces;

//when the sensor sends values, figure out if we should increment intake and by how much
-(NSNumber*)inputFromSensor:(int)ounces;

#define LASTDRINKDATE        @"storedDrinkDate"
#define LASTDRINKAMOUNT         @"storedDrinkAmount"
#define LASTBOTTLEAMOUNT    @"storedBottleAmount"

@end
