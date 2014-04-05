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

#import "TTMTask.h"
#import "RegExCategories.h"
#import "TTMDateUtility.h"

@implementation TTMTask

@synthesize rawText=_rawText;

// define constants for regular expressions
static NSString * const LineBreakPattern = @"(\\r|\\n)";
static NSString * const CompletedPattern = @"^x\\s((\\d{4})-(\\d{2})-(\\d{2}))\\s";
static NSString * const CompletionDatePattern = @"(?<=^x\\s)((\\d{4})-(\\d{2})-(\\d{2}))";
static NSString * const PriorityTextPattern = @"^(\\([A-Z]\\)\\s)";
static NSString * const CreationDatePatternIncomplete =
    @"(?<=^|\\([A-Z]\\)\\s)((\\d{4})-(\\d{2})-(\\d{2}))";
static NSString * const CreationDatePatternCompleted =
    @"(?<=^x\\s((\\d{4})-(\\d{2})-(\\d{2}))\\s)((\\d{4})-(\\d{2})-(\\d{2}))";
static NSString * const DueDatePattern = @"(?<=due:)((\\d{4})-(\\d{2})-(\\d{2}))";
static NSString * const FullDueDatePattern = @"(\\sdue:)((\\d{4})-(\\d{2})-(\\d{2}))";
static NSString * const ProjectPattern = @"(?<=^|\\s)(\\+[^\\s]+)";
static NSString * const ContextPattern = @"(?<=^|\\s)(\\@[^\\s]+)";

#pragma mark - Init Methods

- (id)initWithRawText:(NSString*)rawText withTaskId:(NSInteger)taskId
   withPrependedDate:(NSDate*)prependedDate {
    self = [super init];
    if (self) {
        
        _taskId = taskId;
        [self setRawText:rawText withPrependedDate:prependedDate];
        
    }
    return self;
}

- (id)initWithRawText:(NSString*)rawText withTaskId:(NSInteger)taskId {
    
    return [self initWithRawText:rawText withTaskId:taskId withPrependedDate:nil];
}

#pragma mark - rawText Methods

- (void)setRawText:(NSString*)rawText withPrependedDate:(NSDate*)prependedDate {
    // prepend date only if a prependedDate is passed and if there isn't already a creation date
    if (!prependedDate  ||
        [rawText isMatch:RX(CreationDatePatternIncomplete)] ||
        [rawText isMatch:RX(CreationDatePatternCompleted)]
        ) {
        [self setRawText:rawText];
    } else {
        NSString *newRawText = [NSString stringWithFormat:@"%@%c%@",
            [TTMDateUtility convertDateToString:prependedDate], ' ', rawText];
        [self setRawText:newRawText];
    }
}

- (void)setRawText:(NSString*)rawText {
    // only update rawText and other properties if the new raw text differs from the old raw text
    if ([rawText isEqualToString:_rawText]) {
        return;
    }
    
    // make sure the task doesn't contain line breaks
    _rawText = [rawText replace:RX(LineBreakPattern) with:@""];

    // handle blank strings gracefully
    if (rawText == nil || [rawText isEqualToString:@""]) {
        _isBlank = YES;
        _isCompleted = NO;
        _isPrioritized = NO;
        _priorityText = @"";
        _priority = ' ';
        _contexts = @"";
        _contextsArray = nil;
        _projects = @"";
        _projectsArray = nil;
        _completionDateText = nil;
        _completionDate = nil;
        _dueDateText = @"";
        _dueDate = nil;
        _creationDateText = @"";
        _dueState = NotDue;
        _hasContexts = NO;
        _hasProjects = NO;
        return;
    }
    
    // set properties for non-blank strings
    _isBlank = NO;
    _isCompleted = [_rawText isMatch:RX(CompletedPattern)];
    _isPrioritized = [_rawText isMatch:RX(PriorityTextPattern)];
    
    // priority
    _fullPriorityText = [_rawText firstMatch:RX(PriorityTextPattern)];
    NSRange range = {.location = 1, .length = 1};
    _priorityText = [_fullPriorityText substringWithRange:range];
    // Set priority to tilde (~) to ensure that tasks with no priority are sorted after
    // tasks with any other priority (A-Z).
    _priority = (_priorityText != nil) ? [_priorityText characterAtIndex:0] : '~';
    
    // sorted array of projects
    _projectsArray = [[_rawText matches:RX(ProjectPattern)]
                      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    _projects = [_projectsArray componentsJoinedByString:@", "];
    _hasProjects = (_projectsArray.count > 0);

    // sorted array of contexts
    _contextsArray = [[_rawText matches:RX(ContextPattern)]
                      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    _contexts = [_contextsArray componentsJoinedByString:@", "];
    _hasContexts = (_contextsArray.count > 0);
    
    // completion date
    _completionDateText = [_rawText firstMatch:RX(CompletionDatePattern)];
    // Set completion date to the high date (9999-12-31) to ensure that tasks with no
    // completion date are sorted after tasks with a due date.
    _completionDate = (_completionDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        [TTMDateUtility convertStringToDate:_completionDateText];
    
    // due date
    _dueDateText = [_rawText firstMatch:RX(DueDatePattern)];
    // Set due date to the high date (9999-12-31) to ensure that tasks with no due date
    // are sorted after tasks with a due date.
    _dueDate = (_dueDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        [TTMDateUtility convertStringToDate:_dueDateText];
    
    // creation date
    _creationDateText = _isCompleted ?
        [_rawText firstMatch:RX(CreationDatePatternCompleted)] :
        [_rawText firstMatch:RX(CreationDatePatternIncomplete)];
    // Set creation date to the high date (9999012031) to ensure that tasks with no
    // creation date are sorted after tasks with a creation date.
    _creationDate = (_creationDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        [TTMDateUtility convertStringToDate:_creationDateText];
    
    // due state (past due, due today, not due)
    _dueState = [self getDueState];
}

- (NSString*)rawText {
    return _rawText;
}

- (NSAttributedString*)displayText {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:self.rawText];
    NSRange fullStringRange = NSMakeRange(0, [as length]);
    // Apply strikethrough and light gray color to completed tasks when they are displayed
    // in the tableView.
    if (self.isCompleted) {
        [as addAttribute:NSStrikethroughStyleAttributeName
                   value:(NSNumber *)kCFBooleanTrue
                   range:fullStringRange];
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor lightGrayColor]
                   range:fullStringRange];
    }
    
    // Apply boldface to the task priority.
    if (self.isPrioritized) {
        [as applyFontTraits:NSBoldFontMask range:NSMakeRange(0, 3)];
    }
    
    // Mark due texts in red.
    if (self.dueState == DueToday) {
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor redColor]
                   range:fullStringRange];
    }
    
    // Mark overdue texts in purple.
    if (self.dueState == Overdue) {
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor purpleColor]
                   range:fullStringRange];
    }
    
    // Highlight projects.
    NSArray* matches = [self.rawText matchesWithDetails:RX(ProjectPattern)];
    for (RxMatch *match in matches) {
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor darkGrayColor]
                   range:match.range];
    }
    
    // Highlight contexts.
    matches = [self.rawText matchesWithDetails:RX(ContextPattern)];
    for (RxMatch *match in matches) {
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor darkGrayColor]
                   range:match.range];
    }
    
    return as;
}

#pragma mark - Due/Not Due Method

- (TTMDueState)getDueState {
    // completed tasks and those with no due dates are automatically not due
    if (nil == self.dueDate || self.isCompleted || [self.dueDateText isEqual:[NSNull null]])
        return NotDue;
    
    // If there is a due date, compare it to today's date to determine
    // if the task is overdue, not due, or due today.
    NSDate *todaysDate = [TTMDateUtility today];
    NSInteger interval = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                          fromDate:todaysDate
                                                            toDate:self.dueDate
                                                           options:0] day];
    if (interval < 0) {
        return Overdue;
    } else if (interval > 0) {
        return NotDue;
    } else {
        return DueToday;
    }
}

#pragma mark - Priority Methods

- (void)setPriority:(unichar)priority {
    // Blanks and completed tasks don't get priorities.
    if (self.isBlank || self.isCompleted) {
        return;
    }
    
    // Test whether priority parameter is a valid character [A-Z].
    NSCharacterSet *letters = [NSCharacterSet uppercaseLetterCharacterSet];
    if (![letters characterIsMember:priority]) {
        return;
    }
    
    // If there is a priority, find it and replace it with the new priority.
    // If there is no priority, prepend it to the beginning of rawText
    // and update all class properties.
    if (self.isPrioritized) {
        NSRange oldPriority = [self.rawText rangeOfString:self.fullPriorityText];
        if (NSNotFound != oldPriority.location) {
            self.rawText =
             [self.rawText stringByReplacingCharactersInRange:oldPriority
              withString:[NSString stringWithFormat:@"%c%c%c%c", '(', priority, ')', ' ']];
        }
    } else {
        self.rawText = [NSString stringWithFormat:@"%c%c%c %@", '(', priority, ')', self.rawText];
    }
}

- (void)increasePriority {
    // Blank and completed tasks don't get priorities
    if (self.isBlank || self.isCompleted) {
        return;
    }
    
    // Non-prioritized tasks automatically get the top priority
    if (!self.isPrioritized) {
        return [self setPriority:'A'];
    }
    
    // There is no priority greater than 'A'.
    if (self.priority == 'A') {
        return;
    }
    
    // increase priority of task (e.g. 'B' - 1 = 'A')
    self.priority = self.priority - 1;
//    [self setPriority:(self.priority - 1)];
}

- (void)decreasePriority {
    // Blank and completed tasks don't get priorities
    if (self.isBlank || self.isCompleted) {
        return;
    }
    
    // There is no priority less than 'Z'.
    if (self.priority == 'Z') {
        return;
    }
    
    // non-prioritized tasks automatically get the top priority
    if (!self.isPrioritized) {
        [self setPriority:'A'];
        return;
    }
    
    // decrease priority of task (e.g. 'A' + 1 = 'B')
    self.priority = self.priority + 1;
//    [self setPriority:(self.priority + 1)];
}

- (void)removePriority {
    // Blank, completed, and non-prioritized tasks don't have priorities.
    if (self.isBlank || self.isCompleted || !self.isPrioritized) {
        return;
    }
    
    // Remove the priority substring and update all class properties.
    self.rawText = [RX(PriorityTextPattern) replace:self.rawText with:@""];
}

#pragma mark - Completion Methods

- (void)markComplete {
    // Completed tasks don't need to be completed again. Blank tasks can't be completed.
    if (self.isBlank || self.isCompleted) {
        return;
    }
    
    // Build new task rawText by removing priority and prepending "x" and today's date.

    // Remove priority if it exists.
    NSString *rawTextWithoutPriority = (self.isPrioritized) ?
        [self.rawText replace:RX(PriorityTextPattern) with:@""] :
        self.rawText;
    
    // Prepend the new raw task string with "x yyyy-MM-dd " (note the trailing space),
    // with today's date as "yyyy-MM-dd".
    NSString *newRawText = [NSString stringWithFormat:@"%@%c%@%c%@", @"x", ' ',
        [TTMDateUtility todayAsString], ' ', rawTextWithoutPriority];
    
    // Update the task's raw text.
    [self setRawText:newRawText];
}

- (void)markIncomplete {
    // Incomplete tasks don't need to be marked incomplete again.
    // Blank tasks can't be marked incompleted.
    if (self.isBlank || !self.isCompleted) {
        return;
    }
    
    // Remove the completed task prepended substring and update all class properties.
    [self setRawText:[RX(CompletedPattern) replace:self.rawText with:@""]];
}

- (void)toggleCompletionStatus {
    if (self.isCompleted) {
        [self markIncomplete];
    } else {
        [self markComplete];
    }
}

# pragma mark - Postpone and Set Due Date Methods

- (void)postponeTask:(NSInteger)daysToPostpone {
    
    // Blank and completed tasks don't get postponed.
    if (self.isBlank || self.isCompleted) {
        return;
    }

    if (daysToPostpone == 0) {
        return;
    }

    // Get due date of the selected task.
    // If the selected task doesn't have a due date, use today as the due date.
    NSDate *oldDueDate = (self.dueDateText != nil) ? self.dueDate : [TTMDateUtility today];

    // Add days to that date to create the new due date.
    NSDate *newDueDate = [TTMDateUtility addDays:daysToPostpone toDate:oldDueDate];

    [self setDueDate:newDueDate];
}

- (void)setDueDate:(NSDate *)dueDate {
    NSString *newDueDateText = [TTMDateUtility convertDateToString:dueDate];
    // If the item has a due date, exchange the current due date with the new.
    // Else if the item does not have a due date, append the new due date to the task.
    self.rawText = (self.dueDateText != nil) ?
        [self.rawText replace:RX(DueDatePattern) with:newDueDateText] :
        [self.rawText stringByAppendingFormat:@" due:%@", newDueDateText];
}

- (void)removeDueDate {
    // Blank and tasks without a due date do not get updated.
    if (self.isBlank || !self.dueDate) {
        return;
    }
    self.rawText = [self.rawText replace:RX(FullDueDatePattern) with:@""];
}

@end
