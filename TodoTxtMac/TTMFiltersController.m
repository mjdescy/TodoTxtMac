/**
 * @author Michael Descy
 * @copyright 2014 Michael Descy
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

#import "TTMFiltersController.h"
#import "TTMFilterPredicates.h"

@implementation TTMFiltersController

@synthesize filter1Predicate, filter2Predicate, filter3Predicate, filter4Predicate,
filter5Predicate, filter6Predicate, filter7Predicate, filter8Predicate,
filter9Predicate;

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
    // Load filter predicates.
    [self getAllFilterPredicatesFromDefaults];
    // initialize predicate editors (add lines if they are empty)
    [self initializeAllPredicateEditors];
}

- (void)getAllFilterPredicatesFromDefaults {
    self.filter1Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:1];
    self.filter2Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:2];
    self.filter3Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:3];
    self.filter4Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:4];
    self.filter5Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:5];
    self.filter6Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:6];
    self.filter7Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:7];
    self.filter8Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:8];
    self.filter9Predicate = [TTMFilterPredicates getFilterPredicateFromPresetNumber:9];
}

- (void)setAllFilterPredicatesToDefaults {
    [TTMFilterPredicates setFilterPredicate:self.filter1Predicate toPresetNumber:1];
    [TTMFilterPredicates setFilterPredicate:self.filter2Predicate toPresetNumber:2];
    [TTMFilterPredicates setFilterPredicate:self.filter3Predicate toPresetNumber:3];
    [TTMFilterPredicates setFilterPredicate:self.filter4Predicate toPresetNumber:4];
    [TTMFilterPredicates setFilterPredicate:self.filter5Predicate toPresetNumber:5];
    [TTMFilterPredicates setFilterPredicate:self.filter6Predicate toPresetNumber:6];
    [TTMFilterPredicates setFilterPredicate:self.filter7Predicate toPresetNumber:7];
    [TTMFilterPredicates setFilterPredicate:self.filter8Predicate toPresetNumber:8];
    [TTMFilterPredicates setFilterPredicate:self.filter9Predicate toPresetNumber:9];
}

- (void)initializeAllPredicateEditors {
    [self initializePredicateEditor:self.filter1PredicateEditor];
    [self initializePredicateEditor:self.filter2PredicateEditor];
    [self initializePredicateEditor:self.filter3PredicateEditor];
    [self initializePredicateEditor:self.filter4PredicateEditor];
    [self initializePredicateEditor:self.filter5PredicateEditor];
    [self initializePredicateEditor:self.filter6PredicateEditor];
    [self initializePredicateEditor:self.filter7PredicateEditor];
    [self initializePredicateEditor:self.filter8PredicateEditor];
    [self initializePredicateEditor:self.filter9PredicateEditor];
}

- (void)initializePredicateEditor:(NSPredicateEditor*)predicateEditor {
    if ([predicateEditor numberOfRows] == 0) {
        [predicateEditor addRow:self];
    }
}

#pragma mark - Window Delegate Methods

- (BOOL)windowShouldClose:(NSWindow *)window {
    // We do this to catch the case where the user enters a value into one of the text fields but
    // closes the window without hitting enter or tab.
    return [window makeFirstResponder:nil];
}

- (void)windowWillClose:(NSNotification *)notification {
    // save all filter predicates to user defaults
    [self setAllFilterPredicatesToDefaults];
}

@end
