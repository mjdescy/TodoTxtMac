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

#import "TTMFieldEditor.h"

#define COMPLETION_DELAY (0.25)

@implementation TTMFieldEditor

#pragma mark - Init Methods

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - Autocompletion Timer Methods

- (void)startCompletionTimer {
    [self stopCompletionTimer]; // cancel any timers running already
    self.completionTimer = [NSTimer scheduledTimerWithTimeInterval:COMPLETION_DELAY
                                                            target:self
                                                          selector:@selector(doCompletion:)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)stopCompletionTimer {
    [self.completionTimer invalidate];
    self.completionTimer = nil;
}

- (void)doCompletion:(NSTimer*)timer {
    [self complete:nil];
    [self stopCompletionTimer];
}

#pragma mark - Autocompletion Event Handler Methods

/*!
 * @method keyUp:
 * @abstract This method fires after the user types a character.
 * @discussion It is necessary to override this method to handle autocompletion of contexts and
 * projects, which start with "@" and "+" respectively. Autocompletion is handled by a timer,
 * which means that the user has to pause a split second to see the autocompletion list. If the
 * user does not pause, the autocompeltion menu does not display. This implementation was
 * selected so the program does not interrupt the user when typing math (with "+") or email
 * addresses (with "@").
 */
- (void)keyUp:(NSEvent*)event {
    // Start the completion timer if the user types an "@" or "+".
    if ([[event characters] isEqualToString:@"@"] || [[event characters] isEqualToString:@"+"]) {
        [self startCompletionTimer];
    } else {
        [self stopCompletionTimer];
    }
    
    // Call the super so we don't override any other behaviors.
    [super keyUp:event];
}

/*!
 * @method completionsForPartialWordRange:indexOfSelectedItem:
 * @abstract This method returns autocompletion suggestions based on the range it receives.
 * @discussion It is necessary to override this method to handle autocompletion of contexts and
 * projects, which start with "@" and "+" respectively.
 */
- (NSArray*)completionsForPartialWordRange:(NSRange)charRange
                       indexOfSelectedItem:(NSInteger*)index {
    // Check the character range for "@" and "+".
    NSString *partialString = [[self string] substringWithRange:charRange];
    if ([partialString hasSuffix:@"+"]) {
        return self.projectsArray;
    } else if ([partialString hasSuffix:@"@"]) {
        return self.contextsArray;
    } else {
        // Call the super method to get the default behavior.
        // This allows for the user to type Esc and still trigger autocompletion.
        return [super completionsForPartialWordRange:charRange indexOfSelectedItem:index];
    }
}

/*!
 * @method rangeForUserCompletion:
 * @abstract This method returns the range to be replaced by autocompletion.
 * @discussion It is necessary to override this method to handle autocompletion of contexts,
 * which begin with the @ (at) sign. The super's rangeForUserCompletion: method does not
 * consider that an @ sign could start a word, so it returns the word and space before the @
 * sign. When the complete: method fires, the prior word and space are deleted, which is not
 * what is desired.
 */
- (NSRange)rangeForUserCompletion {
    // Call the super method to get the default behavior.
    NSRange superRange = [super rangeForUserCompletion];
    
    // Only override the default behavior if there is an "@" in the partial range.
    NSString *partialString = [[self string] substringWithRange:superRange];
    NSRange atSignRange = [partialString rangeOfString:@"@" options:NSBackwardsSearch];
    if (atSignRange.location == NSNotFound) {
        return superRange;
    }
    
    // Modify the range properties to just return the "@" at the end of the range.
    superRange.location = superRange.location + atSignRange.location;
    superRange.length = 1;
    return superRange;
}

/*!
 * @method: cancelOperation:
 * @abstract This method undoes all changes of the text field being edited when the user hits Esc,
 * if the user has opted for that setting.
 * @discussion This method also triggers autocompletion, again dependent on the user setting.
 */
- (void)cancelOperation:(id)sender {
    // How the Esc key behaves is dependent on a user setting.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"escapeKeyCancelsAllTextChanges"]) {
        // Undo all events on the undoManager's stack. Autocompletion triggers additional undo
        // groups to be created, so one undo or undoNestedGroup call is not enough to undo all
        // changes.
        NSUndoManager *undoManager = [self undoManager];
        while ([undoManager canUndo]) {
            [undoManager undoNestedGroup];
        }
    } else {
        // Trigger autocompletion (default behavior).
        [self complete:nil];
    }
}

@end
