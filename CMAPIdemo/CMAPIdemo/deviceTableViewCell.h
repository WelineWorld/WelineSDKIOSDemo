//
//  deviceTableViewCell.h
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/21.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface deviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smartNodeSelectedImg;

@end
