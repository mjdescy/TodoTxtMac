// This code is lifted from Apple's Developer Documenation.
// Source: https://developer.apple.com/library/mac/documentation/cocoa/conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html

#import <Foundation/Foundation.h>

@interface NSUserDefaults(myColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;

@end

