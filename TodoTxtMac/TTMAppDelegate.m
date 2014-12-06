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

#import "TTMAppDelegate.h"
#import "TTMFilterPredicates.h"
#import "TTMAppController.h"

static NSDictionary *defaultValues() {
    
    static NSData *newPredicateData = nil;
    if (!newPredicateData) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"rawText != ''"];
        newPredicateData = [NSKeyedArchiver archivedDataWithRootObject:newPredicate];
    }
    
    static NSDictionary *dict = nil;
    if (!dict) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @NO, @"prependDateOnNewTasks",
                @1, @"taskListSortType",
                newPredicateData, @"activefilterPredicate",
                newPredicateData, @"filter1Predicate",
                newPredicateData, @"filter2Predicate",
                newPredicateData, @"filter3Predicate",
                newPredicateData, @"filter4Predicate",
                newPredicateData, @"filter5Predicate",
                newPredicateData, @"filter6Predicate",
                newPredicateData, @"filter7Predicate",
                newPredicateData, @"filter8Predicate",
                newPredicateData, @"filter9Predicate",
                @"", @"archiveFilePath",
                @NO, @"archiveTasksUponCompletion",
                @NO, @"useUserFont",
                @NO, @"moveToTaskListAfterTaskCreation",
                @YES, @"useHighlightColorsInTaskList",
                @NO, @"useCustomColorForOverdueTasks",
                @NO, @"useCustomColorForDueTodayTasks",
                @NO, @"useCustomColorForProjects",
                @NO, @"useCustomColorForContexts",
                @NO, @"useCustomColorForDueDates",
                [NSArchiver archivedDataWithRootObject:[NSColor redColor]], @"dueTodayColor",
                [NSArchiver archivedDataWithRootObject:[NSColor purpleColor]], @"overdueColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"projectColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"contextColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"dueDateColor",
                @NO, @"escapeKeyCancelsAllTextChanges",
                @NO, @"openDefaultTodoFileOnStartup",
                @"", @"defaultTodoFilePath",
                nil];
    }
    return dict;
}

@implementation TTMAppDelegate

+ (void)initialize {
    // Set up default values for preferences managed by NSUserDefaultsController
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues()];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
    
    [super initialize];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Open file from command line argument. Does nothing if there is no command line argument.
    [self.appController openTodoFileFromCommandLineArgument];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    // Suppress creating an Untitled document on launch if there is a command line argument
    // to open a todo file. Without this method override, opening a todo file using the
    // command line argument also opens an Untitled document every time.
    return ([self.appController commandLineArgumentTodoFile] == NULL);
}

@end
