//
//  DeviceViewController.m
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/21.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import "DeviceViewController.h"
#import "informationTableViewCell.h"
#import "SelectTableViewCell.h"


@interface DeviceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation DeviceViewController{
    NSArray * _deviceInfoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceInfoArr = @[@"Name",@"Domain",@"IP",@"Owner",@"Version"];

}
- (IBAction)dismissClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark-UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString * infomationidentifier = @"informationIdentifier";
        
        informationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:infomationidentifier];
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:infomationidentifier
                                                   forIndexPath:indexPath];
        }
        cell.nameLabel.text = [NSString stringWithFormat:@"%@",_deviceInfoArr[indexPath.row]];
        switch (indexPath.row) {
            case 0:
                cell.contextLabel.text = _item.name;
                break;
            case 1:
                cell.contextLabel.text = _item.domain;
                break;
            case 2:
                cell.contextLabel.text = _item.vip;
                break;
            case 3:
                cell.contextLabel.text = _item.owner;
                break;

            default:
                break;
        }
        return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



@end
