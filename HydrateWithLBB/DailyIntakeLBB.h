//
//  DailyIntakeLBB.h
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/29/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyIntakeLBB : NSObject


@property (strong) NSNumber *numOunces; //total ounces drank today
@property (strong) NSDate *todaysDate; //todaysDAte


//special init that makes sure that stored values are taken into acct
-(DailyIntakeLBB*)init;

//increment intake by a specific amount
//for use by manual input
-(void)incrementIntake:(int)cumulativeOunces by:(int)ounces;

//when the sensor sends values, figure out if we should increment intake and by how much
-(void)inputFromSensor:(int)ounces;

#define LASTDRINKDATE        @"storedDrinkDate"
#define LASTDRINKAMOUNT         @"storedDrinkAmount"
#define LASTBOTTLEAMOUNT    @"storedBottleAmount"

@end
