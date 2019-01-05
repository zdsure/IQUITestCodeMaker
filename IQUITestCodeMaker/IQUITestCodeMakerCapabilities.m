//
//  IQUITestCodeMakerCapabilities.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestCodeMakerCapabilities.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *const kCapabilitiesKey = @"kCapabilitiesKey";

@implementation IQUITestCodeMakerCapabilities

- (instancetype)init {
    if (self = [super init]) {
//        IQCapabilities *cap = [IQCapabilities new];
//        self.capbilities  = cap;
        
        NSDictionary *localCapDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
        if (localCapDic) {
            IQCapabilities *localCap = [IQCapabilities new];
            for (NSString *key in localCapDic.allKeys) {
                [localCap setValue:localCapDic[key] forKey:key];
            }
            self.capbilities = localCap;
        } else {
            IQCapabilities *cap = [IQCapabilities new];
            self.capbilities  = cap;
        }
    }
    return self;
}

- (void)setCapbilities:(IQCapabilities *)capbilities {
    if (capbilities) {
        _capbilities = capbilities;
    }
    /*更新本地缓存
     1.将model转换成NSDictonary存入本地。
     */
    NSDictionary *cacheCap = [self convertModelToDict:_capbilities];
    [[NSUserDefaults standardUserDefaults] setObject:cacheCap forKey:kCapabilitiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)capbilitiesFromCache {
    NSDictionary *localCapDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
    return localCapDic;
}

/*只能处理简单属性*/
- (NSDictionary *)convertModelToDict:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([object class], &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        [dic setValue:[object valueForKey:name] forKey:name];
    }
    
    return [dic copy];
}

@end

@implementation IQCapabilities : NSObject

- (instancetype)init {
    if (self = [super init]) {
        _platformName       = @"iOS";
        _platformVersion    = [UIDevice currentDevice].systemVersion;
        _deviceName         = [UIDevice currentDevice].name;
        _udid               = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        _app                = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        _language           = @"Totoro";
        _waitTime           = @"1";
        _automationName     = @"XCUITest";
    }
    return self;
    
}

@end


