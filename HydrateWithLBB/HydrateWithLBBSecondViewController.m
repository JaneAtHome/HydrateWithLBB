//
//  HydrateWithLBBSecondViewController.m
//  HydrateWithLBB
//
//  Created by Janette Fong on 7/25/14.
//  Copyright (c) 2014 Janette Fong. All rights reserved.
//

#import "HydrateWithLBBSecondViewController.h"

@interface HydrateWithLBBSecondViewController ()

@end

@implementation HydrateWithLBBSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    self.beans = [NSMutableDictionary dictionary];
    // instantiating the bean starts a scan. make sure you have you delegates implemented
    // to receive bean info
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // the next vc grabs the delegate to receive callbacks
    // when the view appears , we want to grab them back.
    self.beanManager.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//the next set of methods are required by the protocol

- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        [self.beanManager startScanningForBeans_error:nil];
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
    }
    
}
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        //[alert show];
        NSLog(@"error connecting");
        return;
    }
    
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
    NSString *beanName = bean.name;
    NSLog(beanName);
}


@end
