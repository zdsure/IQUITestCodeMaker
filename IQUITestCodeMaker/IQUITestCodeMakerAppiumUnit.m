//
//  IQUITestCodeMakerAppiumUnit.m
//  IQUITestCodeMaker
//
//  Created by yishu.zd on 2018/12/15.
//

#import "IQUITestCodeMakerAppiumUnit.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "IQUITestOperationEvent.h"

@implementation IQUITestCodeMakerAppiumUnit

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
           MobileElement el%ld = (MobileElement) driver.findElementByAccessibilityId(\"%@\");\n\
           el%ld.click();\n",self.eventIndex,op.identifier,self.eventIndex];
    [self storeProductCode:tapCode];
}

- (void)produceSendKeyCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    if (!self.isConverting) {
        [self.eventQueue addObject:op];
    }
    self.eventIndex++;
    NSString *sendCode = [NSString stringWithFormat:@"\n\
           MobileElement el%ld = (MobileElement) driver.findElementByAccessibilityId(\"%@\");\n\
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
      /*This Sample Code Uses Appium*/\n\
      \n\
      \n\
      import io.appium.java_client.MobileElement;\n\
      import io.appium.java_client.ios.IOSDriver;\n\
      import junit.framework.TestCase;\n\
      import org.junit.After;\n\
      import org.junit.Before;\n\
      import org.junit.Test;\n\
      import java.net.MalformedURLException;\n\
      import java.net.URL;\n\
      import org.openqa.selenium.remote.DesiredCapabilities;\n\
      \n\
      public class SampleTest {\n\
      private IOSDriver driver;\n\
      \n\
      @Before\n\
      public void setUp() throws MalformedURLException {\n\
          DesiredCapabilities desiredCapabilities = new DesiredCapabilities();\n\
          desiredCapabilities.setCapability(\"platformName\", \"%@\");\n\
          desiredCapabilities.setCapability(\"platformVersion\", \"%@\");\n\
          desiredCapabilities.setCapability(\"deviceName\", \"%@\");\n\
          desiredCapabilities.setCapability(\"automationName\", \"%@\");\n\
          desiredCapabilities.setCapability(\"app\", \"%@\");\n\
          URL remoteUrl = new URL(\"http://127.0.0.1:4723/wd/hub\");\n\
          driver = new IOSDriver(remoteUrl, desiredCapabilities);\n\
      }\n\
      \n\
      @Test\n\
      public void sampleTest() {\n", self.cap.capbilities.platformName,self.cap.capbilities.platformVersion,self.cap.capbilities.deviceName,self.cap.capbilities.automationName,self.cap.capbilities.app];
    
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
