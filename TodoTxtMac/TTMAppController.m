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

#import "TTMAppController.h"
#import "TTMPreferencesController.h"
#import "TTMFiltersController.h"
#import "TTMFilterPredicates.h"
#import "TTMDocument.h"

// Default user preference values, including those for saved filters
static NSDictionary *defaultValues() {
    
    static NSData *defaultPredicateData = nil;
    if (defaultPredicateData == nil) {
        defaultPredicateData = [TTMFilterPredicates defaultFilterPredicateData];
    }

    static NSDictionary *dict = nil;
    if (!dict) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @NO, @"prependDateOnNewTasks",
                @1, @"taskListSortType",
                defaultPredicateData, @"activefilterPredicate",
                @0, @"activefilterPreset",
                defaultPredicateData, @"filterPredicate1",
                defaultPredicateData, @"filterPredicate2",
                defaultPredicateData, @"filterPredicate3",
                defaultPredicateData, @"filterPredicate4",
                defaultPredicateData, @"filterPredicate5",
                defaultPredicateData, @"filterPredicate6",
                defaultPredicateData, @"filterPredicate7",
                defaultPredicateData, @"filterPredicate8",
                defaultPredicateData, @"filterPredicate9",
                @"", @"archiveFilePath",
                @NO, @"archiveTasksUponCompletion",
                @NO, @"useUserFont",
                @NO, @"moveToTaskListAfterTaskCreation",
                @YES, @"useHighlightColorsInTaskList",
                @NO, @"useCustomColorForOverdueTasks",
                @NO, @"useCustomColorForDueTodayTasks",
                @NO, @"useCustomColorForProjects",
                @NO, @"useCustomColorForContexts",
                @NO, @"useCustomColorForTags",
                @NO, @"useCustomColorForDueDates",
                @NO, @"useCustomColorForThresholdDates",
                [NSArchiver archivedDataWithRootObject:[NSColor redColor]], @"dueTodayColor",
                [NSArchiver archivedDataWithRootObject:[NSColor purpleColor]], @"overdueColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"projectColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"contextColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"tagColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"dueDateColor",
                [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]], @"thresholdDateColor",
                @NO, @"escapeKeyCancelsAllTextChanges",
                @NO, @"openDefaultTodoFileOnStartup",
                @"", @"defaultTodoFilePath",
                @YES, @"showStatusBar",
                @"Filter #: {Filter Preset} | Sort: {Sort Name} | Tasks: {Shown Tasks} of {All Tasks} | Incomplete: {Shown Incomplete} | Due Today: {All Due Today} | Overdue: {All Overdue}", @"statusBarFormat",
                nil];
    }
    return dict;
}

// Default user preference values, excluding those for saved filters.
// Defined to help allow users to reset preferences without losing saved filters.
static NSDictionary *defaultValuesExcludingFilters() {
    static NSMutableDictionary *defaults = nil;
    if (defaults == nil) {
        defaults = [NSMutableDictionary dictionaryWithDictionary:defaultValues()];
        for (int i = 1; i <= 9; i++) {
            [defaults removeObjectForKey:[TTMFilterPredicates keyFromPresetNumber:i]];
        }
        [defaults removeObjectForKey:@"activefilterPredicate"];
    }
    return defaults;
}

@implementation TTMAppController

// Constants for command-line argument names
NSString *const TodoFileArgument = @"todo-file";

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (IBAction)openPreferencesWindow:(id)sender {
    if (!self.preferencesController) {
        self.preferencesController = [[TTMPreferencesController alloc]
                                      initWithWindowNibName:@"TTMPreferences"];
    }
    [self.preferencesController showWindow:self];
}

- (IBAction)openFiltersWindow:(id)sender {
    if (!self.filtersController) {
        self.filtersController = [[TTMFiltersController alloc]
                                  initWithWindowNibName:@"TTMFilters"];
    }
    [self.filtersController showWindow:self];
}

- (IBAction)openWebSite:(id)sender {
    NSURL *helpURL = [NSURL URLWithString:@"http://mjdescy.github.io/TodoTxtMac/"];
    [[NSWorkspace sharedWorkspace] openURL:helpURL];
}

#pragma mark - User Defaults-related Methods

- (void)initializeUserDefaults:(id)sender {
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues()];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
}

- (void)resetUserDefaults:(id)sender {
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:
                                                                 defaultValuesExcludingFilters()];
    [[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:self];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
}

#pragma mark - Command-line Argument-related Methods

- (void)openTodoFileFromCommandLineArgument {
    NSString *fileToOpenOnLaunch = [self commandLineArgumentTodoFile];
    if (!fileToOpenOnLaunch) {
        return;
    }
    [self openDocumentFromFilePath:fileToOpenOnLaunch];
}

- (NSString*)commandLineArgumentTodoFile {
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    return [args stringForKey:TodoFileArgument];
}

- (void)openDocumentFromFilePath:(NSString*)filePath {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self openDocumentFromFileURL:fileURL];
}

- (void)openDocumentFromFileURL:(NSURL*)fileURL {
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fileURL
                                                                           display:YES
                                                                 completionHandler:NULL];
}

#pragma mark - Open Default Todo.txt File Methods

-(void)openDefaultTodoFile {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"openDefaultTodoFileOnStartup"]) {
        return;
    }
    [self openDocumentFromFilePath:[[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"defaultTodoFilePath"]];
}

#pragma mark - Close All Windows Methods

- (IBAction)closeAllWindows:(id)sender {
    [[NSDocumentController sharedDocumentController]
         closeAllDocumentsWithDelegate:self
                   didCloseAllSelector:@selector(documentController:didCloseAll:contextInfo:)
                           contextInfo:NULL];
}

- (void)documentController:(NSDocumentController *)docController
                     didCloseAll:(BOOL)didCloseAll
                     contextInfo:(void *)contextInfo {
    return;
}

#pragma mark - Reload All Methods

- (IBAction)reloadAll:(id)sender {
    NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
    [documents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(TTMDocument*)obj reloadFile:self];
    }];
}

#pragma mark - Visual Refresh Methods

- (IBAction)visualRefreshAll:(id)sender {
    NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
    [documents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(TTMDocument*)obj visualRefreshOnly:self];
    }];
}

@end
