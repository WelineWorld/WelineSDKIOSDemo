//
//  DisconnectTableViewCell.m
//  CMAPIdemo
//
//  Created by L-wh on 2017/11/21.
//  Copyright © 2017年 L-wh. All rights reserved.
//

#import "DisconnectTableViewCell.h"
#import <CMAPIAPPSDK/cmapiApp.h>
@implementation DisconnectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
static int count = 0;
- (IBAction)disconnectClick:(id)sender {

    [[cmapiApp sharedInstance] stopLogin];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
