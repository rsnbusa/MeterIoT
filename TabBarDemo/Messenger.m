/*
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 */

#import "Messenger.h"
#import "MqttOCClient.h"
#import "AppDelegate.h"
#import "Subscription.h"
#include "FirstViewController.h"
#define PORTESP 81
@import AVFoundation;

// Connect Callbacks

@interface ConnectCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation ConnectCallbacks

-(void)subs
{ // This a controller for many feeders so a Wildchar for NAME is used (+)
    NSString *subscribeTopic=[NSString stringWithFormat:@"HeatIoT/+/MSG"];
    [[Messenger sharedMessenger] subscribe:subscribeTopic qos:0];
}

- (void) onSuccess:(NSObject*) invocationContext
{
   
    [self performSelectorOnMainThread:@selector(subs ) withObject:NULL waitUntilDone:NO];
   NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);

  //  [[Messenger sharedMessenger] addLogMessage:@"Connected to server!" type:@"Action"];

 //   AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
 //   [appDelegate updateConnectButton];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__,
        __LINE__, invocationContext, errorCode, errorMessage);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MqttReconnect" object:NULL];

  //  [[Messenger sharedMessenger] addLogMessage:@"Failed to connect!" type:@"Action"];
}
@end


// Disconnect Callbacks
@interface DisconnectCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation DisconnectCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
 //   [[Messenger sharedMessenger] addLogMessage:@"Disconnected from server!" type:@"Action"];
  //  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
 //   NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__,
   //       __LINE__, invocationContext, errorCode, errorMessage);
  //  [[Messenger sharedMessenger] addLogMessage:@"Failed to disconnect!" type:@"Action"];
}
@end

// Publish Callbacks
@interface PublishCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage;
@end
@implementation PublishCallbacks
- (void) onSuccess:(NSObject *) invocationContext
{
   // NSLog(@"PublishCallbacks - onSuccess");
}
- (void) onFailure:(NSObject *) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage
{
   // NSLog(@"PublishCallbacks - onFailure");
}
@end

// Subscribe Callbacks
@interface SubscribeCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation SubscribeCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    
    NSLog(@"SubscribeCallbacks - onSuccess %@",(NSString *)invocationContext);
   // NSString *topic = (NSString *)invocationContext;
   // [[Messenger sharedMessenger] addLogMessage:[NSString stringWithFormat:@"Subscribed to %@", topic] type:@"Action"];

   // AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
 }
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
  //  NSLog(@"SubscribeCallbacks - onFailure");
}
@end

// Unsubscribe Callbacks
@interface UnsubscribeCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation UnsubscribeCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
   // NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
  // NSString *topic = (NSString *)invocationContext;
   // [[Messenger sharedMessenger] addLogMessage:[NSString stringWithFormat:@"Unsubscribed to %@", topic] type:@"Action"];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
  //  NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__, __LINE__, invocationContext, errorCode, errorMessage);
}
@end

@interface GeneralCallbacks : NSObject <MqttCallbacks>
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage;
- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg;
- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId;
@end
@implementation GeneralCallbacks
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage
{
    NSLog(@"Conn lost mqtt");
    [[[Messenger sharedMessenger] subscriptionData] removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MqttReconnect" object:NULL];
    
   // AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
}

- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg
{
   // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *payload = [[NSString alloc] initWithBytes:msg.payload length:msg.payloadLength encoding:NSASCIIStringEncoding];
    NSData *crudo=[[NSData alloc] initWithBytes:msg.payload length:msg.payloadLength];
 //   NSLog(@"Payload Crudo %@",crudo);
    
    NSString *topic = msg.destinationName;
    payload=[[NSString alloc] initWithData:crudo encoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MqttMsg" object:payload];
/*
    NSLog(@"Message received for us topic %@ payload %@",topic,payload);
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] //1
                          
                          options:kNilOptions
                          error:&error];
    NSLog(@"Json received: %@ day %@",json,json[@"data"][@"time"][@"day"]);
    */
}

- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId
{
 //   NSLog(@"GeneralCallbacks - onMessageDelivered!");
}

@end


@implementation Messenger

@synthesize client,alerter,collect;

#pragma mark Singleton Methods

+ (id)sharedMessenger {
    static Messenger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.client = [MqttClient alloc];
        self.clientID = nil;
        self.client.callbacks = [[GeneralCallbacks alloc] init];
        self.logMessages = [[NSMutableArray alloc] init];
        self.subscriptionData = [[NSMutableArray alloc] init];
        libref=true;
        collect=NO;
    }
    return self;
}

- (void)connectWithHosts:(NSArray *)hosts ports:(NSArray *)ports clientId:(NSString *)clientId cleanSession:(BOOL)cleanSession
{
    client=nil;
    cb=nil;
    client=[MqttClient alloc];
        cb=[[ConnectCallbacks alloc] init];

        client = [client initWithHosts:hosts ports:ports clientId:clientId];
    ConnectOptions *opts = [[ConnectOptions alloc] init];
    opts.timeout = 10;
    opts.keepAliveInterval = 10;
    
    opts.cleanSession = cleanSession;
    NSLog(@"%s:%d host=%@, port=%@, clientId=%@", __func__, __LINE__, hosts, ports, clientId);
    [client connectWithOptions:opts invocationContext:self onCompletion:cb];
}

- (void)disconnectWithTimeout:(int)timeout {
    DisconnectOptions *opts = [[DisconnectOptions alloc] init];
    [opts setTimeout:timeout];
    
    [[self subscriptionData] removeAllObjects];
  //  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  //  [appDelegate reloadSubscriptionList];
    
    [client disconnectWithOptions:opts invocationContext:self onCompletion:[[DisconnectCallbacks alloc] init]];
}

- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained
{
  //  NSString *retainedStr = retained ? @" [retained]" : @"";
  //  NSString *logStr = [NSString stringWithFormat:@"[%@] %@%@", topic, payload, retainedStr];
 //   NSLog(@"%s:%d - %@", __func__, __LINE__, logStr);
 //   [[Messenger sharedMessenger] addLogMessage:logStr type:@"Publish"];
    
    MqttMessage *msg = [[MqttMessage alloc] initWithMqttMessage:topic payload:(char*)[payload UTF8String] length:(int)payload.length qos:qos retained:retained duplicate:NO];
    [client send:msg invocationContext:self onCompletion:[[PublishCallbacks alloc] init]];
}

- (void)subscribe:(NSString *)topicFilter qos:(int)qos
{
    NSLog(@"%s:%d topicFilter=%@, qos=%d", __func__, __LINE__, topicFilter, qos);
    [client subscribe:topicFilter qos:qos invocationContext:topicFilter onCompletion:[[SubscribeCallbacks alloc] init]];

    Subscription *sub = [[Subscription alloc] init];
    sub.topicFilter = topicFilter;
    sub.qos = qos;
    [self.subscriptionData addObject:sub];
}

- (void)unsubscribe:(NSString *)topicFilter
{
 //   NSLog(@"%s:%d topicFilter=%@", __func__, __LINE__, topicFilter);
    [client unsubscribe:topicFilter invocationContext:topicFilter onCompletion:[[UnsubscribeCallbacks alloc] init]];
    
    NSUInteger currentIndex = 0;
    for (id obj in self.subscriptionData) {
        if ([((Subscription *)obj).topicFilter isEqualToString:topicFilter]) {
            [self.subscriptionData removeObjectAtIndex:currentIndex];
            break;
        }
        currentIndex++;
    }
}




@end