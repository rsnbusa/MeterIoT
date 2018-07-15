//
//  infoVC.m
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "infoVC.h"
#import "httpVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


@interface infoVC ()
-(void)updateScreen:(NSArray*)partes;
@end

@implementation infoVC

extern BOOL CheckWiFi();

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
    dispatch_async(dispatch_get_main_queue(), ^{[tumblrHUD hide]; });

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


MQTTMessageHandler infoMsg=^(MQTTMessage *message)
{
    //   [yo setCallBackNull];
    LogDebug(@"SettingsMsg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showMessage:@"Settings Answer" withMessage:message.payloadString];
    });
};

MQTTMessageHandler infosettingsMsg=^(MQTTMessage *message)
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
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:infosettingsMsg];
    mis=[NSString stringWithFormat:@"settings?password=zipo&meter=%d",(int)_dispMeter.selectedSegmentIndex];
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];

}

-(IBAction)update:(id)sender
{
    if([_meterid.text isEqualToString:@""] || [_startkwh.text isEqualToString:@""])
        return;
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:infosettingsMsg];
    [self hud];
    mis=[NSString stringWithFormat:@"internal?password=zipo&meter=%d&mmmm=%@&born=%@",(int)_dispMeter.selectedSegmentIndex,_meterid.text,_startkwh.text];
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
    yo=self;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _dispMeter.tintColor=[UIColor colorWithRed:251.0/256.0 green:199.0/256.0 blue:0.0/256.0 alpha:1.0];
    }


-(void)updateScreen:(NSArray*)partes
{
    if(mitimer)
        [mitimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{[tumblrHUD hide]; });

    if(partes.count>=9)
    {
        _dispMeter.selectedSegmentIndex=[partes[0] integerValue];
        _meterid.text=partes[3];
        _startkwh.text=partes[4];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    yo=self;
    [super viewDidAppear:animated];
    [self workingIcon];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:infosettingsMsg];
    [self hud];
    mis=[NSString stringWithFormat:@"settings?password=zipo&meter=%d",(int)_dispMeter.selectedSegmentIndex];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
   
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
