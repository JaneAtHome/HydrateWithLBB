//
//  DailyIntakeLBB.m
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/29/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import "DailyIntakeLBB.h"

@interface DailyIntakeLBB()
@property (strong) NSNumber *bottleAmount; //last known amount of water in the bottle
@property (strong) NSUserDefaults *defaults;
@end

@implementation DailyIntakeLBB

@synthesize bottleAmount = _bottleAmount;
@synthesize defaults = _defaults;
@synthesize someProperty = _someProperty;
@synthesize numOunces = _numOunces;
@synthesize todaysDate = _todaysDate;

+(id)sharedDailyIntake
{
    static DailyIntakeLBB *sharedMyDailyIntake = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{sharedMyDailyIntake = [[self alloc]initPrivate]; });
    return sharedMyDailyIntake;
}

//no one should call init
-(id)init
{
    [NSException raise:@"Singleton" format:@"use +[DailyIntakeLBB] sharedDailyIntake"];
    return nil;
}
/*
specialized init:
check to see if NSUserDefaults has key=LASTDRINKDATE

if yes:
check to see if LASTDRINKDATE == today
if yes - init with the LASTDRINKDATE and LASTDRINKAMOUNT
if no - set LASTDRINKDATE = today, and LASTDRINKAMOUNT = 0


if no,

create NSUSerDefaults fields for

-LASTDRINKDATE = current Date
-LASTDRINKAMOUNT = 0


*/

//secret designated initializer
-(DailyIntakeLBB*)initPrivate
{
    self = [super init];
    
    if (self) {
       
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSDate *storedDate = [self.defaults objectForKey:LASTDRINKDATE];
    
    
    if (storedDate != nil) {
        //NSLog(@"stored date is not nil");
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle]; //suppress time
        NSString *storedDateString = [formatter stringFromDate:storedDate];
        NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
        
        NSLog(@"%@", storedDateString);
        
        if ([storedDateString isEqualToString:currentDateString]) {
            self.todaysDate = storedDate;
            self.numOunces = [self.defaults objectForKey:LASTDRINKAMOUNT];
            self.bottleAmount = [self.defaults objectForKey:LASTBOTTLEAMOUNT];
            if (self.numOunces == nil) {
                self.numOunces = [NSNumber numberWithInt:0];
            }
            if(self.bottleAmount == nil)
            {
                //leave it as nil
                NSLog(@"bottle is nil");
            }
            
            //NSLog(self.numOunces);
            //NSLog(@"stored date is equal to todays date");
        }else
        {
            self.todaysDate = [NSDate date];
            self.numOunces = [NSNumber numberWithInt:0];
            //does it make sense to init the bottle amount to nil??
            self.bottleAmount = nil;
            [self.defaults setObject:self.todaysDate forKey:LASTDRINKDATE];
            [self.defaults setObject:self.numOunces forKey:LASTDRINKAMOUNT];
            //[self.defaults setObject:self.bottleAmount forKey:LASTBOTTLEAMOUNT];
            //NSLog(@"stored date is not today");
        }
    } else
    {
        //NSLog(@"stored date was NIL");
        self.todaysDate = [NSDate date];
        self.numOunces = [NSNumber numberWithInt:0];
        self.bottleAmount = nil;
        [self.defaults setObject:self.todaysDate forKey:LASTDRINKDATE];
        [self.defaults setObject:self.numOunces forKey:LASTDRINKAMOUNT];
        //[self.defaults setObject:self.bottleAmount forKey:LASTBOTTLEAMOUNT];
    }
    }
    return self;
}


/*
 This method takes the passed number of ounces and add to the passed cumulative ounces, saves the data back to User Defaults, and sets self.numOunces to current amount.
 */

-(void)incrementIntake:(int)cumulativeOunces by:(int)ounces
{
    
    int totalOunces = cumulativeOunces + ounces;
    
    //store the value
    NSNumber *totalOuncesNumber = [NSNumber numberWithInt:totalOunces];
    [self.defaults setValue:totalOuncesNumber forKey:LASTDRINKAMOUNT];
    [self.defaults synchronize];
    
    self.numOunces = totalOuncesNumber;
    
    
    
    
}

/*
 This method takes an int from the sensor's scratch data and determines whether or not to increment the drink amount.
 
 The expectation is that the int = current number of ounces of water in the bottle
 
 If the current ounces is fewer than they were before, then take the difference and add to the cumulative ounces
 
 If the current ounces is more than they were before, then ignore the difference
 */

-(NSNumber*)inputFromSensor:(int)ounces
{
    NSLog(@"input from sensor");
    NSNumber *returnNumber;
    
    if (self.bottleAmount == nil) {
        //set the bottle amount to ounces
        self.bottleAmount = [NSNumber numberWithInt:ounces];
        [self.defaults setObject:self.bottleAmount forKey:LASTBOTTLEAMOUNT];

        returnNumber = [NSNumber numberWithLong:0];
    }
    else
    {
        if (ounces < [self.bottleAmount intValue]) {
            int drank = [self.bottleAmount intValue] - ounces;
            if (drank >= 0 && drank <=24) {
                self.numOunces = [NSNumber numberWithInt:[self.numOunces intValue] + drank];
                [self.defaults setObject:self.numOunces forKey:LASTDRINKAMOUNT];
                self.bottleAmount = [NSNumber numberWithInt:ounces];
                [self.defaults setObject:self.bottleAmount forKey:LASTBOTTLEAMOUNT];
                returnNumber = [NSNumber numberWithLong:1];
              
            }
            else if(drank < 0)
            {
                //ERROR!!
                NSLog(@"oops. you drank more than possible");
                returnNumber = [NSNumber numberWithLong:0];
                
            } else
            {
                NSLog(@"oops you couldnt have drank ");
                NSLog(@"%d", drank);
                returnNumber = [NSNumber numberWithLong:0];
            }
        } else if (ounces > [self.bottleAmount intValue] && ounces <= 24)
        {
            //for now assumes that sensors are always right and that this means the user added more water to the bottle
            self.bottleAmount = [NSNumber numberWithInt:ounces];
            [self.defaults setObject:self.bottleAmount forKey:LASTBOTTLEAMOUNT];
            returnNumber = [NSNumber numberWithLong:0];
            
        } else if(ounces > 24)
        {
            NSLog(@"something else!");
            returnNumber = [NSNumber numberWithLong:0];
        }
        else
        {
            //this means ounces = bottleAmount
            NSLog(@"user did not drink or fill up the bottle");
            returnNumber = [NSNumber numberWithLong:0];
        }
    }
    //now update defaults!
    [self.defaults synchronize];
    NSLog(@"BOTTLE AMT %d", [self.bottleAmount intValue]);
    return returnNumber;
    
    
}





@end
