//
//  Timings.h
//  FeedIoT
//
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "httpVc.h"
#import "DoughnutChartContainerView.h"
#import "blurLabel.h"
#import "btSimplePopUp.h"
#import "DGActivityIndicatorView.h"

@interface Timings : UIViewController <btSimplePopUpDelegate>
{
    bool editf;
    AppDelegate *appDelegate;
    NSString *mis;
    NSMutableString *answer;
    httpVC *comm;
    float costoTm,costoTd;
    NSTimer *theStatusTimer,*theFirstTimer;
    int selectedMeter;
    BOOL wifi;
    DGActivityIndicatorView *activityIndicatorView;
}


@property (strong) IBOutlet UIImageView *bffIcon,*activity;
@property (strong) IBOutlet UIView *mainView;
@property (strong) IBOutlet UILabel *time,*costoDia,*totValor, *totKwh,*amps,*ampslabel,*tempHum,*lastMonth;
@property (strong) IBOutlet UILabel *cuandoDia,*cuandoHora,*intervalo,*maxPower,*msPower,*beats,*limbo;
@property (strong) IBOutlet UIButton *breaker;
@property (strong) UIImage *onImage,*offImage;
@property (strong) IBOutlet UISlider *tempo;
@property (strong) IBOutlet UISegmentedControl *meter;

@end
