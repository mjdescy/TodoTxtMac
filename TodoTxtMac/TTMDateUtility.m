/**
 * @author Michael Descy
 * @copyright 2014-2015 Michael Descy
 * @discussion Dual-licensed under the GNU General Public License and the MIT License
 *
 *
 *
 * @license GNU General Public License http://www.gnu.org/licenses/gpl.html
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *
 *
 * @license The MIT License (MIT)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "TTMDateUtility.h"
#import "NSDate+RelativeDates.h"

@implementation TTMDateUtility

+ (NSDate*)convertStringToDate:(NSString*)dateString {
    if (!dateString) {
        return nil;
    }
    
    // dateString must not contain a time element.
    // We add a time element to it to set the time to midnight.
    NSString *dateTimeString = [dateString stringByAppendingString:@" 00:00:00"];
    
    // Convert dateString to NSDate.
    NSDateFormatter *dateFormatter = [self dateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter dateFromString:dateTimeString];
}

+ (NSDateFormatter*)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setCalendar:gregorian];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return dateFormatter;
}

+ (NSString*)convertDateToString:(NSDate*)date {
    if (!date) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [self dateFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate*)today {
    return [self dateWithoutTime:[NSDate date]];
}

+ (NSString*)todayAsString {
    return [self convertDateToString:[self today]];
}

+ (NSDate*)addDays:(NSInteger)days toDate:(NSDate*)date {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = days;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
}

+ (NSDate*)dateWithoutTime:(NSDate*)date {
    if (date == nil) {
        return nil;
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar]
                               components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                               fromDate:date];
    
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (NSDate*)dateFromNaturalLanguageString:(NSString*)string {
    // This method's structure of comparing localized strings, rather than just using
    // an NSDataDetector, came about because NSDataDetector does not properly find dates
    // in short strings such as "today", "tomorrow", or "Friday". NSDataDetector does find
    // dates when a time is specified, such as "today at 00:00", but it also finds the time
    // when nonsense plus a time is specified, as in "never at 00:00" (which returns today's date
    // at midnight).

    if (!string) {
        return nil;
    }
    
    NSString *todayString = NSLocalizedStringFromTable(@"today", @"RelativeDates", @"today");
    if ([string caseInsensitiveCompare:todayString] ==
        NSOrderedSame) {
        return [self today];
    }
    
    NSString *tomorrowString = NSLocalizedStringFromTable(@"tomorrow", @"RelativeDates",
                                                          @"tomorrow");
    if ([string caseInsensitiveCompare:tomorrowString]
        == NSOrderedSame) {
        return  [self addDays:1 toDate:[self today]];
    }
    
    NSString *yesterdayString = NSLocalizedStringFromTable(@"yesterday", @"RelativeDates",
                                                           @"yesterday");
    if ([string caseInsensitiveCompare:yesterdayString]
        == NSOrderedSame) {
        return  [self addDays:-1 toDate:[self today]];
    }
    
    NSString *testString = [string lowercaseString];
    NSDate *returnDate;
    
    NSArray *weekdayNames =
        @[[NSLocalizedStringFromTable(@"Monday", @"RelativeDates", @"Monday") lowercaseString],
          [NSLocalizedStringFromTable(@"Tuesday", @"RelativeDates", @"Tuesday") lowercaseString],
          [NSLocalizedStringFromTable(@"Wednesday", @"RelativeDates", @"Wednesday") lowercaseString],
          [NSLocalizedStringFromTable(@"Thursday", @"RelativeDates", @"Thursday") lowercaseString],
          [NSLocalizedStringFromTable(@"Friday", @"RelativeDates", @"Friday") lowercaseString],
          [NSLocalizedStringFromTable(@"Saturday", @"RelativeDates", @"Saturday") lowercaseString],
          [NSLocalizedStringFromTable(@"Sunday", @"RelativeDates", @"Sunday") lowercaseString]];
    returnDate = [self relativeDateFromWeekdayName:testString
                           withAllowedWeekdayNames:weekdayNames
                                    withDateFormat:@"eeee"];
    if (returnDate) {
        return returnDate;
    }

    NSArray *shortWeekdayNames =
        @[[NSLocalizedStringFromTable(@"Mon", @"RelativeDates", @"Mon") lowercaseString],
          [NSLocalizedStringFromTable(@"Tue", @"RelativeDates", @"Tue") lowercaseString],
          [NSLocalizedStringFromTable(@"Wed", @"RelativeDates", @"Wed") lowercaseString],
          [NSLocalizedStringFromTable(@"Thu", @"RelativeDates", @"Thu") lowercaseString],
          [NSLocalizedStringFromTable(@"Fri", @"RelativeDates", @"Fri") lowercaseString],
          [NSLocalizedStringFromTable(@"Sat", @"RelativeDates", @"Sat") lowercaseString],
          [NSLocalizedStringFromTable(@"Sun", @"RelativeDates", @"Sun") lowercaseString]];
    returnDate = [self relativeDateFromWeekdayName:testString
                           withAllowedWeekdayNames:shortWeekdayNames
                                    withDateFormat:@"eee"];
    if (returnDate) {
        return returnDate;
    }
    
    return nil;
}

+ (NSDate*)relativeDateFromWeekdayName:(NSString*)weekdayName
               withAllowedWeekdayNames:(NSArray*)allowedWeekdayNames
                        withDateFormat:(NSString*)dateFormat {
    NSSet *weekdayNamesSet = [NSSet setWithArray:allowedWeekdayNames];
    if (![weekdayNamesSet containsObject:weekdayName]) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    [dateFormatter setDateFormat:dateFormat];
    
    NSDate *todaysDate = [self today];
    
    for (NSUInteger i = 1; i < 8; i++) {
        NSDate *testDate = [self addDays:i toDate:todaysDate];
        NSString *generatedWeekdayName = [[dateFormatter stringFromDate:testDate] lowercaseString];
        if ([weekdayName caseInsensitiveCompare:generatedWeekdayName] == NSOrderedSame) {
            return testDate;
        }
    }
    
    return nil;
}

+ (NSString*)dateStringFromNaturalLanguageString:(NSString*)naturalLanguageString {
    NSDate *date = [self dateFromNaturalLanguageString:naturalLanguageString];
    if (date == nil) {
        return nil;
    } else {
        return [self convertDateToString:date];
    }
}

+ (NSInteger)daysBetweenDate:(NSDate*)startDate andEndDate:(NSDate*)endDate {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:NSCalendarMatchFirst];
    
    return components.day;
}

@end