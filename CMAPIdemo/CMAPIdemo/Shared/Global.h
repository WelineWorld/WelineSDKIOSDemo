//
//  Global.h
//  Cifernet
//
//  Created by Eric Tang on 17/1/6.
//  Copyright © 2017年 Cifernet Inc. All rights reserved.
//
#ifndef Global_h
#define Global_h

@interface deviceItem : NSObject

@property (nonatomic, assign) int deviceType;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *owner;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *adDomain;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int deviceClass;
//@property (nonatomic, assign) int osType;
@property (nonatomic, copy) NSString *vip;
@property (nonatomic, copy) NSString *pubip;
@property (nonatomic, copy) NSString *ver;
@property (nonatomic, assign) int feature;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic , copy) NSArray * subnet;
@property (nonatomic , copy) NSDictionary * dlt;
//@property (nonatomic, assign) BOOL dlt;
//@property (nonatomic, assign) int devClass;
@property (nonatomic, copy) NSString *privip;
@property (nonatomic,copy) NSString *status;
@property (nonatomic , assign) BOOL ManufacturerFlag; //是否按新版设备类型判断 YES:按照新版类型判断（根据deviceOSType字段判断 DEVICE_OS_TYPE 枚举） NO:按照旧版类型判断（根据osType字段判断 OS_TYPE 枚举）
@property (nonatomic ,assign) int deviceOSType; //新版设备类型
@property (nonatomic , assign) int deviceSubType; //新版设备子类型
@property (nonatomic , assign) int manufacturerType; //新版设备供应商

@end

@interface dltItem : NSObject
@property (nonatomic, assign) BOOL dltStatus;
@property (nonatomic, assign) int algoLevel;
@property (nonatomic, assign) int dltClass;
@property (nonatomic, copy) NSString *peerIp;
@property (nonatomic, assign) int peerPort;

@end

@interface networkItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *owner;

@end
#endif /* Global_h */
