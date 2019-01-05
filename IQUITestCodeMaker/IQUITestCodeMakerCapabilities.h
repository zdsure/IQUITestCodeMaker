//
//  IQUITestCodeMakerCapabilities.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IQCapabilities;

@interface IQUITestCodeMakerCapabilities : NSObject

@property (nonatomic, strong) IQCapabilities  *capbilities;

@end

@interface IQCapabilities : NSObject

@property (nonatomic, copy) NSString *platformName;/*iOS*/
@property (nonatomic, copy) NSString *platformVersion;/*9.3~11.4*/
@property (nonatomic, copy) NSString *deviceName;/*iPhone 6s ..*/
@property (nonatomic, copy) NSString *udid;/*device id*/
@property (nonatomic, copy) NSString *app;/*app path*/
@property (nonatomic, copy) NSString *language;/*Totoro default*/
@property (nonatomic, copy) NSString *waitTime;/*find element timeout,10s default*/
@property (nonatomic, copy) NSString *automationName;/*XCUITest default*/

@end

