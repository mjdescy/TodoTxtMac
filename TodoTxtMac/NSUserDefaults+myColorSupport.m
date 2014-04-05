// This code is lifted from Apple's Developer Documenation.
// Source: https://developer.apple.com/library/mac/documentation/cocoa/conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html

#import "NSUserDefaults+myColorSupport.h"

@implementation NSUserDefaults(myColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey {
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end