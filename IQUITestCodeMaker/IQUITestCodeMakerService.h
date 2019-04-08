//
//  IQUITestCodeMakerService.h
//  IQUITestCodeMaker
//
//  Created by yishu.zd on 2019/1/17.
//

#import <Foundation/Foundation.h>
#import "IQUITestProtocol.h"

@class IQUITestCodeMakerFactory,GCDWebServer;

void IQRuntimeMethodExchange(Class aClass, SEL oldSEL, SEL newSEL);

@interface IQUITestCodeMakerService : NSObject<IQUITestProtocol>

@property (nonatomic, strong, readonly) IQUITestCodeMakerFactory *factory;
@property (nonatomic, strong, readonly) GCDWebServer *webServer;
@property (nonatomic, strong) NSHashTable *hashTable;

+ (instancetype)sharePersistent;
- (void)hook;
- (void)handleConvertTaskWithIdentifier:(NSString *)identifier;
- (void)handleCapChangeTaskWithKey:(NSString *)key value:(NSString *)value;
- (void)handleRecordControlEventWithState:(BOOL)state;

@end
