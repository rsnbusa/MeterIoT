//
//  Log.h
//  GarageIoT
//
//  Created by Robert on 6/15/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"
@interface Log : UIViewController
{
    httpVC *comm;
    NSString *mis;
    AppDelegate* appDelegate;
    bool save;
    NSMutableArray *entries;
    NSInteger randomNumber;
    MQTTMessageHandler lastmess;
}
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UITableView *table;


@end
