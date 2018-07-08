//
//  AppDelegate.m
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import "AppDelegate.h"
#import "KeychainWrapper.h"
#import <Security/Security.h>
#import "queueEntry.h"

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize firstViewController,secondViewController,lastbutton,tabBarController,workingBFF,bffs,feed_addr,feeders,direccion,oldbff,lastpos,emailsArray,appColors,imageArray,passwordf,queues,client,mqservers,clonef,logText;

-(void)makeLogText
{
    [logText addObject:@"System Booted"]; //0
    [logText addObject:@"Fram Cmd"];// 1
    [logText addObject:@"WiFi"]; //2
    [logText addObject:@"Log"];// 3
    [logText addObject:@"Erase Config"]; // 4
    [logText addObject:@"Payment"]; // 5
    [logText addObject:@"Connection"];// 6
    [logText addObject:@"MQTT"];// 7
    [logText addObject:@"PayTable"];//8
    [logText addObject:@"Ap Set"];//9
    [logText addObject:@"Reset"]; // 10
    [logText addObject:@"Timer Delete"]; //11
    [logText addObject:@"Timer Sync"];//12
    [logText addObject:@"Heater Off"];//13
    [logText addObject:@"Heater On"]; //14
    [logText addObject:@"Reload Reboot"]; //15
    [logText addObject:@"Manual On"]; //16
    [logText addObject:@"Manual Off"]; //17
}

-(void) makeColors
{
     [appColors addObject:[UIColor colorWithRed:70.0/255.0 green:255.0/255.0 blue:20.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:182.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:96.0/255.0 green:79.0/255.0 blue:255.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:252.0/255.0 green:81.0/255.0 blue:148.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:107.0/255.0 green:43.0/255.0 blue:255.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:70.0/255.0 green:203.0/255.0 blue:255.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:253.0/255.0 green:154.0/255.0 blue:13.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:253.0/255.0 green:161.0/255.0 blue:179.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:239.0/255.0 green:255.0/255.0 blue:69.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:119.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:38.0/255.0 alpha:1.0]];
     [appColors addObject:[UIColor colorWithRed:205.0/255.0 green:165.0/255.0 blue:225.0/255.0 alpha:1.0]];
    
}
-(void)createQueue:(NSString*)nombre
{
    NSLog(@"Create queue %@",nombre);
    NSMutableArray *temp=[queues objectForKey:nombre];
    if (temp==NULL)
    {
        NSMutableArray *a=[[NSMutableArray alloc]init];
        [queues setObject:a forKey:nombre];
    }
    else
        [temp removeAllObjects];
}

MQTTDisconnectionHandler disco=^(NSUInteger code){
      AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    LogDebug(@"disconnect %d %d ",code,appDelegate.mqservers.count);

    if(appDelegate.voyserver++>=appDelegate.mqservers.count)
        appDelegate.voyserver=0;
    
    LogDebug(@"Server %d",appDelegate.voyserver);
    if(appDelegate.voyserver<appDelegate.mqservers.count)
        [appDelegate connectManager:@"m13.cloudmqtt.com"];
    else
    {
        [appDelegate.workingBFF setValue:@0 forKey:@"bffLimbo"];// use web transport
        LogDebug(@"Disconnected use Web");
    }

};

MQTTMessageHandler aqui=^(MQTTMessage *message)
{
    // will queue messages received into a RAM queue based on message.Topic title as the queue name
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *text = message.payloadString;
    queueEntry * messageFromController=[[queueEntry alloc]init];
    messageFromController.date=[NSDate date];
    messageFromController.que=text;
    LogDebug(@"Message received Topic %@ Data %@ MID %d retainded %d",message.topic,text,message.mid,message.retained);
    NSString *alertm=[NSString stringWithFormat:@"MeterIoT/EcuaHeat/Monitor/%@/%@/ALERT",[appDelegate.workingBFF valueForKey:@"bffGroup"],[appDelegate.workingBFF valueForKey:@"bffName"]];
    appDelegate.rxIn=YES;
    if([message.topic isEqualToString:alertm])
    {
        NSArray *msgParts=[text componentsSeparatedByString:@"|"];
        if (msgParts.count==5)
        {
        NSManagedObjectContext *context =
        [appDelegate managedObjectContext];
        NSManagedObject *logEntry= [NSEntityDescription
                                  insertNewObjectForEntityForName:@"Log"
                                  inManagedObjectContext:context];
        
        [logEntry setValue:[msgParts objectAtIndex:3] forKey:@"logAlert"];
        [logEntry setValue:[msgParts objectAtIndex:2] forKey:@"logBff"];
        [logEntry setValue:[msgParts objectAtIndex:4] forKey:@"logText"];

   
        NSString *str =[msgParts objectAtIndex:1];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [formatter setTimeZone:gmt];
        NSDate *datee = [formatter dateFromString:str];
        [logEntry setValue:datee forKey:@"logAlertDate"];
        [logEntry setValue:[NSDate date] forKey:@"logDate"];
        [logEntry setValue:[[msgParts objectAtIndex:0] stringByAppendingString:[msgParts objectAtIndex:1]] forKey:@"logId"];
    //    NSLog(@"LogEntry %@",logEntry);
        }
      //  else
         //   NSLog(@"Bad ALERT Message");
    }
    else
    {
        NSMutableArray *temp=[appDelegate.queues objectForKey:message.topic];
        if(temp!=NULL)
            [temp addObject:messageFromController]; //Add the message to the Queue
    }
};

-(void)subscribeMQTT:(NSString*)rx
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [client subscribe:rx withCompletionHandler:nil];
    [appDelegate createQueue:rx];
  //  [client subscribe:tx withCompletionHandler:nil];
 //   [appDelegate createQueue:tx];
}

-(void)unsubscribeMQTT:(NSString*)rx
{
    [client unsubscribe:rx withCompletionHandler:nil];
 //   [client disconnectWithCompletionHandler:nil];
}

-(void)connectManager:(NSString*)cualMqtt
{
    LogDebug(@"Mqtt to %@",cualMqtt);
  //  [client connectToHost:[mqservers objectAtIndex:self.voyserver]  //@"192.168.100.101" //@"broker.hivemq.com" //@"test.mosquitto.org"
    //  [client connectToHost:@"broker.hivemq.com"  //@"192.168.100.101" //@"m13.cloudmqtt.com" //@"test.mosquitto.org" //@"broker.hivemq.com"
        [client connectToHost:cualMqtt
        completionHandler:^(NSUInteger code) {
            if (code == ConnectionAccepted)
            {
                [workingBFF setValue:@1 forKey:@"bffLimbo"];// use mqtt transport
                [self subscribeMQTT:[NSString stringWithFormat:@"MeterIoT/%@/%@/%@/MSG",[self.workingBFF valueForKey:@"bffName"],[self.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
       //         [self subscribeMQTT:[NSString stringWithFormat:@"MeterIoT/EcuaHeat/Monitor/%@/%@/ALERT",[self.workingBFF valueForKey:@"bffName"],[self.workingBFF valueForKey:@"bffName"]]];
                LogDebug(@"Connected. Subscribe %@",[NSString stringWithFormat:@"MeterIoT/%@/%@/%@/MSG",[self.workingBFF valueForKey:@"bffName"],[self.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]);
            }
            else
                LogDebug(@"error conn %lu",code);
        }];

}

-(void)startTelegramService:(NSString*)whichServer withPort:(NSString*)thisPort
{
    NSString  *currentDeviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    LogDebug(@"UID %@",currentDeviceId);
 //   NSString *clientID =[[NSString stringWithFormat:@"%@CLIENT", [workingBFF valueForKey:@"bffName"]] uppercaseString];
    LogDebug(@"Mqtt %@:%@ Client %@",whichServer,thisPort,currentDeviceId);
 
    if(client)
        [client disconnectWithCompletionHandler:nil];

  //  client = [[MQTTClient alloc] initWithClientId:clientID];
    client = [[MQTTClient alloc] initWithClientId:currentDeviceId];

//    client.username=@"wckwlvot";
//    client.password=@"LpoEYOhOClPq";
    client.port=thisPort.integerValue;
    
    client.username= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttuser"];
    client.password= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttpass"];

       client.keepAlive=15;
    // connect to the MQTT server
    [client setMessageHandler: aqui
     // or using blocks
     /*^(MQTTMessage *message) {
      NSString *text = message.payloadString;
          LogDebug(@"Topic %@ mid %d retained %d received message %@",message.topic,message.mid,message.retained, text);
      queueEntry * a=[[queueEntry alloc]init];
      a.date=[NSDate date];
      a.que=text;
      NSLog(@"Message received Topic %@ Data %@ MID %d retainded %d",message.topic,text,message.mid,message.retained);
      NSMutableArray *temp=[appDelegate.queues objectForKey:message.topic];
      if(temp!=NULL)
      [temp addObject:a];
      }
      */
     ];
    
    [self.client setDisconnectionHandler:disco];
    [self connectManager:whichServer];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIDevice *device = [UIDevice currentDevice];
    
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    _deviceMqtt=[currentDeviceId substringFromIndex:MAX((int)[currentDeviceId length]-8, 0)]; //in case string is less than 8 characters long.
    [[NSUserDefaults standardUserDefaults] setObject:_deviceMqtt  forKey:@"bffUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   // NSLog(@"UID %@",currentDeviceId);
    // Override point for customization after application launch.
    tabBarController = (UITabBarController *)self.window.rootViewController;
    firstViewController = [[tabBarController viewControllers] objectAtIndex:0];
    secondViewController = [[tabBarController viewControllers] objectAtIndex:1];
    lastbutton=-1;
    feed_addr= [[NSMutableDictionary alloc] initWithCapacity:100];
    queues= [[NSMutableDictionary alloc] initWithCapacity:10];
    feeders=[[NSMutableArray alloc]initWithCapacity:100];
    emailsArray=[[NSMutableArray alloc]initWithCapacity:100];
    appColors=[[NSMutableArray alloc]initWithCapacity:15];
    imageArray=[[NSMutableArray alloc]initWithCapacity:50];
     logText=[[NSMutableArray alloc]initWithCapacity:50];
    [self makeColors];
    [self makeLogText];
    direccion=[NSMutableString string];
//#ifndef TARGET_IPHONE_SIMULATOR

    KeychainWrapper* keychain = [[KeychainWrapper alloc]init];
    [keychain mySetObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    NSString *user=[keychain myObjectForKey:(id)kSecAttrAccount];
    if ([user isEqualToString:@""] || user==NULL){
    [keychain mySetObject:@"MeterIoT" forKey:(id)kSecAttrAccount];
    [keychain mySetObject:@"VeryCold" forKey:(id)kSecValueData];
    }
//#endif
 //   mqservers=[NSArray arrayWithObjects:@"broker.hivemq.com",@"m2m.eclipse.org",@"test.mosquitto.org",nil];
    mqservers=[NSArray arrayWithObjects:@"m13.cloudmqtt.com",nil];
  //      mqservers=[NSArray arrayWithObjects:@"broker.hivemq.com",nil];

    self.voyserver=0;
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    passwordf=!passw.integerValue;
    LogDebug(@"Initial Passwordf %d",passwordf);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
     NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if(passw.integerValue)
        passwordf=NO;
    else
        passwordf=YES;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if(passw.integerValue)
        passwordf=NO;
    else
        passwordf=YES;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "rsn.coredata" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"coredata" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"coredata.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        LogDebug(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}




- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          //  LogDebug(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
