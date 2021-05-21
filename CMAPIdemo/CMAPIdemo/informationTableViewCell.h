//
//  informationTableViewCell.h
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/21.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface informationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;
@property (nonatomic, assign) int intValue;

@end
