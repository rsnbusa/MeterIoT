//
//  Timings.m
//  FeedIoT
//
#import "Timings.h"
#import "servingCell.h"
#import "AppDelegate.h"
#import "ThirViewController.h"
#import "httpVc.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "DGActivityIndicatorView.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


@interface Timings ()

@end


@implementation Timings
@synthesize bffIcon,time,totKwh,totValor,amps,ampslabel,tempHum,tempo,meter,onImage,offImage,lastMonth;
id yo;
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}
-(void)setCallBackNull
{
    [appDelegate.client setMessageHandler:NULL];
}

-(IBAction)showMonth:(id)segue {
    
     [self performSegueWithIdentifier:@"servingsEditVC" sender:self];
}

-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:que
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}


MQTTMessageHandler generalMsg=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"GeneralMsg msg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showMessage:@"Meter Answer" withMessage:message.payloadString];
    });
};

-(IBAction)selectMeter:(UISegmentedControl* )sender {
    selectedMeter=(int)meter.selectedSegmentIndex;
    amps.text=nil;
    ampslabel.text=nil;
    totKwh.text=nil;
    totValor.text=nil;
    tempHum.text=nil;
    mis=[NSString stringWithFormat:@"displaymeter?password=zipo&meter=%d",(int)sender.selectedSegmentIndex];
    [comm lsender:mis andAnswer:NULL andTimeOut:1 vcController:self];

 //   [activityIndicatorView stopAnimating];
    [self dispatcher];
    if(theFirstTimer)
        [theFirstTimer invalidate];
    theFirstTimer=[NSTimer scheduledTimerWithTimeInterval:(int)tempo.value
                                                   target:self
                                                 selector:@selector(dispatcher)
                                                 userInfo:nil
                                                  repeats:YES];
}

-(void)workingIcon
{
    UIImage *licon;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    bffIcon.image=licon;
}

-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        LogDebug(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

BOOL CheckWiFi() {
    
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

-(void)showSettings:(NSString*)lanswer
{
    NSArray *partes,*diahora;
    NSString *dater,*medidor;
    int corte=0,currentBeat=0,curLife=0,curMonth=0,curDay=0,curHour=0,curCycle=0,beatKwH=0,onOff=0,beatsNow,powerNow,maxAmps,msAmps,msNow,limbo;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [activityIndicatorView stopAnimating];
    });
    
        partes=[lanswer componentsSeparatedByString:@"!"];
        LogDebug(@"Answer %@ count %d",lanswer,partes.count);
        if(partes.count>16)
        {
            currentBeat=(int)[partes[0] integerValue];
            curLife=(int)[partes[1] integerValue];
            curMonth=(int)[partes[2] integerValue];
            curDay=(int)[partes[3] integerValue];
            curHour=(int)[partes[4] integerValue];
            curCycle=(int)[partes[5] integerValue];
            beatKwH=(int)[partes[6] integerValue];
            dater=partes[7];
            diahora=[dater componentsSeparatedByString:@" "];
            medidor=partes[8];
            onOff=(int)[partes[9] integerValue ];
            maxAmps=(int)[partes[10] integerValue ];
            msAmps=(int)[partes[11] integerValue ];
            powerNow=(int)[partes[12] integerValue ];
            msNow=(int)[partes[13] integerValue ];
            beatsNow=(int)[partes[14] integerValue ];
            limbo=(int)[partes[15] integerValue ];
            corte=(int)[partes[16] integerValue ];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSString *beats = [numberFormatter stringFromNumber:[NSNumber numberWithInt:curLife]];
            NSString *kwh = [numberFormatter stringFromNumber:[NSNumber numberWithInt:currentBeat]];
            NSString *mes = [numberFormatter stringFromNumber:[NSNumber numberWithInt:curMonth]];
            NSString *dia = [numberFormatter stringFromNumber:[NSNumber numberWithInt:curDay]];
            NSString *hora = [numberFormatter stringFromNumber:[NSNumber numberWithInt:curHour]];
            NSString *beatk=[NSString stringWithFormat:@"%d",beatKwH];
            if(onOff)
                [_breaker setImage:onImage forState:UIControlStateNormal];
            else
                [_breaker setImage:offImage forState:UIControlStateNormal];
            
            amps.text=beats;
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = 0.75;
            [ampslabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
            [_cuandoDia.layer addAnimation:animation forKey:@"kCATransitionFade"];
            [_cuandoHora.layer addAnimation:animation forKey:@"kCATransitionFade"];
            [_beats.layer addAnimation:animation forKey:@"kCATransitionFade"];
            
            ampslabel.text=kwh;
            
            _costoDia.text=medidor;
            time.text=mes;
            totKwh.text=dia;
            totValor.text=hora;
            tempHum.text=beatk;
            //  _cuandoDia.text=diahora[0];
            // _cuandoHora.text=diahora[1];
            _cuandoDia.text=[NSString stringWithFormat:@"%@amp",partes[12]];
            _cuandoHora.text=[NSString stringWithFormat:@"%@ms",partes[13]];
            _maxPower.text=[NSString stringWithFormat:@"%@amp",partes[10]];
            _msPower.text=[NSString stringWithFormat:@"%@ms",partes[11]];
            _beats.text=[NSString stringWithFormat:@"%@",partes[14]];
            _limbo.text=[NSString stringWithFormat:@"%@",partes[15]];
            
            // set activity color for ONLINE mode BLue
            activityIndicatorView.tintColor=[UIColor colorWithRed:49.0/255.0 green:130.0/255.0 blue:217.0/255.0 alpha:1.0];
    }
}

MQTTMessageHandler showStatus=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"Status msg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showSettings:message.payloadString];
    });
};

-(void)viewDidLoad
{
    [super viewDidLoad];
    yo=self;
    activityIndicatorView =[[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeTriplePulse
                                                               tintColor:[UIColor colorWithRed:49.0/255.0 green:130.0/255.0 blue:217.0/255.0 alpha:1.0] size:100.0f];
 
    activityIndicatorView.frame = _activity.frame;

    [self.view addSubview:activityIndicatorView];
    onImage = [UIImage imageNamed:@"oniphone.png"];
    offImage = [UIImage imageNamed:@"offiphone.png"];

    comm=[httpVC new];
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    answer=nil;
    answer=[NSMutableString string];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    theStatusTimer=nil;
     _intervalo.text=[NSString stringWithFormat:@"%d",(int)tempo.value];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if(theFirstTimer)
    {
        [theFirstTimer invalidate];
        theFirstTimer=nil;
    }
    
    if(theStatusTimer)
    {
        [theStatusTimer invalidate];
        theStatusTimer=nil;
    }
    
    NSString *blank=[NSString stringWithFormat:@"                  "];
    amps.text=blank;
    ampslabel.text=blank;
    _costoDia.text=blank;
    time.text=blank;
    totKwh.text=blank;
    totValor.text=blank;
    tempHum.text=blank;
    
}

-(void)makeHour
{
    activityIndicatorView.tintColor=[UIColor colorWithRed:217.0/255.0 green:56.0/255.0 blue:41.0/255.0 alpha:1.0];

    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicatorView startAnimating];
        [theStatusTimer invalidate];
        theStatusTimer=nil;
    });
    
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:showStatus];
    mis=[NSString stringWithFormat:@"status?meter=%d",selectedMeter];
  [comm lsender:mis andAnswer:NULL andTimeOut:wifi?2:10 vcController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    yo=self;
    appDelegate.rxIn=NO;
    wifi=CheckWiFi();
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if(passw.integerValue)
    {
     if (!appDelegate.passwordf)
     {
         LogDebug(@"Need to get password");
         [self performSegueWithIdentifier:@"getPassword" sender:self];
     }
    }
    
    [self workingIcon];

    selectedMeter=(int)meter.selectedSegmentIndex;
   
    if (!theStatusTimer)
    {
        [self makeHour];
        theFirstTimer=[NSTimer scheduledTimerWithTimeInterval:(int)tempo.value //60-(int)comps.second
                                         target:self
                                       selector:@selector(dispatcher)
                                       userInfo:nil
                                        repeats:YES];
          }

}

-(IBAction)tiempo:(UISlider*)sender
{
    _intervalo.text=[NSString stringWithFormat:@"%d",(int)tempo.value];
    [activityIndicatorView stopAnimating];
    if(theFirstTimer)
        [theFirstTimer invalidate];
    theFirstTimer=[NSTimer scheduledTimerWithTimeInterval:(int)tempo.value
                                                    target:self
                                                  selector:@selector(dispatcher)
                                                  userInfo:nil
                                                   repeats:YES];
}

-(IBAction)powerOffOn:(id)sender
{
    BOOL como;
    
    como=NO;
    LogDebug(@"Breaker Im %@",[_breaker imageForState:UIControlStateNormal]==onImage?@"ON":@"OFF");
    if([_breaker imageForState:UIControlStateNormal]==onImage)
        [_breaker setImage:offImage forState:UIControlStateNormal];
    else
    {
        [_breaker setImage:onImage forState:UIControlStateNormal];
        como=YES;
    }
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:generalMsg];
    mis=[NSString stringWithFormat:@"conection?password=zipo&meter=%d&st=%d",(int)meter.selectedSegmentIndex,como];
    [comm lsender:mis andAnswer:NULL andTimeOut:CheckWiFi()?2:10 vcController:self];
}

-(void)dispatcher
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.75;
    [activityIndicatorView.layer addAnimation:animation forKey:@"kCATransitionFade"];
    [activityIndicatorView stopAnimating];
    if (!theStatusTimer){
        theStatusTimer=[NSTimer scheduledTimerWithTimeInterval:0.0
                                     target:self
                                   selector:@selector(makeHour)
                                   userInfo:nil
                                    repeats:NO];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [activityIndicatorView stopAnimating];
    
}


@end

