//
//  IQUITestCodeMakerFactory.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestCodeMakerFactory.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "IQUITestOperationEvent.h"

@interface IQUITestCodeMakerFactory ()

@property (nonatomic, strong, readwrite) IQUITestCodeMakerCapabilities *cap;
@property (nonatomic, copy, readwrite) NSString *scriptPath;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation IQUITestCodeMakerFactory

+ (NSDictionary *)unitStructureMap {
    NSDictionary *unitStruct = @{
                                 @"Totoro"      :@"IQUITestCodeMakerTotoroUnit",
                                 @"Appium"      :@"IQUITestCodeMakerAppiumUnit"
                                 };
    return unitStruct;
}

+ (IQUITestCodeMakerFactory *)handleTaskUnit {
    return [self handleTaskUnitWithCap:[IQUITestCodeMakerCapabilities new]];/*default cap*/
}

+ (IQUITestCodeMakerFactory *)handleTaskUnitWithCap:(IQUITestCodeMakerCapabilities *)cap {
    NSDictionary *unitMap = [self unitStructureMap];
    NSString *unitString = unitMap[cap.capbilities.language];
    IQUITestCodeMakerFactory *unit = [[NSClassFromString(unitString) alloc]init];
    unit.cap = cap;
    unit.eventQueue = [NSMutableArray array];
    return unit;
}

- (void)produceCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    /*override this method*/
    
}

- (void)convertEvetQueueToScript {
    
}

- (void)storeProductCode:(NSString *)code {
    if (!code) {
        return;
    }
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.scriptPath]) {
        [code writeToFile:self.scriptPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }else{
        NSString *originCode = [NSString stringWithContentsOfFile:self.scriptPath encoding:NSUTF8StringEncoding error:nil];
        originCode = [originCode stringByAppendingString:code];
        [originCode writeToFile:self.scriptPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }
    dispatch_semaphore_signal(self.semaphore);
}

#pragma mark--Getters & Setters--
- (NSString *)scriptPath{
    if (!_scriptPath) {
        NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString *documentDirectory = [directoryPaths objectAtIndex:0];
        NSString *scriptDir = [documentDirectory stringByAppendingString:@"/IQScripts/"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:scriptDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:scriptDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //NSString *suffix = [self suffix];
        _scriptPath = [scriptDir stringByAppendingPathComponent:[NSString stringWithFormat:@"scriptCode.%@",@"java"]];
        NSLog(@"scriptCode.rb:%@",_scriptPath);
    }
    return _scriptPath;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore){
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}


@end
