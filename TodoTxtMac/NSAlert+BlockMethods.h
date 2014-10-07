// This code comes from Jakob Egger on StackOverflow.
// http://stackoverflow.com/questions/20146249/how-can-i-use-nsalert-beginsheetmodalforwindowcompletionhandler-on-older-ver

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSAlert (BlockMethods)

- (void)compatibleBeginSheetModalForWindow:(NSWindow *)sheetWindow
                        completionHandler:(void (^)(NSInteger returnCode))handler;

@end
