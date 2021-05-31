//  ReactNativeRongta.m


// ReactNativeRongta.m
#import <React/RCTLog.h>
#import "ReactNativeRongta.h"

// SDK
#import "RTBlueToothPI.h"
#import "PrinterManager.h"
#import "BlueToothFactory.h"
#import "ObserverObj.h"
#import "RTDeviceinfo.h"
#import "PrinterInterface.h"
#import "ESCCmd.h"
#import "PinCmd.h"
#import "TSCCmd.h"
#import "ZPLCmd.h"

@interface ReactNativeRongta(){
  RTBlueToothPI * _blueToothPI;
  PrinterManager * _printerManager;
}
@property (nonatomic) BlueToothKind bluetoothkind;
@end

@implementation ReactNativeRongta

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

// To export a module named ReactNativeRongta
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(connectToDevice:(NSString *)UUID callback:(RCTResponseSenderBlock)callback)
{
  RCTLogInfo(@"Pretending to print '%@'", UUID);
  _printerManager = [PrinterManager sharedInstance];
  [_printerManager DoConnectBle:UUID];
  double delayInSeconds = 1.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      //code to be executed on the main queue after delay
    if ([self->_printerManager.CurrentPrinter IsOpen]) {
      RCTLogInfo(@"connect success");
      callback(@[@"1"]);
    } else {
      RCTLogInfo(@"connect failed");
      callback(@[@"0"]);
    }
  });
}
RCT_EXPORT_METHOD(print:(NSString *)text)
{
  // todo print esc
  _printerManager = [PrinterManager sharedInstance];
  Printer * currentprinter = _printerManager.CurrentPrinter;
  if (currentprinter.IsOpen){
      NSString* inputStr = text;
      NSLog(@"inputStr = %@",text);
      TextSetting *textst = currentprinter.TextSets;
      //[textst setEscFonttype:ESCFontType_FontA];
      [textst setIsBold:Set_Enabled];
      [textst setIsItalic:Set_Enabled];
      [textst setIsTimes_Wide:Set_DisEnable];
      [textst setIsTimes_Heigh:Set_DisEnable];
      [textst setIsTimes4_Wide:Set_DisEnable];
      [textst setIsTimes_Wide:Set_Enabled];
      [textst setAlignmode:Align_Left];
      [textst setIsUnderline:Set_Enabled];
      [textst setRotate:Rotate0];//ESC: Rotate90,Rotate0 有效(valid)
      Cmd *cmd =  [_printerManager CreateCmdClass:_printerManager.CurrentPrinterCmdType];
      [cmd Clear];
      [cmd setEncodingType:Encoding_GBK];
      NSData *headercmd = [_printerManager GetHeaderCmd:cmd cmdtype:_printerManager.CurrentPrinterCmdType];//
      [cmd Append:headercmd];
      NSData *data1 = [(ESCCmd*)cmd GetSetAreaWidthCmd:80*8];
      [cmd Append:data1];
      NSData *data = [cmd GetTextCmd:currentprinter.TextSets text:inputStr];
      [cmd Append:data];
      for (int i=0; i<2; i++) {
          [cmd Append:[cmd GetLFCRCmd]];
      }
      data1 = [(ESCCmd*)cmd GetSetAreaWidthCmd:72*8];
      [cmd Append:data1];
      NSData *data2 = [(ESCCmd*)cmd GetSetLeftStartSpacingCmd:10*8];
      [cmd Append:data2];
      [cmd Append:data];
      [cmd Append:[cmd GetPrintEndCmd]];
      //询问打印是否完成，打印完成，返回 “print Ok" 适用于 Rpp80Use 定制客户使用。
      
      //Inquire whether the printing is completed, printing is completed, return "print Ok" For Rpp80Use custom customer use.
      //       [cmd Append:[cmd GetAskPrintOkCmd]];
      
      
      [cmd Append:[cmd GetCutPaperCmd:CutterMode_half]];
      [cmd Append:[cmd GetPrintEndCmd]];
      [cmd Append:[cmd GetBeepCmd:1 interval:3]];//level，interval:max is(最大值) 9
      [cmd Append:[cmd GetPrintEndCmd]];
      //        [cmd Append:[cmd GetOpenDrawerCmd:0 startTime:5 endTime:0]];
      //
      
      if ([currentprinter IsOpen]){
          NSData *data=[cmd GetCmd];
          NSLog(@"data bytes = %@",text);
          NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          
          aString = [aString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
          NSLog(@"data string encoding = %@",aString);
          // for (int i=0; i<60; i++) {
          [currentprinter Write:data];
          // }
          
      }
  }
}
RCT_EXPORT_METHOD(getDevicesList:(RCTResponseSenderBlock)callback) {
  @try {
    if (_printerManager == nil) {
      _printerManager = [PrinterManager sharedInstance];
    }
    if (_blueToothPI == nil) {
      _blueToothPI  = [BlueToothFactory Create:self.bluetoothkind];
    }

    // scan device
    [_blueToothPI startScan:15 isclear:YES];
    
    // init array
    NSMutableArray *devlist = _blueToothPI.getBleDevicelist;
    NSMutableArray *listDevice = [[NSMutableArray alloc] init];
    
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
      for (RTDeviceinfo *device in devlist) {
        NSDictionary *dic = @{@"id": device.UUID, @"name": device.name};
        [listDevice addObject:dic];
      }
      callback(@[[NSNull null], listDevice]);
    });
  } @catch (NSException *exception) {
    callback(@[exception.reason, [NSNull null]]);
  }
}

@end
