//
//  displayVC.m
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "displayVC.h"
#import "httpVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"
#import "AMTumblrHud.h"

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

extern BOOL CheckWiFi();

@interface displayVC ()
-(void)updateScreen:(NSArray*)partes;
@end

@implementation displayVC

id yo;

-(void)killBill
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMessage:@"Meter Msg" withMessage:@"Comm Timeout"];
}

-(void)hud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) (_hhud.frame.origin.x),
                                                                  (CGFloat) (_hhud.frame.origin.y), 55, 20)];
        tumblrHUD.hudColor = _hhud.backgroundColor;
        [self.view addSubview:tumblrHUD];
        [tumblrHUD showAnimated:YES];
        mitimer=[NSTimer scheduledTimerWithTimeInterval:10
                                                target:self
                                              selector:@selector(killBill)
                                              userInfo:nil
                                               repeats:NO];
    });
}
-(void)setCallBackNull
{
    [appDelegate.client setMessageHandler:NULL];
}

-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    if(mitimer)
        [mitimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{[tumblrHUD hide];});
    
    if(_respuesta.isOn)
    {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:que
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {


                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
    }
    else
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
}


MQTTMessageHandler displayMsg=^(MQTTMessage *message)
{
   
    LogDebug(@"SettingsMsg %@ %@",message.payload,message.payloadString);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showMessage:@"Settings Answer" withMessage:message.payloadString];
    });
};

MQTTMessageHandler dinfoMsg=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"Info %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *partes=[message.payloadString componentsSeparatedByString:@"!"];
        [yo updateScreen:partes];
    });
};

-(IBAction)displayMeter:(UISegmentedControl*)sender
{
//    if(appDelegate.client)
//        [appDelegate.client setMessageHandler:dinfoMsg];
//    mis=[NSString stringWithFormat:@"settings?password=zipo&meter=%d",(int)sender.selectedSegmentIndex];
//    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:displayMsg];
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&meter=%d",(int)sender.selectedSegmentIndex];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
    [self hud];

}

-(IBAction)dispTime:(UISlider*)sender
{
    _inter.text=[NSString stringWithFormat:@"%d",(int)sender.value];

}
-(IBAction)intervalSelect:(id)sender
{
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:displayMsg];
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&meter=%d&int=%d",(int)_dispMeter.selectedSegmentIndex,(int)_interval.value];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
    [self hud];

}

-(IBAction)onOff:(UISwitch*)sender
{
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:displayMsg];
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&st=%d",sender.isOn];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
    [self hud];

}

-(IBAction)displayMode:(UISegmentedControl*)sender
{
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:displayMsg];
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&mode=%d",(int)sender.selectedSegmentIndex];
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];


}


-(void)workingIcon
{
    UIImage *licon;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //   NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    _bffIcon.image=licon;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    yo =self;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _dispMeter.tintColor=[UIColor colorWithRed:233.0/256.0 green:96.0/256.0 blue:187.0/256.0 alpha:1.0];
    _dispMode.tintColor=[UIColor colorWithRed:233.0/256.0 green:96.0/256.0 blue:187.0/256.0 alpha:1.0];
}

-(void)viewDidAppear:(BOOL)animated
{
    yo=self;
    [super viewDidAppear:animated];
    [self workingIcon];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:dinfoMsg];
    
    mis=[NSString stringWithFormat:@"settings?password=zipo&meter=0"];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
    [self hud];

//    {
//       // NSLog(@"Setings %@",lanswer);
//        //set different controls to received data
//        NSArray *partes=[lanswer componentsSeparatedByString:@"!"];
//        [self updateScreen:partes];
//    }

}
-(void)updateScreen:(NSArray*)partes
{
    if(mitimer)
        [mitimer invalidate];
      dispatch_async(dispatch_get_main_queue(), ^{
          [tumblrHUD hide];
      });

    if(partes.count>=9)
    {
        _dispMeter.selectedSegmentIndex=[partes[0] integerValue];
        _dispMode.selectedSegmentIndex=[partes[1] integerValue];
        _onOff.on=[partes[2] integerValue];
        _inter.text=partes[8];
        _interval.value=[partes[8] floatValue];
        NSLog(@"Meter %d Mode %d",[partes[0] integerValue],[partes[1] integerValue]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
