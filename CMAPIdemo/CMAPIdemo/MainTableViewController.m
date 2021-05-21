//
//  MainTableViewController.m
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/20.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import "MainTableViewController.h"
#import "DisconnectTableViewCell.h"
#import "informationTableViewCell.h"
#import "networkTableViewCell.h"
#import "deviceTableViewCell.h"
#import "DeviceViewController.h"
#import "Global.h"
#import <CMAPIAPPSDK/cmapiApp.h>
#import "MBProgressHUD.h"
@interface MainTableViewController ()<CmapiAppNotifyDelegate>
@end

@implementation MainTableViewController{
    NSArray * _infomationNameArr;
    NSTimer *  _reloadTimer;
    CONNECTION_STAT current_status;
    NSString *networkCurrentName;
    NSString *networkCurrentID;
    int duration; //登录时长
    int latency;    //网络延时
    NSMutableArray *networkListArray;
    NSMutableArray *devicesListArray;;
    MBProgressHUD * _hud;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:@"kStatusChangeNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _infomationNameArr = @[@"Network",@"OnlineTime",@"NetLatency"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    duration = 0;
    //循环获取连接数据
    _reloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                    target:self
                                                  selector:@selector(reloadStatus)
                                                  userInfo:nil
                                                   repeats:YES];

    [self getnetworkList];
    [self getDevicesList];
    
    [self getBaseinfo];

    [cmapiApp sharedInstance].networkChangeDelegate = self;
    [cmapiApp sharedInstance].deviceChangeDelegate = self;
    [cmapiApp sharedInstance].switchCompleteDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChangeNotification:) name:@"kStatusChangeNotification" object:nil];
}


- (void)getBaseinfo {
    [[cmapiApp sharedInstance] getBaseInfo:^(NSDictionary *result) {
        NSLog(@"MaintableVC getbaseinfo result = %@",result);
    }];
}

#pragma mark 获取信息（网络列表信息，设备列表信息）
- (void)getnetworkList {

    NSMutableArray *listArray = [NSMutableArray array];
    [[cmapiApp sharedInstance] getNetworkList:^(NSDictionary *result) {
        NSArray *dataArray = [result objectForKey:@"data"];
        networkCurrentID = [result objectForKey:@"netid"];
        if (networkCurrentID && dataArray.count > 0) {
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDic = dataArray[i];
                NSString *idStr = [dataDic objectForKey:@"id"];
                if (idStr != nil && [idStr isEqualToString:networkCurrentID]) {
                    //当前的网络名称
                    networkCurrentName = [dataDic objectForKey:@"name"];
                }
                //获取网络列表
                networkItem *item = [[networkItem alloc] init];
                item.Id = [dataDic objectForKey:@"id"];
                item.name = [dataDic objectForKey:@"name"];
                item.owner = [dataDic objectForKey:@"owner"];
                [listArray addObject:item];
            }
        }
        networkListArray = [NSMutableArray arrayWithArray:listArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
}

- (void)getDevicesList {

    NSMutableArray *devlistArray = [NSMutableArray array];
    NSMutableArray *smartNodlistArray = [NSMutableArray array];
    [[cmapiApp sharedInstance] getDeviceList:^(NSDictionary *result) {
        NSLog(@"deviceslist result = %@",result);
        if (nil != [result objectForKey:@"devices"] &&
            [[result objectForKey:@"devices"] isKindOfClass:[NSArray class]]) {
            NSArray *node_devices = [result objectForKey:@"devices"];
            for (NSDictionary *device in node_devices) {
                deviceItem *item = [[deviceItem alloc] init];
                item.Id = [device objectForKey:@"id"];
                item.owner = [device objectForKey:@"owner"];
                item.userid = [device objectForKey:@"userid"];
                item.domain = [device objectForKey:@"domain"];
                item.adDomain = [device objectForKey:@"ad_domain"];
                item.name = [device objectForKey:@"name"];
                item.deviceClass = [[device objectForKey:@"device_class"] intValue];
                item.vip = [device objectForKey:@"vip"];
                item.pubip = [device objectForKey:@"pubip"];
                item.ver = [device objectForKey:@"ver"];
                item.feature = [[device objectForKey:@"feature"] intValue];
                item.dlt = [device objectForKey:@"dlt"];
               
                [devlistArray addObject:item];
            }
        }
    
        devicesListArray = [NSMutableArray arrayWithArray:devlistArray];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData];
        });
        
    }];
}

-(void)statusChangeNotification:(NSNotification *)note {
    NSDictionary *dic = note.object;
    CONNECTION_STAT status = (CONNECTION_STAT)[dic[@"status"] integerValue];
    int dr = [dic[@"dissconnectDr"] intValue];
    NSLog(@"tostatus view. status : %d, dr : %ld",status,(long)dr);
    NSLog(@"tostatus view = %d",status);
    current_status = status;
    if (CCS_CONNECTED == status){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hideAnimated:YES];
            [self getnetworkList];
            [self getDevicesList];

        });
    }else if (CCS_DISCONNECTING == status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            _hud.label.text = @"正在断开连接...";
            
        });
    }
    else if (CCS_WAIT_RECONNECTING == status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            _hud.label.text = @"正在重新连接...";
            
        });
    }
    else if (CCS_DISCONNECTED == status) { //断开连接或者正在登录状态，回退倒登录界面
        [_reloadTimer invalidate];
        _reloadTimer = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hideAnimated:YES];
            [cmapiApp sharedInstance].networkChangeDelegate = nil;
            [cmapiApp sharedInstance].deviceChangeDelegate = nil;
            [cmapiApp sharedInstance].switchCompleteDelegate = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void) deviceChangeNotify:(NSDictionary *)deviceInfoDic {
    NSLog(@"设备状态信息变更 ： %@,%@",networkCurrentName,deviceInfoDic);
    //device
    int haveSameID = -1;
    if (devicesListArray.count > 0) {
        
        for (int i = 0; i < devicesListArray.count; i++) {
            deviceItem *subDevicesList = devicesListArray[i];
            if ([subDevicesList.Id isEqualToString:[deviceInfoDic objectForKey:@"id"]]) {
                haveSameID = i;
                break;
            }
        }

    }
    deviceItem *devItem = [self setDevicesItem:deviceInfoDic];
    if ( haveSameID != -1) {
        devicesListArray[haveSameID] = devItem;
    }else {
        [devicesListArray addObject:devItem];
    }

}

- (deviceItem *)setDevicesItem:(NSDictionary *)deviceInfoDic {
    deviceItem *item = [[deviceItem alloc] init];
    item.deviceClass = [[deviceInfoDic objectForKey:@"device_class"] intValue];
    item.deviceType = [[deviceInfoDic objectForKey:@"device_type"] intValue];
    item.dlt = [deviceInfoDic objectForKey:@"dlt"];
    item.domain = [deviceInfoDic objectForKey:@"domain"];
    item.feature = [[deviceInfoDic objectForKey:@"feature"] intValue];
    item.Id = [deviceInfoDic objectForKey:@"id"];
    item.name = [deviceInfoDic objectForKey:@"name"];
    item.owner = [deviceInfoDic objectForKey:@"owner"];
    item.privip = [deviceInfoDic objectForKey:@"privip"];
    item.pubip = [deviceInfoDic objectForKey:@"pubip"];
    item.status = [deviceInfoDic objectForKey:@"status"];
    item.userid = [deviceInfoDic objectForKey:@"userid"];
    item.adDomain = [deviceInfoDic objectForKey:@"ad_domain"];
    item.vip = [deviceInfoDic objectForKey:@"vip"];
    item.ver = [deviceInfoDic objectForKey:@"ver"];
    item.subnet = [deviceInfoDic objectForKey:@"subnet"];
    return item;
}

- (void)switchNetworkCompleteNotify:(int)errorCode {
    if (errorCode == 0) {
        NSLog(@"网络切换完成");
        [devicesListArray removeAllObjects];
        [self getnetworkList];
    }else {
        NSLog(@"网络切换失败");
    }
    
}

- (void) networkChangeNotify {
    NSLog(@"虚拟网网络变更");
    [devicesListArray removeAllObjects];
    [self getnetworkList];
    [self getDevicesList];
}

//刷新连接信息数据
- (void) reloadStatus {
 
    NSIndexPath *indexPath_network= [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPath_uptime = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPath_latency = [NSIndexPath indexPathForRow:3 inSection:0];
    
    informationTableViewCell *cell_network = [self.tableView cellForRowAtIndexPath:indexPath_network];
    informationTableViewCell *cell_latency = [self.tableView cellForRowAtIndexPath:indexPath_latency];
    informationTableViewCell *cell_uptime = [self.tableView cellForRowAtIndexPath:indexPath_uptime];
    
  
    [[cmapiApp sharedInstance] getStatusInfo:^(NSDictionary *result) {
        NSDictionary *dataDic = [result objectForKey:@"data"];
        if (dataDic) {
            duration = [[dataDic objectForKey:@"duration"] intValue];
            NSDictionary *network_statusDic = [dataDic objectForKey:@"network_status"];
            if (network_statusDic) {
                latency = [[network_statusDic objectForKey:@"latency"] intValue];
            }
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *refresh_cells = [[NSMutableArray alloc] init];
        
        if (nil != cell_network) {
            NSString *comp = cell_network.contextLabel.text;
            if (nil == networkCurrentName || nil == comp || ![networkCurrentName isEqualToString:comp]) {
                cell_network.contextLabel.text = networkCurrentName;
                [refresh_cells addObject:indexPath_network];
            }
        }
        
        if (nil != cell_uptime) {
            if (duration != 0) {
                cell_uptime.contextLabel.text = [self calcUptime:duration];
                [refresh_cells addObject:indexPath_uptime];
            }
        }
        if (nil != cell_latency) {
            int comp = cell_latency.intValue;

            if (latency != comp) {
                cell_latency.contextLabel.text = [NSString stringWithFormat:@"%d ms", latency];
                [refresh_cells addObject:indexPath_latency];
            }
        }
        
        
        if ([refresh_cells count] > 0){
            [self.tableView reloadData];
        }
    });
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return networkListArray.count;
            break;
        case 2:
            return devicesListArray.count;
            break;
        default:
            return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    backView.backgroundColor = [UIColor whiteColor];
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:24];
    [backView addSubview:titleLabel];
    [titleLabel setCenter:backView.center];
    switch (section) {
        case 0:
            titleLabel.text = @"CMAPI SDK Demo";
            break;
        case 1:
            titleLabel.text = @"Networks";
            break;
        case 2:
            titleLabel.text = @"Devices";
            break;

        case 3:
            titleLabel.text = @"text";
        default:
            break;
    }
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //断开连接 与 连接信息展示
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString * disconnectidentifier = @"disconnectIdentifier";
            
            DisconnectTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:disconnectidentifier];
            if (cell == nil) {
                cell = [tableView dequeueReusableCellWithIdentifier:disconnectidentifier
                                                       forIndexPath:indexPath];
            }
            return cell;
        }
        else{
            static NSString * infomationidentifier = @"informationIdentifier";
            
            informationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:infomationidentifier];
            if (cell == nil) {
                cell = [tableView dequeueReusableCellWithIdentifier:infomationidentifier
                                                       forIndexPath:indexPath];
            }
            cell.nameLabel.text = [NSString stringWithFormat:@"%@",_infomationNameArr[indexPath.row-1]];
            switch (indexPath.row) {
                case 1:
                    cell.contextLabel.text = networkCurrentName;
                    break;
                case 2:
                    cell.contextLabel.text = [self calcUptime:duration];
                    break;
                case 3:
                    cell.contextLabel.text = [NSString stringWithFormat:@"%d ms",latency];
                    break;
                default:
                    break;
            }
            return cell;
        }
    }
    //网络列表
    else if (indexPath.section == 1){
        static NSString * networkidentifier = @"networkIdentifier";
        
        networkTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:networkidentifier];
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:networkidentifier
                                                   forIndexPath:indexPath];
        }
        networkItem * item = networkListArray[indexPath.row];
        cell.networkNameLabel.text = item.name;
        if ([networkCurrentID isEqualToString:item.Id])
            cell.currentLabel.hidden = NO;
        else
            cell.currentLabel.hidden = YES;
        return cell;
        
    }
     //设备列表
    else {
        static NSString * deviceidentifier = @"deviceIdentifier";
        
        deviceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:deviceidentifier];
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:deviceidentifier
                                                   forIndexPath:indexPath];
        }
        deviceItem * item = [devicesListArray objectAtIndex:indexPath.row];
        cell.deviceNameLabel.text = item.name;
        cell.iconImageView.image =[UIImage imageNamed:@"icon_device"];
        cell.smartNodeSelectedImg.hidden = YES;
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        networkItem *item = [networkListArray objectAtIndex:indexPath.row];
        if ([networkCurrentID isEqualToString:item.Id])
            return;
        //切换网络
        [self switchNetwork:item.Id];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//切换网络实现方法
- (void) switchNetwork:(NSString *)Id {

    [[cmapiApp sharedInstance] switchNetwork:Id completion:^(NSDictionary *result) {
        
    }];
}

//连接时长
- (NSString *) calcUptime:(int)timestamp {
    int seconds = (int) (timestamp);
    int hours = (int) (seconds / 3600);
    seconds -= (hours * 3600);
    int minutes = (int) (seconds / 60);
    seconds -= (minutes * 60);
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

//跳转到设备或者节点详情数据页
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"devicepushIdentifier"]) {
        deviceTableViewCell * cell = (deviceTableViewCell *)sender;
        DeviceViewController *receive = segue.destinationViewController;
        
        NSIndexPath * inde = [self.tableView indexPathForCell:cell];
        deviceItem *item;

        item = [devicesListArray objectAtIndex:[self.tableView indexPathForCell:cell].row];
        receive.smartFlag = NO;
        
        receive.item = item;
        
        
    }
    
}


@end
