//
//  HydrateWithLBBSecondViewController.m
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/25/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import "HydrateWithLBBSecondViewController.h"
#import "AppMessages.h"
#import "DailyIntakeLBB.h"

@interface HydrateWithLBBSecondViewController ()

@end

@implementation HydrateWithLBBSecondViewController

@synthesize theBean = _theBean;
@synthesize temp = _temp;
@synthesize beans = _beans;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DailyIntakeLBB *sharedDailyIntake = [DailyIntakeLBB sharedDailyIntake];
    
    self.title = @"Details";
    
    self.beans = [NSMutableDictionary dictionary];
   self.theBean = nil;
    // instantiating the bean starts a scan. make sure you have you delegates implemented
    // to receive bean info
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    
    self.beanManager.delegate = self;


    self.incomingLabel.text = @"start";
    [self updateScratch];
    
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // the next vc grabs the delegate to receive callbacks
    // when the view appears , we want to grab them back.
    self.beanManager.delegate = self;
    
    [self.theBean readTemperature];
    self.incomingLabel.text = [self.temp stringValue];

    
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//the next set of methods are required by the protocol

- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        [self.beanManager startScanningForBeans_error:nil];
        self.connectionStatus.text = @"scanning...";
    }
    else if (self.beanManager.state == BeanManagerState_PoweredOff) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Turn on bluetooth to continue" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        //[alert show];
        NSLog(@"Turn on bluetooth to continue");
        return;
    }
}
- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error{
    NSUUID * key = bean.identifier;
    if (![self.beans objectForKey:key]) {
        // New bean
        NSLog(@"BeanManager:didDiscoverBean:error %@", bean);
        [self.beans setObject:bean forKey:key];
        self.connectionStatus.text = @"new bean discovered.";
        
    }
    NSString *beanNames = [[NSString alloc]init];
    
    //LIST out all beans names that we detect
    NSArray *allBeansArray = [self.beans allValues];
    NSArray *allKeys = [self.beans allKeys];
    for (int x = 0; x< allBeansArray.count; x++) {
        PTDBean *aBean = allBeansArray[x];
        beanNames = [beanNames stringByAppendingString:aBean.name];
        beanNames = [beanNames stringByAppendingString:@". "];
    }
    self.allBeansLabel.text = beanNames;
    
    if (error) {
        PTDLog(@"%@", [error localizedDescription]);
        return;
    }
    
    //Connect ONLY to the one called Bottle with the uuid below
   // NSUUID *theUUID = [[NSUUID alloc]initWithUUIDString:@"8604DA9A-0821-6772-44A2-5C777969EF96"];
    NSUUID *theUUID = [[NSUUID alloc]initWithUUIDString:@"61AA0A7B-519D-BE6C-39db-9efd30684c40"];
    self.theBean = [self.beans objectForKey:theUUID];
    self.theBean.delegate = self;
    [self.beanManager connectToBean:self.theBean error:nil];
    
}
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    
    if (error) {
        PTDLog(@"%@", [error localizedDescription]);
       
        return;
    }
    self.connectionStatus.text = @"connected!";
    self.beanNameLabel.text = bean.name;
    
    //PTDBean *theBean = bean;

    [self.beanManager stopScanningForBeans_error:&error];
    if (error) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        //[alert show];
        NSLog(@"stopped scanning for beans");
        return;
    }
    
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDisconnectBean:(PTDBean*)bean error:(NSError*)error{
    NSLog(@"disconnected from bean");
    self.connectionStatus.text = @"disconnected!";
    NSString *beanName = bean.name;
    NSLog(@"%@", beanName);
    
    //now try to reconnect
    [self.beanManager startScanningForBeans_error:nil];
    NSLog(@"tryint to reconnect");
    self.connectionStatus.text = @"trying to reconnect";
}

//stop the scanning for ble peripherals if view disappears
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //stop scanning for peripheral if view disappears
    [self.beanManager stopScanningForBeans_error:nil];
}

-(void)bean:(PTDBean *)bean didUpdateTemperature:(NSNumber *)degrees_celsius
{
    NSLog(@"temperature updated");
    self.temp = [[NSNumber alloc]init];
    self.temp = degrees_celsius;
    self.incomingLabel = self.temp;
    
}

-(void)beanDidUpdateBatteryVoltage:(PTDBean *)bean error:(NSError *)error
{
    NSLog(@"voltage updated");
    //bean.readBatteryVoltage;
    self.incomingLabel.text = [bean.batteryVoltage stringValue];
    
}

-(void)bean:(PTDBean *)bean didUpdateAccelerationAxes:(PTDAcceleration)acceleration
{
    NSLog(@"updated axes");
}


-(void)bean:(PTDBean *)bean didUpdateScratchNumber:(NSNumber *)number withValue:(NSData *)data
{
    NSLog(@"updated scratch data");
    
    NSRange range = {0,1};
    NSData *theByte = [data subdataWithRange:range];
    self.incomingLabel.text = [NSString stringWithFormat:@"%d",((uint8_t *)[theByte bytes])[0]];
    
    [[DailyIntakeLBB sharedDailyIntake] inputFromSensor:((uint8_t *)[theByte bytes])[0]];
    
    
    NSString *str = [NSString stringWithFormat:@"%d",((uint8_t *)[theByte bytes])[0]];
    //NSString* str = [NSString stringWithUTF8String:[theByte bytes]];
    NSString *msg = [NSString stringWithFormat:@"received scratch number:%@ scratch:%@", number, str];
    PTDLog(@"%@", msg);
}


-(void)updateScratch
{
    //get the temperature
    
    int sNumber = 1;
    [self.theBean readScratchBank:sNumber];
    
    [self performSelector:@selector(updateScratch) withObject:self afterDelay:15.0];
    
 
}


@end
