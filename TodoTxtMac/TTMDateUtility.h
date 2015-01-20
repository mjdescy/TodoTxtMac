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

#import <Foundation/Foundation.h>

@interface TTMDateUtility : NSObject

/*!
 * @method convertStringToDate:
 * @abstract This method converts a string in "yyyy-MM-dd" format to an NSDate object.
 * @param dateString An NSString in "yyyy-MM-dd" format. It must not contain time elements.
 * @return Returns a date object based on the date string.
 */
+ (NSDate*)convertStringToDate:(NSString*)dateString;

/*!
 * @method convertDateToString:
 * @abstract This method returns today's date as a string in "yyyy-MM-dd" format.
 * @param date The date to convert to a string.
 * @return The date parameter as a string in "yyyy-MM-dd" format.
 */
+ (NSString*)convertDateToString:(NSDate*)date;

/*!
 * @method todayAsString:
 * @abstract This method returns today's date.
 * @return Today's date.
 */
+ (NSDate*)today;

/*!
 * @method todayAsString:
 * @abstract This method returns today's date as a string in "yyyy-MM-dd" format.
 * @return Today's date as a string in "yyyy-MM-dd" format.
 */
+ (NSString*)todayAsString;

/*!
 * @method addDays:toDate:
 * @abstract This method adds a number of days to the date.
 * @param days The number of days to add. Can be negative.
 * @param date The date to add days to.
 * @return A date offset by the given number of days.
 */
+ (NSDate*)addDays:(NSInteger)days toDate:(NSDate*)date;

/*!
 * @method dateWithoutTime:
 * @abstract This method strips the time element from a date.
 * @param date The date to return as of 00:00:00.
 * @return A date with the time element set to 00:00:00.
 * @discussion This method is necessary to allow for date "is equal" comparisons
 * in NSPredicateEditor.
 */
+ (NSDate*)dateWithoutTime:(NSDate*)date;

/*!
 * @method dateFromNaturalLanguageString:
 * @abstract This method returns a date based on a string such as "today" or "Monday".
 * @param string A string that could represent a relative due date.
 * @return A date, or nil if no date matches the string passed to the method.
 */
+ (NSDate*)dateFromNaturalLanguageString:(NSString*)string;

/*!
 * @method relativeDateFromWeekdayName:withAllowedWeekdayNames:withDateFormat
 * @abstract This method returns a date based on a string that represents a weekday name.
 * @return A date, or nil if no date matches the string passed to the method.
 * @param weekdayName A string that could be a weekday name.
 * @param allowedWeekdayNames An array of weekday names (or shortnames) that the weekdayName 
 * will be tested to match.
 * @param dateFormat Date format to apply to the weekdayName for matching purposes.
 * @discussion This is a convenience method called from
 * relativeDateFromWeekdayName:withAllowedWeekdayNames:withDateFormat.
 */
+ (NSDate*)relativeDateFromWeekdayName:(NSString*)weekdayName
               withAllowedWeekdayNames:(NSArray*)allowedWeekdayNames
                        withDateFormat:(NSString*)dateFormat;

/*!
 * @method dateStringFromNaturalLanguageString:
 * @abstract This method returns a string-formatted date in "YYYY-MM-DD" format, 
 * based on a string such as "today" or "Monday".
 * @param string A string that could represent a relative due date.
 * @return A string-formatted date in "YYYY-MM-DD" format, or nil if no date matches
 * the string passed to the method.
 */
+ (NSString*)dateStringFromNaturalLanguageString:(NSString*)string;

@end
