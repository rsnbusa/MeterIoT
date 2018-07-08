//
//  monthUseViewController.h
//  MeterIoT
//
//  Created by Robert on 2/3/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSDFDatePickerView.h"

@interface monthUseViewController : UIViewController <RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>

@property (copy, nonatomic) NSArray *datesToMark;
@property (copy, nonatomic) NSDictionary *statesOfTasks;
@property (copy, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) RSDFDatePickerView *datePickerView;
@property (copy, nonatomic) UIColor *completedTasksColor;
@property (copy, nonatomic) UIColor *uncompletedTasksColor;
@property (copy, nonatomic) NSDate *today;
@property (copy, nonatomic) NSCalendar *calendar;

@end
