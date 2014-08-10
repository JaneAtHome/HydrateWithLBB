//
//  HydrateWithLBBFirstViewController.m
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/25/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import "HydrateWithLBBFirstViewController.h"
#import "DailyIntakeLBB.h"
#import "PTDBean+Protected.h"
#import "PTDBeanManager+Protected.h"

@interface HydrateWithLBBFirstViewController ()
//storing all bean stuff
@property (strong, nonatomic) CBPeripheral *theBeanPeripheral;
@property   (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation HydrateWithLBBFirstViewController

@synthesize theBean = _theBean;
@synthesize temp = _temp;
@synthesize beans = _beans;

static void *singletonModelKVOContext = & singletonModelKVOContext;

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
    
    
    //----------------init the bean connection and stuff---------------------------
    self.beans = [NSMutableDictionary dictionary];
    self.theBean = nil;
    // instantiating the bean starts a scan. make sure you have you delegates implemented
    // to receive bean info
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];

    self.beanManager.delegate = self;
    self.lastDataUpdateLabel.text = @"starting";
    [self updateScratch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DailyIntakeLBB sharedDailyIntake]addObserver:self forKeyPath:@"numOunces" options:0 context:singletonModelKVOContext];

    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == singletonModelKVOContext) {
        
        [self updateViewsFromModel];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)updateViewsFromModel
{
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

-(void)updateScratch
{
    //get the temperature
    
    int sNumber = 1;
    [self.theBean readScratchBank:sNumber];
    
    [self performSelector:@selector(updateScratch) withObject:self afterDelay:15.0];
    
    
}

-(void)dealloc
{
    [[DailyIntakeLBB sharedDailyIntake] removeObserver:self forKeyPath:@"numOunces" context:singletonModelKVOContext];
}

//the next set of methods are required by the protocol

- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        [self.beanManager startScanningForBeans_error:nil];
        self.connectionStatusLabel.text = @"Connection Status:scanning...";
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
        self.connectionStatusLabel.text = @"Connection Status: new bean!";
        
    }
    NSString *beanNames = [[NSString alloc]init];
    
    //LIST out all beans names that we detect
    NSArray *allBeansArray = [self.beans allValues];
    for (int x = 0; x< allBeansArray.count; x++) {
        PTDBean *aBean = allBeansArray[x];
        beanNames = [beanNames stringByAppendingString:aBean.name];
        beanNames = [beanNames stringByAppendingString:@". "];
    }
    
    if (error) {
        PTDLog(@"%@", [error localizedDescription]);
        return;
    }
    
    //Connect ONLY to the one called Bottle with the uuid below
    //NSUUID *theUUID = [[NSUUID alloc]initWithUUIDString:@"8604DA9A-0821-6772-44A2-5C777969EF96"];
    //NSUUID *theUUID = [[NSUUID alloc]initWithUUIDString:@"61AA0A7B-519D-BE6C-39db-9efd30684c40"];
    NSUUID *theUUID = [[NSUUID alloc]initWithUUIDString:@"0d92f61c-e0b8-d3fb-99b4-7f5d5f04e6bb"];
    self.theBean = [self.beans objectForKey:theUUID];
    self.theBean.delegate = self;
    [self.beanManager connectToBean:self.theBean error:nil];
    
    //get the peripheral (that is already connected)
    self.theBeanPeripheral = [self.theBean peripheral];
    
    
}
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    
    if (error) {
        PTDLog(@"%@", [error localizedDescription]);
        
        return;
    }
    self.connectionStatusLabel.text = @"Connection Status: connected!";
    
    //PTDBean *theBean = bean;
    
    [self.beanManager stopScanningForBeans_error:&error];
    if (error) {
        
        NSLog(@"stopped scanning for beans");
        return;
    }
    
    
    
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDisconnectBean:(PTDBean*)bean error:(NSError*)error{
    NSLog(@"disconnected from bean");
    self.connectionStatusLabel.text = @"disconnected!";
    NSString *beanName = bean.name;
    NSLog(@"%@", beanName);
    
    //now try to reconnect
    [self.beanManager startScanningForBeans_error:nil];
    NSLog(@"tryint to reconnect");
    self.connectionStatusLabel.text = @"trying to reconnect";
}

//stop the scanning for ble peripherals if view disappears
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //stop scanning for peripheral if view disappears
    [self.beanManager stopScanningForBeans_error:nil];
}



-(void)beanDidUpdateBatteryVoltage:(PTDBean *)bean error:(NSError *)error
{
    NSLog(@"voltage updated");
    //bean.readBatteryVoltage;
    self.lastDataUpdateLabel.text = [bean.batteryVoltage stringValue];
    
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
    self.lastDataUpdateLabel.text = [NSString stringWithFormat:@"%d",((uint8_t *)[theByte bytes])[0]];
    
    NSNumber *v = [[DailyIntakeLBB sharedDailyIntake] inputFromSensor:((uint8_t *)[theByte bytes])[0]];
    
    [self.theBean setScratchNumber:2 withValue:[NSData dataWithBytes:&v length:1]];
    
    
    
    NSString *str = [NSString stringWithFormat:@"%d",((uint8_t *)[theByte bytes])[0]];
    //NSString* str = [NSString stringWithUTF8String:[theByte bytes]];
    NSString *msg = [NSString stringWithFormat:@"received scratch number:%@ scratch:%@", number, str];
    PTDLog(@"%@", msg);
    
}



@end
