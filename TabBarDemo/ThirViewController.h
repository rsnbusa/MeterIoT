//
//  ThirViewController.h
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSDFDatePickerView.h"
#import "httpVc.h"
#import "JBBarChartView.h"
#import "AppDelegate.h"
#import "AMTumblrHud.h"

@interface ThirViewController : UIViewController<RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>
{
    httpVC *comm;
    JBBarChartView *barChartView;
    AppDelegate *appDelegate;
    MQTTMessageHandler viejo;
    AMTumblrHud *tumblrHUD ;
    NSTimer *mitimer;
    }

@property (copy, nonatomic) NSMutableArray *datesToMark,*horasDia;
@property (copy, nonatomic) NSDictionary *statesOfTasks;
@property (copy, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) RSDFDatePickerView *datePickerView;
@property (copy, nonatomic) UIColor *completedTasksColor;
@property (copy, nonatomic) UIColor *uncompletedTasksColor;
@property (copy, nonatomic) NSDate *today;
@property (copy, nonatomic) NSCalendar *calendar;
@property (copy, nonatomic) NSNumber *cualMeter;
@property (strong) IBOutlet UIImageView *algox,*hhud;
@property (strong) IBOutlet UIButton *doneb;




@end
