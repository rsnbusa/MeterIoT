//
//  displayVC.h
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"

@interface displayVC : UIViewController
{
    httpVC *comm;
    NSString *mis;
    AppDelegate* appDelegate;
}

@property (strong) IBOutlet UISegmentedControl *dispMeter,*dispMode;
@property (strong) IBOutlet UISwitch *onOff;
@property (strong) IBOutlet UISlider *interval;
@property (strong) IBOutlet UILabel *inter;
@property (strong) IBOutlet UIImageView *bffIcon;
@end

