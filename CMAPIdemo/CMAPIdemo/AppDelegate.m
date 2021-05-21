//
//  AppDelegate.m
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/28.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import "AppDelegate.h"
#import <CMAPIAPPSDK/CMAPIAPPSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self redirectNSlogToDocumentFolder];
    return YES;
}

- (void)redirectNSlogToDocumentFolder
{
    //先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * tempPath = [[array objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Database/"]];
    NSString * pathStr = [tempPath stringByAppendingPathComponent:@"dr.log"];
    NSLog(@"{sdvn} provider init. file : %d，tempPath = %@",[defaultManager fileExistsAtPath:tempPath],tempPath);
    if (![defaultManager fileExistsAtPath:tempPath]) {
        NSError *error = nil;
        [defaultManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // 将log输入到文件
    freopen([pathStr cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
    freopen([pathStr cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[cmapiApp sharedInstance] stopLogin];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
