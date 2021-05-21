//
//  ViewController.m
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/20.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import "ViewController.h"

#define EMPTY_PASSWORD @"CIFERNET%PASSBY"
#define kNetworkCheckpoint @"http://www.memenet.net"
#import "HUD/MBProgressHUD.h"
#import <CMAPIAPPSDK/cmapiApp.h>
#import "MainTableViewController.h"
#import "AFNetworking/AFNetworkReachabilityManager.h"




@import CoreTelephony;

@interface ViewController ()<CmapiAppNotifyDelegate>{
    NSUserDefaults *_user_defaults;
    dispatch_queue_t _thread_queue;
    MBProgressHUD * _hud;
}
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;


@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getNetworkpermissions];
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"network status = 未知网络");
                
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                NSLog(@"network status = 没有网络(断网)");
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"network status = 手机自带网络");
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                NSLog(@"network status = WIFI");
                
                break;
        }
    }];
    [self accessNetwork];
    
    //设置配置信息
    [cmapiApp sharedInstance].kVPNId = @"CMAPIs SDVN";
    [cmapiApp sharedInstance].kProviderBundleid = @"net.memenet.CMAPIdemo3.provider";
    [cmapiApp sharedInstance].kServerAddr = @"as.memenet.net";
    [cmapiApp sharedInstance].statusDelegate = self;

    //设置配置 获取缓存数据
    [self createProviderSDK];

    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (IBAction)keydownClick:(id)sender {
    [self.view endEditing:YES];
}

-(void)showMessage:(NSString *)message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Title"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //响应事件
                                                              [self createProviderSDK];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)getNetworkpermissions{
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state)
    { //获取联网状态 switch (state)
        switch (state) {
                
            case kCTCellularDataRestricted:{
                NSLog(@"Restricrted");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCALIZESTRING(@"Network_access_title") message:[NSString stringWithFormat:@"%@\"%@\"%@\"%@\"%@",LOCALIZESTRING(@"Network_access_Message_One"),app_Name,LOCALIZESTRING(@"Network_access_Message_Two"),app_Name,LOCALIZESTRING(@"Network_access_Message_Three")] preferredStyle:UIAlertControllerStyleAlert];
                    alertController.popoverPresentationController.sourceView = self.view;
                    alertController.popoverPresentationController.sourceRect = self.view.bounds;
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LOCALIZESTRING(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            }break;
            case kCTCellularDataNotRestricted: {
                NSLog(@"Not Restricted");
            }break;
                //未知，第一次请求
            case kCTCellularDataRestrictedStateUnknown: {
                NSLog(@"Unknown");
            }break;
            default: break;
        };
    };
    
}


- (void) accessNetwork {
    //    if (YES == [self isFirstRunning]) {
    NSURL *url = [NSURL URLWithString:kNetworkCheckpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:5];
    request.HTTPMethod = @"HEAD";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (data && !error) {
                                             NSLog(@"apps reachable.");
                                         } else {
                                             NSLog(@"apps unreachable.");
                                         }
                                     }] resume];
}



- (void)createProviderSDK {
    
    [[cmapiApp sharedInstance] createSessionWithCompletionHandler:^(BOOL result) {
        if (YES == result) {
             [[cmapiApp sharedInstance] getBaseInfo:^(NSDictionary *result) {
                NSLog(@"createProviderSDK result = %@",result);
                //获取缓存帐号
                if (result) {
                    NSDictionary *informationDic = [result objectForKey:@"information"];
                    NSString *current_account = [informationDic objectForKey:@"account"];
                    
                    if (nil != current_account && ![current_account isEqualToString:@""]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.accountTextField.text = current_account;
                            self.passwordTextfield.text = EMPTY_PASSWORD;
                        });
                        
                        CONNECTION_STAT status = [[informationDic objectForKey:@"status"] intValue];
                        NSLog(@"current status: %d", status);
                        if (CCS_CONNECTED == status){
                            [self transferToMainPage];
                        }
                        else if (CCS_CONNECTING == status) {
                            _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
                            _hud.label.text = @"连接中...";
                        }
                    } else {
                    }
                }
            }];
        } else { // 如果返回NO，则表示用户没有选择 "Allow" ?
            [self showError:@"请在授权框中选择 Allow." handler:^(UIAlertAction *action) {
            }];
        }
    }];
}

- (void) showError:(NSString *)msg handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCALIZESTRING(@"error")
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.popoverPresentationController.sourceView = _btnLogin;
    alertController.popoverPresentationController.sourceRect = _btnLogin.bounds;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LOCALIZESTRING(@"ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

//登录
- (IBAction)loginClick:(id)sender {

    NSString *textAccount = self.accountTextField.text;
    NSString *textPassword = self.passwordTextfield.text;
    if ([textPassword isEqualToString:@""] || [textPassword isEqualToString:EMPTY_PASSWORD])
        textPassword = nil;
        //调用登录接口
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            _hud.label.text = @"连接中...";
            [[cmapiApp sharedInstance] loginWithAccount:textAccount password:textPassword];
        });
}


- (void)statusChange:(CONNECTION_STAT)status Dr:(int)dr {
    NSLog(@"tostatus view = %d",status);
    if (CCS_CONNECTING == status) {
        
    }else if (CCS_CONNECTED == status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hideAnimated:YES];
        });
        [self transferToMainPage];
        
        NSLog(@"connected. get dlt enabel : %d, get current dlt : %d", [[cmapiApp sharedInstance] isGlobalDltEnabel],[[cmapiApp sharedInstance] isGlobalDlt]);
        
    }else if(CCS_DISCONNECTED == status) {
        [self dismissHUDWithReason:dr];
    }
    
    NSDictionary *dic = @{@"status":[NSString stringWithFormat:@"%d",status],@"dissconnectDr":[NSString stringWithFormat:@"%d",dr]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusChangeNotification" object:dic];
}

- (void) dismissHUDWithReason:(int)reason {
    NSLog(@"Disconnect Reason: %d", reason);
    NSString *errmsg = nil;
    switch (reason) {
        case DR_MISVERSION:
            errmsg = LOCALIZESTRING(@"dr_misversion"); break;
        case DR_INVALID_USER:
            errmsg = LOCALIZESTRING(@"dr_invalid_user"); break;
        case DR_INVALID_PASS:
            errmsg = LOCALIZESTRING(@"dr_invalid_pass"); break;
        case DR_DEVICE_DELETED:
            errmsg = LOCALIZESTRING(@"dr_device_deleted"); break;
        case DR_DEVICE_ONLINE:
            errmsg = LOCALIZESTRING(@"dr_device_online"); break;
        case DR_DEVICE_DISABLED:
            errmsg = LOCALIZESTRING(@"dr_device_disabled"); break;
        case DR_MAX_DEVICE:
            errmsg = LOCALIZESTRING(@"dr_max_device"); break;
        case DR_AUX_AUTH_DISMATCH:
            errmsg = LOCALIZESTRING(@"dr_aux_auth_dismatch"); break;
        case DR_NETWORK_UNUSABLE:
            errmsg = LOCALIZESTRING(@"dr_network_unusable"); break;
    }
    if (nil == errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hideAnimated:YES];
        });
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hideAnimated:YES];
            _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            _hud.label.text = [NSString stringWithFormat:@"DisconnectReason：%d",reason];
            [_hud hideAnimated:YES afterDelay:3];
        });
    }
}

//跳转到主页面
- (void) transferToMainPage {
    NSLog(@"Transfer to Main Page.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"GotoMainViewSegue" sender:self];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
