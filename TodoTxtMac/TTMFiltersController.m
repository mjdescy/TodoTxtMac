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

#import "TTMFiltersController.h"
#import "TTMFilterPredicates.h"
#import "TTMAppController.h"

@implementation TTMFiltersController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)resetAllFilters:(id)sender {
    NSAlert *resetPrompt = [[NSAlert alloc] init];
    resetPrompt.messageText = @"Clear all filters";
    resetPrompt.informativeText = @"Are you sure you want to do this? You will lose all filter customizations.";
    [resetPrompt addButtonWithTitle:@"OK"];
    [resetPrompt addButtonWithTitle:@"Cancel"];
    [resetPrompt beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [TTMFilterPredicates resetAllFilterPredicates];
            // Reload all the filter predicate editors because
            // the one with focus at the time this method is executed
            // will not be cleared. This is only really necessary to
            // call on the predicate editor with focus.
            [self.filter1PredicateEditor reloadCriteria];
            [self.filter2PredicateEditor reloadCriteria];
            [self.filter3PredicateEditor reloadCriteria];
            [self.filter4PredicateEditor reloadCriteria];
            [self.filter5PredicateEditor reloadCriteria];
            [self.filter6PredicateEditor reloadCriteria];
            [self.filter7PredicateEditor reloadCriteria];
            [self.filter8PredicateEditor reloadCriteria];
            [self.filter9PredicateEditor reloadCriteria];
        }
    }];
}

- (IBAction)refreshTaskListFilters:(id)sender {
    [self.appController visualRefreshAll:self];
}

#pragma mark - Window Delegate Methods

- (BOOL)windowShouldClose:(NSWindow *)window {
    // We do this to catch the case where the user enters a value into one of the text fields but
    // closes the window without hitting enter or tab.
    return [window makeFirstResponder:nil];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self refreshTaskListFilters:self];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSUInteger flags = [theEvent modifierFlags];
    NSString *passedChar = [theEvent charactersIgnoringModifiers];

    if ((flags & NSCommandKeyMask) &&
        (flags & NSShiftKeyMask) &&
        ([passedChar isEqualToString:@"{"])) {
        [self.tabView selectPreviousTabViewItem:self];
        return;
    }

    if ((flags & NSCommandKeyMask) &&
        (flags & NSShiftKeyMask) &&
        ([passedChar isEqualToString:@"}"])) {
        [self.tabView selectNextTabViewItem:self];
        return;
    }

    [super keyDown:theEvent];
}

#pragma mark - NSTabViewDelegate Delegate Methods

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [self refreshTaskListFilters:self];
}

@end
