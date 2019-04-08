//
//  IQUITestCodeMakerService.m
//  IQUITestCodeMaker
//
//  Created by yishu.zd on 2019/1/17.
//

#import "IQUITestCodeMakerService.h"
#import "IQUITestCodeMaker.h"
#import "IQUITestOperationEvent.h"
#import "IQUITestCodeMakerFactory.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "IQUITestDebugBall.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "GCDWebServer.h"
#import <CNUIInspector/CNUIInspectorService.h>

static IQUITestCodeMakerService *persistent = nil;
static NSString *const kCapabilitiesKey = @"kCapabilitiesKey";

#pragma mark--CodeGenerator--
void IQTapTaskWithId(NSString *identifier) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.eventType = IQUIEventTap;
    op.identifier= identifier;
    
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}

void IQTapTaskWithPoint(CGPoint point) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.locateStrategy = IQElementLocateByCoordinate;
    op.eventType = IQUIEventTap;
    op.touchPoint = point;
    
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}

void IQScrollTask(CGPoint pstart , CGPoint pEnd) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.eventType = IQUIEventSwipe;
    op.touchesBegan = pstart;
    op.touchesEnded = pEnd;
    
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}

void IQInputTask(NSString *identifier,NSString *content) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.eventType = IQUIEventSendKey;
    op.identifier = identifier;
    op.value = content;
    
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}


#pragma mark--IQUITestCodeMakerService--
@interface IQUITestCodeMakerService ()<GCDWebServerDelegate,CNInspectorExportProtocol>

@property (nonatomic, strong, readwrite) IQUITestCodeMakerFactory *factory;
@property (nonatomic, strong, readwrite) GCDWebServer *webServer;

@end

@implementation IQUITestCodeMakerService

+ (instancetype)sharePersistent {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistent = [[IQUITestCodeMakerService alloc]init];
        
    });
    return persistent;
}

- (void)hook {
    [[CNUIInspectorService sharedInstance] enableCustomIdentifier];
    [[CNUIInspectorService sharedInstance] setIdentifierDepth:1];
    [[CNUIInspectorService sharedInstance] enableInspector];
    [[CNUIInspectorService sharedInstance] addDelegate:self];
//    [[CNUIInspectorService sharedInstance] setJustCareHittestView:YES];
}

#pragma mark --CNInspectorExport delegate--
- (void)didReceiveOperationInfo:(NSDictionary *)info {
    if (info) {
        NSString *actionType = [info objectForKey:@"type"];
        NSDictionary *innerDictionary = [info objectForKey:@"params"];
        //去除debugBall的hook
//        if (innerDictionary) {
//            NSString *pageIdentifier = [innerDictionary objectForKey:@"pageIdentifier"];
//            if(DebugView(pageIdentifier)){
//                return;
//            }
//            NSString *type = [innerDictionary objectForKey:@"type"];
//            if(type && DebugView(type)){
//                return;
//            }
//            NSString *identifier = [innerDictionary objectForKey:@"identifier"];
//            if([identifier hasPrefix:@"debugTable"]){
//                return;
//            }
//        }
        //点击事件
        if (innerDictionary && [actionType isEqualToString:@"CNInspectorTap"]) {
            NSString *identifier = [innerDictionary objectForKey:@"identifier"];
            CGPoint point = CGPointFromString([innerDictionary objectForKey:@"ponit"]);
            NSNumber *isWebView =  [innerDictionary objectForKey:@"isWeb"];
            if(isWebView ==  [NSNumber numberWithInt:1]){
                IQTapTaskWithPoint(point);
            }else{
                IQTapTaskWithId(identifier);
            }
        }
        //滑动事件
        if (innerDictionary && [actionType isEqualToString:@"CNInspectorScroll"]) {
            CGPoint pStart = CGPointFromString([innerDictionary objectForKey:@"fromOffset"]);
            CGPoint pEnd = CGPointFromString([innerDictionary objectForKey:@"toOffset"]);
            IQScrollTask(pStart, pEnd);
        }
        //input事件
        if (innerDictionary && [actionType isEqualToString:@"CNInspectorInput"]) {
            NSString *identifier = [innerDictionary objectForKey:@"identifier"];
            NSString *content = [innerDictionary objectForKey:@"content"];
            IQInputTask(identifier, content);
        }
        
    }
}

- (void)handleApplicationWillResignActiveNotification {
    /*系统级弹框会触发应用willResignActive操作*/
    //    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    //    op.eventType = IQEventResignActive;
    //
    //    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    //    [persistent.factory produceCodeWithOperationEvent:op];
}

- (void)handleApplicationWillTerminateNotification {
    //    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    //    op.eventType = IQEventWillTerminate;
    //
    //    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    //    [persistent.factory produceCodeWithOperationEvent:op];
}

- (void)handleApplicationDidReceiveMemoryWarningNotification {
    
}

- (void)handleConvertTaskWithIdentifier:(NSString *)identifier {
    
    if (identifier) {
        NSDictionary *localCap = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
        NSMutableDictionary *mutaleCap = [NSMutableDictionary dictionaryWithDictionary:localCap];
        [mutaleCap setValue:identifier forKey:@"language"];
        [[NSUserDefaults standardUserDefaults] setObject:mutaleCap forKey:kCapabilitiesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    IQUITestCodeMakerCapabilities *cap = [[IQUITestCodeMakerCapabilities alloc]init];
    
    [self removeAllScript];
    
    IQUITestCodeMakerFactory *factory = [IQUITestCodeMakerFactory handleTaskUnitWithCap:cap];
    factory.eventQueue = [NSMutableArray arrayWithArray:self.factory.eventQueue];
    self.factory = factory;
    [self.factory convertEvetQueueToScript];
    [self restartServer];
}

- (void)handleCapChangeTaskWithKey:(NSString *)key value:(NSString *)value {
    NSDictionary *capLocal = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
    NSMutableDictionary *mutableCap = [NSMutableDictionary dictionaryWithDictionary:capLocal];
    [mutableCap setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:mutableCap forKey:kCapabilitiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    /*脚本重新生成*/
    [self handleConvertTaskWithIdentifier:nil];
}

- (void)handleRecordControlEventWithState:(BOOL)state {
    if (state) {
        /*开启，移除本地脚本缓存*/
        [self removeAllScript];
        
        IQUITestCodeMakerCapabilities *cap = [[IQUITestCodeMakerCapabilities alloc]init];
        //        cap.driverType = IQUITestDriverAppium;
        
        IQUITestCodeMakerFactory *factory = [IQUITestCodeMakerFactory handleTaskUnitWithCap:cap];
        self.factory = factory;
    } else {
        IQUITestOperationEvent *lastEvent = [self.factory.eventQueue lastObject];
        if (!lastEvent || lastEvent.eventType == IQEventEndCode) {
            return;
        }
        /*结束录制*/
        IQUITestOperationEvent *op = [IQUITestOperationEvent new];
        op.eventType = IQEventEndCode;
        [self.factory produceCodeWithOperationEvent:op];
    }
}

- (void)handleApplicationDidFinishLaunching {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    IQUITestDebugBall *debugBall = [[IQUITestDebugBall alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 40, 20, 80, 80)];
    [keyWindow addSubview:debugBall];
}

#pragma mark--GCDWebServer--
- (void)webServerDidStart:(GCDWebServer*)server {
    
}

- (void)removeAllScript {
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *scriptDir = [documentDirectory stringByAppendingString:@"/IQScripts"];
    [[NSFileManager defaultManager] removeItemAtPath:scriptDir error:NULL];
}

- (void)restartServer {
    [_webServer stop];
    [_webServer removeAllHandlers];
    [_webServer addGETHandlerForPath:@"/" filePath:_factory.scriptPath isAttachment:NO cacheAge:2 allowRangeRequests:YES];
    [_webServer start];
}

#pragma mark--Getters & Setters--
- (IQUITestCodeMakerFactory *)factory {
    if (!_factory) {
        [self removeAllScript];
        _factory = [IQUITestCodeMakerFactory handleTaskUnit];
    }
    return _factory;
}

- (GCDWebServer *)webServer {
    if (!_webServer){
        _webServer = [[GCDWebServer alloc]init];
        _webServer.delegate = self;
        [_webServer addGETHandlerForPath:@"/" filePath:self.factory.scriptPath isAttachment:NO cacheAge:2 allowRangeRequests:YES];
    }
    return _webServer;
}

- (NSHashTable *)hashTable {
    if (_hashTable == nil) {
        _hashTable = [NSHashTable weakObjectsHashTable];
    }
    return _hashTable;
}

@end
