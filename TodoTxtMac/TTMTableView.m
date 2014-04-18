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

#import "TTMTableView.h"
#import "TTMDocument.h"
#import "TTMTask.h"

@implementation TTMTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedRawText = nil;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

#pragma mark - Handle Keyboard Events Methods

/*!
 * @method keyDown:
 * @abstract Override the default keyDown event handler to call custom commands,
 * such as those handled by the parent window.
 */
- (void)keyDown:(NSEvent *)theEvent {
    NSUInteger flags = [theEvent modifierFlags];
    NSString *passedChar = [theEvent charactersIgnoringModifiers];
    unichar keyChar = [passedChar characterAtIndex:0];

    // tab key (we do not want the tab key to trigger edit mode)
    if (keyChar == 9) {
        [self translateKeyDownEvent:theEvent toKeyDown:keyChar sendToControl:[self window]];
        return;
    }

    // command+c to copy selected tasks
    if ((flags & NSCommandKeyMask) &&
        (keyChar == 'c')) {
        [self translateKeyDownEvent:theEvent toKeyDown:keyChar sendToControl:[self window]];
        return;
    }

    // handle command+option+arrow key combinations
    if ((flags & NSCommandKeyMask) &&
        (flags & NSNumericPadKeyMask) &&
        (flags & NSAlternateKeyMask)) {
        [self translateKeyDownEvent:theEvent toKeyDown:keyChar sendToControl:[self window]];
        return;
    }
    
    // handle command+arrow key combinations
    if ((flags & NSCommandKeyMask) &&
        (flags & NSNumericPadKeyMask)) {
        [self translateKeyDownEvent:theEvent toKeyDown:keyChar sendToControl:[self window]];
        return;
    }
    
    // do not override the super for other special key combinations
    if ((flags & NSCommandKeyMask) ||
        (flags & NSControlKeyMask) ||
        (flags & NSAlternateKeyMask)) {
        [super keyDown:theEvent];
        return;
    }

    // delete/backspace
    if (keyChar == NSBackspaceCharacter) {
        [self translateKeyDownEvent:theEvent
                          toKeyDown:NSBackspaceCharacter
                      sendToControl:[self window]];
        return;
    }

    // move down
    if (keyChar == 'j') {
        [self translateKeyDownEvent:theEvent toKeyDown:NSDownArrowFunctionKey sendToControl:self];
        return;
    }
    
    // move up
    if (keyChar == 'k') {
        [self translateKeyDownEvent:theEvent toKeyDown:NSUpArrowFunctionKey sendToControl:self];
        return;
    }
    
    // update task (send Enter/Return to super)
    if (keyChar == 'u') {
        [self translateKeyDownEvent:theEvent toKeyDown:NSEnterCharacter sendToControl:self];
        return;
    }
    
    // Handle all other single-character commands (those that do not require translating
    // to different key presses) by passing them to the parent window.
    // The key equivalents are defined for the menu items in MainMenu.xib
    NSMutableCharacterSet *singleKeyCommands = [[NSMutableCharacterSet alloc] init];
    [singleKeyCommands addCharactersInString:@"nxdfprcsai.0123456789"];
    if ([singleKeyCommands characterIsMember:keyChar]) {
        [self translateKeyDownEvent:theEvent toKeyDown:keyChar sendToControl:[self window]];
        return;
    }

    // default behavior: pass the event to the super if we didn't make a match above
    [super keyDown:theEvent];
}

- (void)translateKeyDownEvent:(NSEvent*)theEvent
                    toKeyDown:(unichar)keyDown
                sendToControl:(id)targetControl {
    NSString *keyDownString = [NSString stringWithCharacters:&keyDown length:1];
    NSEvent *newEvent =[NSEvent keyEventWithType:NSKeyDown
                                        location:theEvent.locationInWindow
                                   modifierFlags:theEvent.modifierFlags
                                       timestamp:theEvent.timestamp
                                    windowNumber:theEvent.windowNumber
                                         context:nil
                                      characters:keyDownString
                     charactersIgnoringModifiers:keyDownString
                                       isARepeat:theEvent.isARepeat
                                         keyCode:keyDown];
    if (targetControl == self || nil == targetControl)
    {
        [super keyDown:newEvent];
    }  else {
        [targetControl keyDown:newEvent];
    }
}

#pragma mark - Respond to Changes Methods

- (void)textDidBeginEditing:(NSNotification *)notification {
    [super textDidBeginEditing:notification];
    self.selectedRawText = [[notification object] string];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    [super textDidEndEditing:notification];
    NSString *newValue = [[notification object] string];
    
    // Handle no change.
    if (self.selectedRawText == nil ||
        [self.selectedRawText isEqualToString:newValue]) {
        return;
    }
    
    [self.parentDocument refreshTaskListWithSave:YES];
    self.selectedRawText = nil;
}

#pragma mark - Drag and Drop Methods

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self.parentDocument addNewTasksFromDragAndDrop:sender];
}

#pragma mark - Row Height Methods

- (CGFloat)rowHeight {
    return ([self.parentDocument usingUserFont]) ?
        [self defaultLineHeightForFont:[self.parentDocument userFont]] :
        [super rowHeight];
}

- (CGFloat)defaultLineHeightForFont:(NSFont*)font {
    // Use default user font if font is nil.
    if (font == nil) {
        font = [NSFont userFontOfSize:0];
    }
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager setTypesetterBehavior:NSTypesetterBehavior_10_2_WithCompatibility];
    [layoutManager setUsesScreenFonts:YES];
    return [layoutManager defaultLineHeightForFont:font];
}


@end
