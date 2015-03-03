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

#import "TTMTableViewDelegate.h"
#import "RegExCategories.h"
#import "TTMTask.h"
#import "NSUserDefaults+myColorSupport.h"

@implementation TTMTableViewDelegate

#pragma mark - TableView Delegate Methods

- (void)tableView:(NSTableView *)tableView
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    // Apply the task's display format to the rawText cell.
    if ([[tableColumn identifier] isEqualToString:@"rawText"]) {
        TTMTask *task = [[self.arrayController arrangedObjects] objectAtIndex:row];
        if (nil == task || task.isBlank) {
            return;
        }

        // Get the user's preferred highlight colors or the defaults.
        BOOL selected = ([tableView.selectedRowIndexes containsIndex:row]);
        BOOL useHighlightColorsInTaskList = [[NSUserDefaults standardUserDefaults]
                                             boolForKey:@"useHighlightColorsInTaskList"];
        NSColor *completedColor = [NSColor lightGrayColor];
        NSColor *dueTodayColor = ([[NSUserDefaults standardUserDefaults]
                                   boolForKey:@"useCustomColorForDueTodayTasks"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"dueTodayColor"] :
            [NSColor redColor];
        NSColor *overdueColor = ([[NSUserDefaults standardUserDefaults]
                                  boolForKey:@"useCustomColorForOverdueTasks"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"overdueColor"] :
            [NSColor purpleColor];
        NSColor *projectColor = ([[NSUserDefaults standardUserDefaults]
                                  boolForKey:@"useCustomColorForProjects"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"projectColor"] :
            [NSColor darkGrayColor];
        NSColor *contextColor = ([[NSUserDefaults standardUserDefaults]
                                  boolForKey:@"useCustomColorForContexts"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"contextColor"] :
            [NSColor darkGrayColor];
        NSColor *tagColor = ([[NSUserDefaults standardUserDefaults]
                              boolForKey:@"useCustomColorForTags"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"tagColor"] :
            [NSColor darkGrayColor];
        NSColor *dueDateColor = ([[NSUserDefaults standardUserDefaults]
                                  boolForKey:@"useCustomColorForDueDates"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"dueDateColor"] :
            [NSColor darkGrayColor];
        NSColor *thresholdDateColor = ([[NSUserDefaults standardUserDefaults]
                                        boolForKey:@"useCustomColorForThresholdDates"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"thresholdDateColor"] :
            [NSColor darkGrayColor];
        NSColor *creationDateColor = ([[NSUserDefaults standardUserDefaults]
                                        boolForKey:@"useCustomColorForCreationDates"]) ?
            [[NSUserDefaults standardUserDefaults] colorForKey:@"creationDateColor"] :
            [NSColor darkGrayColor];

        NSAttributedString *as = [task displayText:selected
                      useHighlightColorsInTaskList:useHighlightColorsInTaskList
                                    completedColor:completedColor
                                     dueTodayColor:dueTodayColor
                                      overdueColor:overdueColor
                                      projectColor:projectColor
                                      contextColor:contextColor
                                          tagColor:tagColor
                                      dueDateColor:dueDateColor
                                thresholdDateColor:thresholdDateColor
                                 creationDateColor:creationDateColor];
        
        [cell setAttributedStringValue:as];
    }
}

@end
