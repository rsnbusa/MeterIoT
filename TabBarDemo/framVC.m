//
//  framVC.m
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "framVC.h"
#import "httpVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"
#import "AMTumblrHud.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

extern BOOL CheckWiFi();

@interface framVC ()

@end

@implementation framVC

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

MQTTMessageHandler framMsg=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"FramMsg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
    [yo showMessage:@"Meter Msg" withMessage:message.payloadString];
    });
};

-(void)updateit:(NSString*)lanswer
{
    if(mitimer)
        [mitimer invalidate];
        NSArray *partes=[lanswer componentsSeparatedByString:@"!"];
        [self updateScreen:partes];
    }

MQTTMessageHandler framInfo=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"FramMsg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
    [yo updateit:message.payloadString];
    });
};


-(IBAction)formatAll:(UISegmentedControl*)sender
{
    if(sender.selectedSegmentIndex==3)
        return;
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:framMsg];
    if(sender.selectedSegmentIndex==0)
    {
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&ALL=y"];
        [self hud];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
        return;
    }
    else{
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&full=y",(int)sender.selectedSegmentIndex-1];
        [self hud];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
        return;
    }
    
}

-(IBAction)formatSingle:(id)sender
{
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:framMsg];
    LogDebug(@"Mes %@ Dia %@ Hora %@",_mes.text,_dia.text,_hora.text);
    if(![_hora.text isEqualToString:@""])
    {// Hour format
        //must have day and month
        if([_dia.text isEqualToString:@""])
            return; //Give error message
        if([_mes.text isEqualToString:@""])
            return ;
        
        [self hud];
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&HOUR=%@&month=%@&mday=%@",(int)_formatMeter.selectedSegmentIndex,_hora.text,_mes.text,_dia.text];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
        return;
    }
    else
        if(![_dia.text isEqualToString:@""])
        {
            // Day format
            if([_mes.text isEqualToString:@""])
                return ;
            [self hud];
            mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&DAY=%@&month=%@",(int)_formatMeter.selectedSegmentIndex,_dia.text,_mes.text];
            [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
            return;
        }
        else
            if(![_mes.text isEqualToString:@""])
            { //Month format
                [self hud];
                mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&MON=%@",(int)_formatMeter.selectedSegmentIndex,_mes.text];
                [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
            }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    yo=self;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _formatAll.tintColor=[UIColor colorWithRed:152.0/256.0 green:192.0/256.0 blue:0.0/256.0 alpha:1.0];
    _formatMeter.tintColor=[UIColor colorWithRed:152.0/256.0 green:192.0/256.0 blue:0.0/256.0 alpha:1.0];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    yo=self;
    [super viewDidAppear:animated];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:framInfo];
    mis=[NSString stringWithFormat:@"settings?password=zipo"];
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


-(void)updateScreen:(NSArray*)partes
{
    if(partes.count>=9)
    {
        _mes.text=partes[5];
        _dia.text=partes[6];
        _hora.text=partes[7];
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
