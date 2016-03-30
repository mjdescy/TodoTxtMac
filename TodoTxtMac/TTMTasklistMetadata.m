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

#import "TTMTasklistMetadata.h"
#import "TTMTask.h"

@implementation TTMTasklistMetadata

- (void)updateMetadataFromTaskArray:(NSArray*)taskArray {
    [self initialize];
    
    for (TTMTask *task in taskArray) {
     
        // update task counts
        self.allTaskCount++;
        self.completedTaskCount += (task.isCompleted ? 1 : 0);
        self.incompleteTaskCount += (task.isCompleted ? 0 : 1);
        self.dueTodayTaskCount += (task.dueState == DueToday ? 1 : 0);
        self.overdueTaskCount += (task.dueState == Overdue ? 1 : 0);
        self.notDueTaskCount += (task.dueState == NotDue ? 1 : 0);
        self.noDueDateTaskCount += (task.dueState == NoDueDate ? 1 : 0);

        // update task counts by project and context
        [self incrementCountsInDictionary:self.projectTaskCounts FromArray:task.projectsArray];
        [self incrementCountsInDictionary:self.contextTaskCounts FromArray:task.contextsArray];
        
        // add all projects and contexts to sets
        [self.projectsSet addObjectsFromArray:task.projectsArray];
        [self.contextsSet addObjectsFromArray:task.contextsArray];
        
        // update task count by priority, and add priority to set
        if (task.priorityText != nil) {
            [self incrementCountsInDictionary:self.priorityTaskCounts
                                    FromArray:@[task.priorityText]];
            [self.prioritiesSet addObject:task.priorityText];
        }
    }

    // Convert the sets to case-insensitive-sorted arrays.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@""
                                        ascending:YES
                                        selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    self.projectsArray = [self.projectsSet sortedArrayUsingDescriptors:sortDescriptorArray];
    self.contextsArray = [self.contextsSet sortedArrayUsingDescriptors:sortDescriptorArray];
    self.prioritiesArray = [self.prioritiesSet sortedArrayUsingDescriptors:sortDescriptorArray];

    // update counts of projects, contexts, and priorities
    self.projectsCount = [self.projectsSet count];
    self.contextsCount = [self.contextsSet count];
    self.prioritiesCount = [self.prioritiesSet count];
}

- (void)initialize {
    self.allTaskCount = 0;
    self.completedTaskCount = 0;
    self.incompleteTaskCount = 0;
    self.dueTodayTaskCount = 0;
    self.overdueTaskCount = 0;
    self.notDueTaskCount = 0;
    self.noDueDateTaskCount = 0;
    
    self.projectTaskCounts = [NSMutableDictionary dictionary];
    self.contextTaskCounts = [NSMutableDictionary dictionary];
    self.priorityTaskCounts = [NSMutableDictionary dictionary];
    
    self.projectsSet = [NSMutableSet set];
    self.contextsSet = [NSMutableSet set];
    self.prioritiesSet = [NSMutableSet set];
    
    self.projectsArray = [NSArray array];
    self.contextsArray = [NSArray array];
    self.prioritiesArray = [NSArray array];
    
    self.projectsCount = 0;
    self.contextsCount = 0;
    self.prioritiesCount = 0;
}

- (void)incrementCountsInDictionary:(NSMutableDictionary*)dictionary FromArray:(NSArray*)array {
    for (NSString *key in array) {
        if (dictionary[key] == nil) {
            dictionary[key] = @1;
        } else {
            dictionary[key] = @([dictionary[key] integerValue] + 1);
        }
    }
}

- (NSString*)projects {
    return [self.projectsArray componentsJoinedByString:@"\n"];
}

- (NSString*)contexts {
    return [self.contextsArray componentsJoinedByString:@"\n"];
}

@end
