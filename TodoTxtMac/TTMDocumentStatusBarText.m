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

#import "TTMDocumentStatusBarText.h"
#import "TTMDocument.h"
#import "TTMTasklistMetadata.h"
#import "TTMFilterPredicates.h"

@implementation TTMDocumentStatusBarText

NSString* const TTMAllStatusBarAllTaskCountTag = @"{All Tasks}";
NSString* const TTMAllCompletedTaskCount = @"{All Completed}";
NSString* const TTMAllIncompleteTaskCount = @"{All Incomplete}";
NSString* const TTMAllDueTodayTaskCount = @"{All Due Today}";
NSString* const TTMAllOverdueTaskCount = @"{All Overdue}";
NSString* const TTMAllNotDueTaskCount = @"{All Not Due}";
NSString* const TTMAllNoDueDateTaskCount = @"{All No Due Date}";
NSString* const TTMAllProjectsCount = @"{All Projects}";
NSString* const TTMAllContextsCount = @"{All Contexts}";
NSString* const TTMAllPrioritiesCount = @"{All Priorities}";
NSString* const TTMShownStatusBarAllTaskCountTag = @"{Shown Tasks}";
NSString* const TTMShownCompletedTaskCount = @"{Shown Completed}";
NSString* const TTMShownIncompleteTaskCount = @"{Shown Incomplete}";
NSString* const TTMShownDueTodayTaskCount = @"{Shown Due Today}";
NSString* const TTMShownOverdueTaskCount = @"{Shown Overdue}";
NSString* const TTMShownNotDueTaskCount = @"{Shown Not Due}";
NSString* const TTMShownNoDueDateTaskCount = @"{Shown No Due Date}";
NSString* const TTMShownProjectsCount = @"{Shown Projects}";
NSString* const TTMShownContextsCount = @"{Shown Contexts}";
NSString* const TTMShownPrioritiesCount = @"{Shown Priorities}";
NSString* const TTMActiveFilterNumber = @"{Filter Preset}";
NSString* const TTMActiveSortNumber = @"{Sort Preset}";
NSString* const TTMActiveSortName = @"{Sort Name}";
NSString* const TTMSelectedTaskCount = @"{Selected}";
NSString* const TTMHideFutureTasks = @"{Hide Future Tasks}";
NSString* const TTMHideHiddenTasks = @"{Hide Hidden Tasks}";

#pragma mark - Init Method

- (id)initWithTTMDocument:(TTMDocument*)sourceDocument format:(NSString*)format {
    self = [super init];
    if (self) {
        _document = sourceDocument;
        _format = format;
    }
    return self;
}

#pragma mark - Metadata Method

- (NSDictionary*)documentMetadata {
    NSDictionary *sortNames = @{@(TTMSortOrderInFile) : @"File",
                                @(TTMSortPriority) : @"Priority",
                                @(TTMSortProject) : @"Project",
                                @(TTMSortContext) : @"Context",
                                @(TTMSortDueDate) : @"Due Date",
                                @(TTMSortCreationDate) : @"Creation Date",
                                @(TTMSortCompletionDate) : @"Completion Date",
                                @(TTMSortThresholdDate) : @"Threshold Date",
                                @(TTMSortAlphabetical) : @"Alphabetical"
                                };
    
    return @{TTMAllStatusBarAllTaskCountTag : @(self.document.tasklistMetadata.allTaskCount),
             TTMAllCompletedTaskCount : @(self.document.tasklistMetadata.completedTaskCount),
             TTMAllIncompleteTaskCount : @(self.document.tasklistMetadata.incompleteTaskCount),
             TTMAllDueTodayTaskCount : @(self.document.tasklistMetadata.dueTodayTaskCount),
             TTMAllOverdueTaskCount : @(self.document.tasklistMetadata.overdueTaskCount),
             TTMAllNotDueTaskCount : @(self.document.tasklistMetadata.notDueTaskCount),
             TTMAllNoDueDateTaskCount : @(self.document.tasklistMetadata.noDueDateTaskCount),
             TTMAllPrioritiesCount : @(self.document.tasklistMetadata.projectsCount),
             TTMAllProjectsCount : @(self.document.tasklistMetadata.projectsCount),
             TTMAllContextsCount : @(self.document.tasklistMetadata.contextsCount),
             TTMShownStatusBarAllTaskCountTag : @(self.document.filteredTasklistMetadata.allTaskCount),
             TTMShownCompletedTaskCount : @(self.document.filteredTasklistMetadata.completedTaskCount),
             TTMShownIncompleteTaskCount : @(self.document.filteredTasklistMetadata.incompleteTaskCount),
             TTMShownDueTodayTaskCount : @(self.document.filteredTasklistMetadata.dueTodayTaskCount),
             TTMShownOverdueTaskCount : @(self.document.filteredTasklistMetadata.overdueTaskCount),
             TTMShownNotDueTaskCount : @(self.document.filteredTasklistMetadata.notDueTaskCount),
             TTMShownNoDueDateTaskCount : @(self.document.filteredTasklistMetadata.noDueDateTaskCount),
             TTMShownPrioritiesCount : @(self.document.filteredTasklistMetadata.projectsCount),
             TTMShownProjectsCount : @(self.document.filteredTasklistMetadata.projectsCount),
             TTMShownContextsCount : @(self.document.filteredTasklistMetadata.contextsCount),
             TTMActiveFilterNumber : @(self.document.activeFilterPredicateNumber),
             TTMActiveSortNumber : @(self.document.activeSortType),
             TTMActiveSortName : [sortNames objectForKey:@(self.document.activeSortType)],
             TTMSelectedTaskCount : @(self.document.arrayController.selectionIndexes.count),
             TTMHideFutureTasks : [self hideFutureTasks],
             TTMHideHiddenTasks : [self hideHiddenTasks]
             };
}

- (NSString*)hideFutureTasks {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hideFutureTasks"]) {
        return NSLocalizedString(@"Yes", "");
    } else {
        return NSLocalizedString(@"No", "");
    }
}

- (NSString*)hideHiddenTasks {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hideHiddenTasks"]) {
        return NSLocalizedString(@"Yes", "");
    } else {
        return NSLocalizedString(@"No", "");
    }
}

#pragma mark - Output/Property Methods

- (NSString*)statusBarText {
    NSMutableString *text = [self.format mutableCopy];
    NSDictionary *dict = [self documentMetadata];
    for (NSString *key in dict) {
        [text replaceOccurrencesOfString:key
                              withString:[NSString stringWithFormat:@"%@",
                                          [dict objectForKey:key]]
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, text.length)];
    }
    return text;
}

+ (NSArray*)availableTags {
    return @[TTMAllStatusBarAllTaskCountTag,
             TTMAllCompletedTaskCount,
             TTMAllIncompleteTaskCount,
             TTMAllDueTodayTaskCount,
             TTMAllOverdueTaskCount,
             TTMAllNotDueTaskCount,
             TTMAllNoDueDateTaskCount,
             TTMAllPrioritiesCount,
             TTMAllProjectsCount,
             TTMAllContextsCount,
             TTMShownStatusBarAllTaskCountTag,
             TTMShownCompletedTaskCount,
             TTMShownIncompleteTaskCount,
             TTMShownDueTodayTaskCount,
             TTMShownOverdueTaskCount,
             TTMShownNotDueTaskCount,
             TTMShownNoDueDateTaskCount,
             TTMShownPrioritiesCount,
             TTMShownProjectsCount,
             TTMShownContextsCount,
             TTMActiveFilterNumber,
             TTMActiveSortNumber,
             TTMActiveSortName,
             TTMSelectedTaskCount,
             TTMHideFutureTasks,
             TTMHideHiddenTasks
             ];
}

+ (NSString*)defaultFormat {
    return @"Filter #: {Filter Preset} | Sort: {Sort Name} | Tasks: {Shown Tasks} of {All Tasks} | Incomplete: {Shown Incomplete} | Due Today: {Shown Due Today} | Overdue: {Shown Overdue} | Hide Future Tasks: {Hide Future Tasks}";
}

@end
