//
//  DeviceViewController.h
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/21.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
@interface DeviceViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong , nonatomic) deviceItem * item;

@property (assign , nonatomic) BOOL  smartFlag;
@end
