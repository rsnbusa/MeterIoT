//
//  ThirViewController.m
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import "ThirViewController.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import "httpVc.h"
#import "JBBarChartView.h"


#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


@import UIKit;
@implementation ThirViewController

- (NSDate *)today
{
    if (!_today) {
        NSDateComponents *todayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        _today = [self.calendar dateFromComponents:todayComponents];
    }
    return _today;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setCalendar:self.calendar];
        [_dateFormatter setLocale:[self.calendar locale]];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    return _dateFormatter;
}

#pragma mark - RSDFDatePickerViewDelegate

-(void)myTapMethod{
    [self.view sendSubviewToBack:_algox];
}

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger day = [components day];
    NSInteger month = [components month];

    NSString *mis=[NSString stringWithFormat:@"gethoursinday?meter=%d&month=%d&day=%d",(int)_cualMeter.integerValue,(int)month-1,(int)day-1];
    NSString *lanswer;
    
    int reply=[comm lsender:mis andAnswer:&lanswer andTimeOut:2 vcController:self];
    
    if (reply)
        _horasDia=[lanswer componentsSeparatedByString:@"!"];
    else
        [_horasDia removeAllObjects];
    [self.view bringSubviewToFront:_algox];
    [barChartView reloadData];

//    [[[UIAlertView alloc] initWithTitle:@"Picked Date" message:[self.dateFormatter stringFromDate:date] delegate:nil cancelButtonTitle:@":D" otherButtonTitles:nil] show];
}

#pragma mark - RSDFDatePickerViewDataSource

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldHighlightDate:(NSDate *)date
{
    if (view == self.datePickerView) {
        return YES;
    }
    
    if ([self.today compare:date] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldSelectDate:(NSDate *)date
{
    if (view == self.datePickerView) {
        return YES;
    }
    
    if ([self.today compare:date] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
    if(_datesToMark.count==0)
        return NO;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"D"];
    NSUInteger dayOfYear = [[formatter stringFromDate:date] intValue];
    
    if([_datesToMark[dayOfYear-1] integerValue] >0)
    return YES;
    else
        return NO;
}

- (UIColor *)datePickerView:(RSDFDatePickerView *)view markImageColorForDate:(NSDate *)date
{
    if (![self.statesOfTasks[date] boolValue]) {
        return self.uncompletedTasksColor;
    } else {
        return self.completedTasksColor;
    }
}

- (UIImage *)datePickerView:(RSDFDatePickerView *)view markImageForDate:(NSDate *)date
{
    if(_datesToMark.count==0)
        return NULL;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"D"];
    NSUInteger dayOfYear = [[formatter stringFromDate:date] intValue];
    
    if([_datesToMark[dayOfYear-1] integerValue] >0)
    {
    NSDictionary *attributes = @{NSFontAttributeName            : [UIFont fontWithName:@"Helvetica" size:16],
                                 NSForegroundColorAttributeName : [UIColor blueColor],
                                 NSBackgroundColorAttributeName : [UIColor clearColor]};
    CGSize size = CGSizeMake(300, 9999);
    NSString *myString =_datesToMark[dayOfYear-1];
    UIFont *myFont = [UIFont  fontWithName:@"Helvetica" size:16];
    CGSize myStringSize = [myString sizeWithFont:myFont
                               constrainedToSize:size
                                   lineBreakMode:NSLineBreakByClipping];
    UIGraphicsBeginImageContextWithOptions(myStringSize, NO, 0);
    [myString drawInRect:CGRectMake(0, 0, myStringSize.width, myStringSize.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    }
    else
        return NULL;
    
}


- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons
    [super viewWillDisappear:animated];
   

   }
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *mis=[NSString stringWithFormat:@"getdayall?meter=%d",(int)_cualMeter.integerValue];
    NSString *lanswer;

    int reply=[comm lsender:mis andAnswer:&lanswer andTimeOut:2 vcController:self];
    
    if (reply)
    {
        _datesToMark=[lanswer componentsSeparatedByString:@"!"];
    }
    else
        [_datesToMark removeAllObjects];
}

-(IBAction)regresa:(UIButton *)sender
{

     [self performSegueWithIdentifier:@"doneEditVC" sender:self];

    
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
  //our return segue
}



- (void)viewDidLoad {

    [super viewDidLoad];
    _datesToMark=[[NSMutableArray alloc]initWithCapacity:366];
     comm=[httpVC new];
    _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [self.calendar dateFromComponents:todayComponents];
    _datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds];
    _datePickerView.delegate=self;
    _datePickerView.dataSource=self;
    [self.datePickerView selectDate:today];
    [self.view addSubview:self.datePickerView];
    barChartView = [[JBBarChartView alloc] init];
    barChartView.dataSource = self;
    barChartView.delegate = self;
    barChartView.frame=_algox.bounds;
    [_algox addSubview:barChartView];
 //   [self.view addSubview:barChartView];
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTapMethod)];
    [_algox setUserInteractionEnabled:YES];
    [_algox addGestureRecognizer:newTap];
  }

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return 24; // number of bars in chart
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    NSLog(@"Hora %d= %f",index,[_horasDia[index] floatValue]);
    return [_horasDia[index] floatValue]; // height of bar at index
}

@end
