//
//  HydrateWithLBBFirstViewController.m
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/25/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import "HydrateWithLBBFirstViewController.h"
#import "DailyIntakeLBB.h"

@interface HydrateWithLBBFirstViewController ()

//@property (strong) DailyIntakeLBB *dailyIntake;
@end

@implementation HydrateWithLBBFirstViewController

//@synthesize dailyIntake = _dailyIntake;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Janette's Water Log";
    
   // DailyIntakeLBB *sharedDailyIntake = [DailyIntakeLBB sharedDailyIntake];
    
    //set and update the todaysDate label
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle]; //output: Jan 2, 1981
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle]; //suppress time
    self.dateLabel.text = [dateFormatter stringFromDate:currentTime];
    [self updateTime];
    
    //todo:load the stored intake into the label
    //self.dailyIntake = [[DailyIntakeLBB alloc]init];
    //self.drinkAmtLabel.text = [self.dailyIntake.numOunces stringValue];
    self.drinkAmtLabel.text = [[[DailyIntakeLBB sharedDailyIntake] numOunces] stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addWaterPress:(UIButton *)sender {
    NSString *buttonTitle = sender.currentTitle;
    [[DailyIntakeLBB sharedDailyIntake] incrementIntake:[self.drinkAmtLabel.text intValue]  by:[buttonTitle intValue]];
    self.drinkAmtLabel.text = [[[DailyIntakeLBB sharedDailyIntake] numOunces] stringValue];
}

-(void)updateTime
{
    //get the current time
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle]; //output: suppress date
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle]; //output 3:30pm
    
    self.dateLabel.text = [dateFormatter stringFromDate:currentTime];
    
    [self performSelector:@selector(updateTime) withObject:self afterDelay:1.0];
}


@end
