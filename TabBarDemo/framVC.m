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
extern BOOL CheckWiFi();

@interface framVC ()

@end

@implementation framVC

-(IBAction)formatAll:(UISegmentedControl*)sender
{
    if(sender.selectedSegmentIndex==3)
        return;

    if(sender.selectedSegmentIndex==0)
    {
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&ALL=0"];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
        return;
    }
    else{
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&all=0",(int)sender.selectedSegmentIndex-1];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
        return;
    }
    
}

-(IBAction)formatSingle:(id)sender
{
    NSLog(@"Mes %@ Dia %@ Hora %@",_mes.text,_dia.text,_hora.text);
    if(![_hora.text isEqualToString:@""])
    {// Hour format
        //must have day and month
        if([_dia.text isEqualToString:@""])
            return; //Give error message
        if([_mes.text isEqualToString:@""])
            return ;
        mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&HOUR=%@&mes=%@&day=%@",(int)_formatMeter.selectedSegmentIndex,_hora.text,_mes.text,_dia.text];
        [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
        return;
    }
    else
        if(![_dia.text isEqualToString:@""])
        {
            // Day format
            if([_mes.text isEqualToString:@""])
                return ;
            mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&DAY=%@&mes=%@",(int)_formatMeter.selectedSegmentIndex,_dia.text,_mes.text];
            [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
            return;
        }
        else
            if(![_mes.text isEqualToString:@""])
            { //Month format
                mis=[NSString stringWithFormat:@"frammanager?password=zipo&METER=%d&MON=%@",(int)_formatMeter.selectedSegmentIndex,_mes.text];
                [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
            }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _formatAll.tintColor=[UIColor colorWithRed:152.0/256.0 green:192.0/256.0 blue:0.0/256.0 alpha:1.0];
    _formatMeter.tintColor=[UIColor colorWithRed:152.0/256.0 green:192.0/256.0 blue:0.0/256.0 alpha:1.0];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *lanswer;
    
    [super viewDidAppear:animated];
    mis=[NSString stringWithFormat:@"settings?password=zipo"];
    if( [comm lsender:mis andAnswer:&lanswer andTimeOut:CheckWiFi()?2:10 vcController:self])
    {
        // NSLog(@"Setings %@",lanswer);
        //set different controls to received data
        NSArray *partes=[lanswer componentsSeparatedByString:@"!"];
        [self updateScreen:partes];
    }
    
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
