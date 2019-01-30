//
//  IQUITestCodeMakerTotoroUnit.m
//  AliyunOSSiOS
//
//  Created by yishu.zd on 2018/12/15.
//

#import "IQUITestCodeMakerTotoroUnit.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "IQUITestOperationEvent.h"

@implementation IQUITestCodeMakerTotoroUnit

- (void)produceCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    [self produceTemplateCodeOnce];
    switch (op.eventType) {
        case IQUIEventUnknown:
        {
            /*未知*/
        }
            break;
        case IQUIEventTap:
        {
            [self produceTapCodeWithOperationEvent:op];
        }
            break;
        case IQUIEventDoubleTap:
        {
            
        }
            break;
        case IQUIEventSwipe:
        {
            [self produceSwipeCodeWithOperationEvent:op];
        }
            break;
        case IQUIEventPinch:
        {
            
        }
            break;
        case IQUIEventZoom:
        {
            
        }
            break;
        case IQUIEventLongPress:
        {
            
        }
            break;
        case IQUIEventSendKey:
        {
            [self produceSendKeyCodeWithOperationEvent:op];
        }
            break;
        case IQEventEndCode:
        {
            [self produceEndCodeOnce];
        }
            break;
        default:
            break;
    }
}

- (void)produceTapCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    if (!self.isConverting) {
        [self.eventQueue addObject:op];
    }
    self.eventIndex++;
    NSString *tapCode = [NSString stringWithFormat:@"\n\
         WebElement el%ld = driver.findElementByAccessibilityId(\"%@\");\n\
         el%ld.click();\n",self.eventIndex,op.identifier,self.eventIndex];
    [self storeProductCode:tapCode];
}
    
- (void)produceSwipeCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    if (!self.isConverting) {
        [self.eventQueue addObject:op];
    }
    self.eventIndex++;
    NSString *swipeCode = [NSString stringWithFormat:@"\n\
                         driver.findElementByAccessibilityId(\"%@\");\n\
                         el%ld.click();\n",self.eventIndex,op.identifier,self.eventIndex];
    [self storeProductCode:swipeCode];
}

- (void)produceSendKeyCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    if (!self.isConverting) {
        [self.eventQueue addObject:op];
    }
    self.eventIndex++;
    NSString *sendCode = [NSString stringWithFormat:@"\n\
        WebElement el%ld = driver.findElementByAccessibilityId(\"%@\");\n\
        el%ld.sendKeys(\"%@\");\n",self.eventIndex,op.identifier,self.eventIndex,op.value];
    [self storeProductCode:sendCode];
}

- (void)produceTemplateCodeOnce {
    if (!self.templateCodeFlag) {
        [self templateCode];
    }
    self.templateCodeFlag++;
}

- (void)templateCode {
    if (!self.isConverting) {
        IQUITestOperationEvent *event = [IQUITestOperationEvent new];
        event.eventType = IQEventTemplateCode;
        [self.eventQueue addObject:event];
    }
    NSString *code = [NSString stringWithFormat:@"\n\
      /*This Sample Code Uses Totoro*/\n\
      \n\
      \n\
      import com.alipay.auto.common.BaseCase;\n\
      import com.alipay.auto.common.CaseInfo;\n\
      import com.totoro.client.utils.Capability;\n\
      import org.junit.Test;\n\
      import org.openqa.selenium.WebElement;\n\
      import org.openqa.selenium.remote.DesiredCapabilities;\n\
      \n\
      public class SampleTest extends BaseCase{\n\
      \n\
      @Override\n\
      public void setCapabilities(){\n\
          DesiredCapabilities capabilities = new DesiredCapabilities();\n\
          capabilities.setCapability(Capability.DEVICEID, \"\");\n\
          capabilities.setCapability(Capability.PLATFORM, \"ios\");\n\
          capabilities.setCapability(Capability.PACKAGE, \"%@\");\n\
          setCustomCapabilities(capabilities);\n\
      }\n\
      \n\
      @Test\n\
      public void sampleTest() {\n", self.cap.capbilities.app];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.scriptPath error:nil];
    [self storeProductCode:code];
}

- (void)produceEndCodeOnce {
    if (!self.endCodeFlag) {
        [self endCode];
    }
    self.endCodeFlag++;
}

- (void)endCode {
    if (!self.isConverting) {
        IQUITestOperationEvent *event = [IQUITestOperationEvent new];
        event.eventType = IQEventEndCode;
        [self.eventQueue addObject:event];
    }
    NSString *code = @"\n\
    }\n\
    \n\
    @After\n\
    public void tearDown() {\n\
        driver.quit();\n\
    }\n";
    [self storeProductCode:code];
}

- (void)convertEvetQueueToScript {
    self.isConverting = YES;
    for (IQUITestOperationEvent *op in self.eventQueue) {
        if (op.eventType == IQEventTemplateCode) {
            [self produceTemplateCodeOnce];
        } else if (op.eventType == IQEventEndCode) {
            [self produceEndCodeOnce];
        } else {
            [self produceCodeWithOperationEvent:op];
        }
    }
    self.isConverting = NO;
}

@end
