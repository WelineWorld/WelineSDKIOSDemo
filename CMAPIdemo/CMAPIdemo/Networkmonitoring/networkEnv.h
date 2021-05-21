//
//  networkEnv.h
//  testipv6
//
//  Created by Eric Tang on 2017/9/22.
//  Copyright © 2017年 Cifernet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _NEIPStack {
  NEIS_Unkown = 0,
  NEIS_IPv4   = 1,
  NEIS_IPv6   = 2,
  NEIS_Dual   = 3,
} NEIPStack;

@interface networkEnv : NSObject

-(NEIPStack) checkIPStack;

@end
