//
//  webBrowserViewController.h
//  HeatIoT
//
//  Created by Robert on 9/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"

@interface webBrowserViewController : UIViewController<UIWebViewDelegate>
{
    httpVC *comm;
    NSString *mis;
    AppDelegate* appDelegate;
}

@property (strong) IBOutlet UISegmentedControl *dispMeter,*dispMode,*formatMeter,*formatAll;
@property (strong) IBOutlet UISwitch *onOff;
@property (strong) IBOutlet UISlider *interval;
@property (strong) IBOutlet UILabel *inter;
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UITextField *mes,*dia,*hora,*meterid,*startkwh;

@end
