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

#import "TTMTableViewDelegate.h"
#import "RegExCategories.h"
#import "TTMTask.h"
#import "NSUserDefaults+myColorSupport.h"

@implementation TTMTableViewDelegate

static NSString * const ProjectPattern = @"(?<=^|\\s)(\\+[^\\s]+)";
static NSString * const ContextPattern = @"(?<=^|\\s)(\\@[^\\s]+)";

#pragma mark - TableView Delegate Methods

- (void)tableView:(NSTableView *)tableView
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    // Apply the task's display format to the rawText cell.
    if ([[tableColumn identifier] isEqualToString:@"rawText"]) {
        BOOL selected = ([tableView.selectedRowIndexes containsIndex:row]);
        TTMTask *task = [[self.arrayController arrangedObjects] objectAtIndex:row];
        if ([task.rawText length] > 0) {
            [cell setAttributedStringValue:[self displayText:task isSelected:selected]];
        }
    }
}

#pragma mark - Attributed Text Methods

- (NSAttributedString*)displayText:(TTMTask*)task
                        isSelected:(BOOL)selected {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:task.rawText];
    NSRange fullStringRange = NSMakeRange(0, [as length]);
    
    // Apply strikethrough and light gray color to completed tasks when they are displayed
    // in the tableView.
    if (task.isCompleted) {
        [as addAttribute:NSStrikethroughStyleAttributeName
                   value:(NSNumber*)kCFBooleanTrue
                   range:fullStringRange];
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor lightGrayColor]
                   range:fullStringRange];
        return as;
    }
    
    // Apply boldface to the task priority.
    if (task.isPrioritized) {
        [as applyFontTraits:NSBoldFontMask range:NSMakeRange(0, 3)];
    }
    
    // Only change colors if row is not selected and user wants to see highlight colors.
    if (!selected && [[NSUserDefaults standardUserDefaults]
                      boolForKey:@"useHighlightColorsInTaskList"]) {
        
        // Get the user's preferred highlight colors or the defaults.
        NSColor *dueTodayColor = ([[NSUserDefaults standardUserDefaults]
                                   boolForKey:@"useCustomColorForDueTodayTasks"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"dueTodayColor"] :
            [NSColor redColor];
        NSColor *overdueColor = ([[NSUserDefaults standardUserDefaults]
                                 boolForKey:@"useCustomColorForOverdueTasks"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"overdueColor"] :
            [NSColor purpleColor];
        NSColor *projectsColor = ([[NSUserDefaults standardUserDefaults]
                                  boolForKey:@"useCustomColorForProjects"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"projectColor"] :
            [NSColor darkGrayColor];
        NSColor *contextsColor = ([[NSUserDefaults standardUserDefaults]
                                  boolForKey:@"useCustomColorForContexts"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"contextColor"] :
            [NSColor darkGrayColor];
        
        // Color due texts.
        if (task.dueState == DueToday) {
            [as addAttribute:NSForegroundColorAttributeName
                       value:dueTodayColor
                       range:fullStringRange];
        }
        
        // Color overdue texts.
        if (task.dueState == Overdue) {
            [as addAttribute:NSForegroundColorAttributeName
                       value:overdueColor
                       range:fullStringRange];
        }

        // Color projects.
        NSArray* matches = [task.rawText matchesWithDetails:RX(ProjectPattern)];
        for (RxMatch *match in matches) {
            [as addAttribute:NSForegroundColorAttributeName
                       value:projectsColor
                       range:match.range];
        }
        
        // Color contexts.
        matches = [task.rawText matchesWithDetails:RX(ContextPattern)];
        for (RxMatch *match in matches) {
            [as addAttribute:NSForegroundColorAttributeName
                       value:contextsColor
                       range:match.range];
        }
    }
    
    return as;
}

@end
