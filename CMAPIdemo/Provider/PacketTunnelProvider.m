//
//  PacketTunnelProvider.m
//  Provider
//
//  Created by L-wh on 2017/11/20.
//Copyright © 2017年 L-wh. All rights reserved.
//

#define DC_COMMON_IOS  0

#import "PacketTunnelProvider.h"
#import <CMAPISDK/cmapi.h>
#import <UserNotifications/UserNotifications.h>


@interface PacketTunnelProvider ()
@property (nonatomic, strong)  cmapi * cmapi;
@end

@implementation PacketTunnelProvider

- (instancetype) init {
    self = [super init];
    NSLog(@"provide init");
    if (self) {
        if (nil == _cmapi) {
            //初始化并设置AppID 、AppKey、PartnerID
            _cmapi = [[cmapi alloc] initLibraryWithAppID:@"" withPartnerID:@"" withDevClass:DC_COMMON_IOS  AndProvider:self AndDnsDivert:NO];
            [self registUserNotificationCenter];
        }
    }
    return self;
}

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler
{
    //获取UI进程传递的帐号数据
    if (nil != options) {
        NSArray *optionsKey = [options allKeys];
        BOOL ifFake = NO;
        for (NSString *key in optionsKey) {
            if ([key isEqualToString:@"isFake"]) {
                ifFake = YES;
                break;
            }
        }
        if (ifFake) {
            [_cmapi fakeConnectionWithCompletionhandler:completionHandler];
        }else   [_cmapi startConnectionWithOptions:options completionHandler:completionHandler];
    }else{
         [_cmapi startConnectionWithOptions:nil completionHandler:completionHandler];
    }
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"provider stop");
    [_cmapi stopTunnel:completionHandler];
    if (reason == NEProviderStopReasonSuperceded || reason == NEProviderStopReasonConfigurationDisabled) {
        NSLog(@"{sdvn} provider stop NEProviderStopReasonSuperceded");
        [self createLocationNotification];
    }
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
    [_cmapi processAppMessage:messageData completion:completionHandler];
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
    // Add code here to get ready to sleep
    completionHandler();
}

- (void)wake
{
    // Add code here to wake up
}

- (void)registUserNotificationCenter {
    //注册通知
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"request authorization successed!");
        }
    }];
    //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"%@",settings);
    }];
}

-(void)createLocationNotification {
    [self locationNotifcation];
}

-(void)locationNotifcation{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //请求获取通知权限（角标，声音，弹框）
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //获取用户是否同意开启通知
            NSLog(@"request authorization successed!");
        }
    }];
    
    //第二步：新建通知内容对象
    
    UNMutableNotificationContent *umnot =[[UNMutableNotificationContent alloc] init];
    umnot.title = @"";
    umnot.subtitle = @"";
    umnot.body = @"因为系统VPN已被其它APP占用，当前链路已断开";
    umnot.badge = @-1;
    //    UNNotificationSound *sound = [UNNotificationSound soundNamed:@"caodi.m4a"];
    //    umnot.sound = sound;
    
    //第三步：通知触发机制。（重复提醒，时间间隔要大于60s）
    UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    //第四步：创建UNNotificationRequest通知请求对象
    NSString *requertIdentifier = @"RequestIdentifier";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requertIdentifier content:umnot trigger:trigger1];
    
    //第五步：将通知加到通知中心
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error:%@",error);
        
    }];
    
}




@end
