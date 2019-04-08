//
//  IQUITestDebugSwitchModel.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugSwitchModel.h"
//#import "IQUITestCodeMakerGenerator.h"
#import "IQUITestCodeMakerService.h"
#import "IQUITestOperationEvent.h"
#import "IQUITestCodeMakerFactory.h"

@interface IQUITestDebugSwitchModel ()

@property (nonatomic, copy, readwrite) NSString *title;

@end

@implementation IQUITestDebugSwitchModel

+ (IQUITestDebugSwitchModel *)viewModelWithState:(BOOL)state {
    IQUITestDebugSwitchModel *model = [[IQUITestDebugSwitchModel alloc]init];
    model.title = @"关闭按钮结束录制(重开会清空脚本)";
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    IQUITestOperationEvent *op = persistent.factory.eventQueue.lastObject;
    //    if (op && (op.eventType != IQEventEndCode)) {
    //        model.swOn = YES;
    //    } else {
    //        model.swOn = NO;
    //    }
    if(state){
        model.swOn = YES;
    }else {
        model.swOn = NO;
    }
    return model;
}

- (void)updateSwitchModel {
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    IQUITestOperationEvent *op = persistent.factory.eventQueue.lastObject;
//    if (op && (op.eventType != IQEventEndCode)) {
//        self.swOn = YES;
//    } else {
//        self.swOn = NO;
//    }
    if (op && (op.eventType != IQEventEndCode)) {
        self.swOn = YES;
    }
    if (op && (op.eventType == IQEventEndCode)) {
        self.swOn = NO;
    }
}

- (void)handleSwitchState:(BOOL)state withCallBack:(IQHandleSwitchBlock)callBack {
    IQUITestCodeMakerService *persistent = [IQUITestCodeMakerService sharePersistent];
    [persistent handleRecordControlEventWithState:state];
    
    if (callBack) {
        callBack();
    }
}

@end
