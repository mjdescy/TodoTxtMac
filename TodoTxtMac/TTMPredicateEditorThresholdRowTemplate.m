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

#import "TTMPredicateEditorThresholdRowTemplate.h"
#import "TTMTask.h"

@implementation TTMPredicateEditorThresholdRowTemplate

#pragma mark - Class Property Getters

- (NSPopUpButton*)keypathPopUp {
    if(!_keypathPopUp) {
        NSMenu *keypathMenu = [[NSMenu alloc]
                               initWithTitle:@"threshold state menu"];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc]
                                initWithTitle:@"threshold state"
                                action:nil
                                keyEquivalent:@""];
        [menuItem setRepresentedObject:[NSExpression expressionForKeyPath:@"thresholdState"]];
        [menuItem setEnabled:YES];
        
        [keypathMenu addItem:menuItem];
        
        _keypathPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
        [_keypathPopUp setMenu:keypathMenu];
    }
    return _keypathPopUp;
}

- (NSPopUpButton*)thresholdStatePopUp {
    if (!_thresholdStatePopUp) {
        NSMenuItem *noThresholdDateItem = [[NSMenuItem alloc]
                                         initWithTitle:@"no threshold date"
                                         action:nil
                                         keyEquivalent:@""];
        [noThresholdDateItem setRepresentedObject:[NSExpression
                                                 expressionForConstantValue:@(NoThresholdDate)]];
        [noThresholdDateItem setEnabled:YES];
        [noThresholdDateItem setTag:(long)NoThresholdDate];

        NSMenuItem *thresholdBeforeToday = [[NSMenuItem alloc]
                                           initWithTitle:@"threshold before today"
                                           action:nil
                                           keyEquivalent:@""];
        [thresholdBeforeToday setRepresentedObject:[NSExpression
                                                   expressionForConstantValue:@(ThresholdBeforeToday)]];
        [thresholdBeforeToday setEnabled:YES];
        [thresholdBeforeToday setTag:(long)ThresholdBeforeToday];
        
        NSMenuItem *thresholdIsTodayItem = [[NSMenuItem alloc]
                                          initWithTitle:@"threshold is today"
                                                 action:nil
                                          keyEquivalent:@""];
        [thresholdIsTodayItem setRepresentedObject:[NSExpression
                                                  expressionForConstantValue:@(ThresholdIsToday)]];
        [thresholdIsTodayItem setEnabled:YES];
        [thresholdIsTodayItem setTag:(long)ThresholdIsToday];
        
        NSMenuItem *thresholdAfterTodayItem = [[NSMenuItem alloc]
                                           initWithTitle:@"threshold after today"
                                                  action:nil
                                           keyEquivalent:@""];
        [thresholdAfterTodayItem setRepresentedObject:[NSExpression
                                                   expressionForConstantValue:@(
                                                   ThresholdAfterToday)]];
        [thresholdAfterTodayItem setEnabled:YES];
        [thresholdAfterTodayItem setTag:(long)ThresholdAfterToday];
        
        NSMenu *thresholdStateMenu = [[NSMenu alloc]
                                      initWithTitle:@"Threshold State"];
        [thresholdStateMenu addItem:noThresholdDateItem];
        [thresholdStateMenu addItem:thresholdBeforeToday];
        [thresholdStateMenu addItem:thresholdIsTodayItem];
        [thresholdStateMenu addItem:thresholdAfterTodayItem];
        
        _thresholdStatePopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
        [_thresholdStatePopUp setMenu:thresholdStateMenu];
    }
    return _thresholdStatePopUp;
}

#pragma mark - NSPredicateEditorRowTemplate Method Overrides

- (NSArray*)templateViews {
    NSMutableArray *newTemplateViews = [[super templateViews] mutableCopy];
    [newTemplateViews replaceObjectAtIndex:0 withObject:self.keypathPopUp];
    [newTemplateViews replaceObjectAtIndex:2 withObject:self.thresholdStatePopUp];
    return newTemplateViews;
}

- (void)setPredicate:(NSPredicate *)predicate {
    id rightValue = [[(NSComparisonPredicate*)predicate rightExpression] constantValue];
    if ([rightValue isKindOfClass:[NSNumber class]]) {
        [self.thresholdStatePopUp selectItemWithTag:[rightValue integerValue]];
    }
}

- (NSPredicate*)predicateWithSubpredicates:(NSArray*)subpredicates {
    NSPredicate *p = [super predicateWithSubpredicates:subpredicates];
    NSComparisonPredicate *comparison = (NSComparisonPredicate*)p;
    NSPredicate *newPredicate =
    [NSComparisonPredicate
     predicateWithLeftExpression:[[self.keypathPopUp selectedItem] representedObject]
     rightExpression:[[self.thresholdStatePopUp selectedItem] representedObject]
     modifier:[comparison comparisonPredicateModifier]
     type:[comparison predicateOperatorType]
     options:[comparison options]];
    return newPredicate;
}

@end
