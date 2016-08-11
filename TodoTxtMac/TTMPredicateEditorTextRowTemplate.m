/**
 * @author Michael Descy
 * @copyright 2014-2016 Michael Descy
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

#import "TTMPredicateEditorTextRowTemplate.h"

@implementation TTMPredicateEditorTextRowTemplate

NSString *const inFormatPrefix = @"rawText IN[cd]";
NSString *const notContainsFormatPrefix = @"NOT rawText CONTAINS[cd]";

#pragma mark - NSPredicateEditorRowTemplate Method Overrides

- (double)matchForPredicate:(NSPredicate *)predicate {
    if ([predicate.predicateFormat hasPrefix:notContainsFormatPrefix]) {
        return 0.4;
    }
    return [super matchForPredicate:predicate];
}

- (void)setPredicate:(NSPredicate*)predicate {
    if ([predicate.predicateFormat hasPrefix:notContainsFormatPrefix]) {
        NSPredicate *newPredicate = [self swapPredicateFormatPrefix:notContainsFormatPrefix withPrefix:inFormatPrefix forPredicate:predicate];
        [super setPredicate:newPredicate];
        return;
    }

    [super setPredicate:predicate];
}

- (NSPredicate*)predicateWithSubpredicates:(NSArray*)subpredicates {
    NSPredicate *predicate = [super predicateWithSubpredicates:subpredicates];
    return [self swapPredicateFormatPrefix:inFormatPrefix withPrefix:notContainsFormatPrefix forPredicate:predicate];
}

- (NSPredicate*)swapPredicateFormatPrefix:(NSString*)oldPrefix withPrefix:(NSString*)newPrefix forPredicate:(NSPredicate*)predicate {
    NSString *predicateFormat = predicate.predicateFormat;
    if ([predicateFormat hasPrefix:oldPrefix]) {
        NSRange oldPrefixRange = [predicateFormat rangeOfString:oldPrefix];
        NSString *newFormat = [predicateFormat stringByReplacingOccurrencesOfString:oldPrefix withString:newPrefix options:0 range:oldPrefixRange];
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:newFormat];
        return newPredicate;
    }

    return predicate;
}

@end
