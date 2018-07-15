//
//  webBrowserViewController.m
//  HeatIoT
//
//  Created by Robert on 9/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "webBrowserViewController.h"
#import "httpVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@interface webBrowserViewController ()

@end

@implementation webBrowserViewController


BOOL CheckWiFiW() {
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    BOOL hasWifi = NO;
    
    int err = getifaddrs(&interfaces);
    if(err == 0) {
        
        temp_addr = interfaces;
        
        while(temp_addr) {
            
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                struct sockaddr_in *addr = (struct sockaddr_in *)temp_addr->ifa_addr;
                
                if(memcmp(temp_addr->ifa_name, "en", 2) == 0) {
                    hasWifi = YES;
                    break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return hasWifi;
}

-(IBAction)formatAll:(UISegmentedControl*)sender
{
    if(sender.selectedSegmentIndex==0)
    {
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&ALL=0"];
       [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
        return;
    }
    else{
    mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&all=0",(int)sender.selectedSegmentIndex-1];
   [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
    return;
    }

}

-(IBAction)intervalSelect:(id)sender
{
         NSString* lanswer;
    _inter.text=[NSString stringWithFormat:@"%d",(int)_interval.value];
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&meter=%d&int=%d",(int)_dispMeter.selectedSegmentIndex,(int)_interval.value];
    [comm lsender:mis andAnswer:&lanswer andTimeOut:CheckWiFiW()?2:10 vcController:self];

}
-(IBAction)update:(id)sender
{
    if([_meterid.text isEqualToString:@""] || [_startkwh.text isEqualToString:@""])
       return;
       
    mis=[NSString stringWithFormat:@"internal?password=zipo&meter=%d&mmmm=%@&born=%@",(int)_dispMeter.selectedSegmentIndex,_meterid.text,_startkwh.text];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
}

-(IBAction)tariffs:(id)sender
{
    
    mis=[NSString stringWithFormat:@"tariff?password=zipo"];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
}

-(IBAction)firmware:(id)sender
{
    if([_meterid.text isEqualToString:@""] || [_startkwh.text isEqualToString:@""])
        return;
    
    mis=[NSString stringWithFormat:@"firmware?password=zipo"];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
}

-(IBAction)reset:(id)sender
{
    mis=[NSString stringWithFormat:@"reset?password=zipo"];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
}

-(IBAction)resetStats:(id)sender
{
    mis=[NSString stringWithFormat:@"resetstats?password=zipo"];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
}

-(IBAction)formatSingle:(id)sender
{
    LogDebug(@"Mes %@ Dia %@ Hora %@",_mes.text,_dia.text,_hora.text);
    if(![_hora.text isEqualToString:@""])
    {// Hour format
        //must have day and month
        if([_dia.text isEqualToString:@""])
            return; //Give error message
        if([_mes.text isEqualToString:@""])
            return ;
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&HOUR=%@&mes=%@&day=%@",(int)_formatMeter.selectedSegmentIndex,_hora.text,_mes.text,_dia.text];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
        return;
    }
    else
        if(![_dia.text isEqualToString:@""])
        {
            // Day format
            if([_mes.text isEqualToString:@""])
                return ;
            mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&DAY=%@&mes=%@",(int)_formatMeter.selectedSegmentIndex,_dia.text,_mes.text];
            [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
            return;
        }
    else
        if(![_mes.text isEqualToString:@""])
        { //Month format
            mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&MON=%@",(int)_formatMeter.selectedSegmentIndex,_mes.text];
            [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFiW()?2:10 vcController:self];
        }
}

-(IBAction)onOff:(UISwitch*)sender
{
        NSString* lanswer;
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&st=%d",sender.isOn];
    [comm lsender:mis andAnswer:&lanswer andTimeOut:CheckWiFiW()?2:10 vcController:self];

}

-(IBAction)displayMode:(UISegmentedControl*)sender
{
     NSString* lanswer;
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&mode=%d",(int)sender.selectedSegmentIndex];
    [comm lsender:mis andAnswer:&lanswer andTimeOut:CheckWiFiW()?2:10 vcController:self];
 
}

-(IBAction)displayMeter:(UISegmentedControl*)sender
{
    NSString* lanswer;
    mis=[NSString stringWithFormat:@"displaymanager?password=zipo&meter=%d",(int)sender.selectedSegmentIndex];
   if( [comm lsender:mis andAnswer:&lanswer andTimeOut:CheckWiFiW()?2:10 vcController:self])
   {
       NSArray *partes=[lanswer componentsSeparatedByString:@"!"];
       [self updateScreen:partes];
   }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
     appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _dispMode.tintColor=[UIColor colorWithRed:233.0/256.0 green:96.0/256.0 blue:187.0/256.0 alpha:1.0];
    _dispMeter.tintColor=[UIColor colorWithRed:233.0/256.0 green:96.0/256.0 blue:187.0/256.0 alpha:1.0];
    _formatAll.tintColor=[UIColor colorWithRed:152.0/256.0 green:192.0/256.0 blue:0.0/256.0 alpha:1.0];
    _formatMeter.tintColor=[UIColor colorWithRed:152.0/256.0 green:192.0/256.0 blue:0.0/256.0 alpha:1.0];

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
        _dispMeter.selectedSegmentIndex=[partes[0] integerValue];
        _dispMode.selectedSegmentIndex=[partes[1] integerValue];
        _onOff.on=[partes[2] integerValue];
        _meterid.text=partes[3];
        _startkwh.text=partes[4];
        _mes.text=partes[5];
        _dia.text=partes[6];
        _hora.text=partes[7];
        _inter.text=partes[8];
        _interval.value=[partes[8] floatValue];
    }

}
-(void)viewDidAppear:(BOOL)animated
{
    NSString* lanswer;
    [super viewDidAppear:animated];
    [self workingIcon];
    mis=[NSString stringWithFormat:@"settings?password=zipo"];
   if( [comm lsender:mis andAnswer:&lanswer andTimeOut:CheckWiFiW()?2:10 vcController:self])
   {
       LogDebug(@"Setings %@",lanswer);
       //set different controls to received data
       NSArray *partes=[lanswer componentsSeparatedByString:@"!"];
       [self updateScreen:partes];
     }


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
