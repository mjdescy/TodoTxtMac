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

#import "TTMTask.h"
#import "RegExCategories.h"
#import "TTMDateUtility.h"
#import "NSMutableAttributableString+ColorRegExMatches.h"

@implementation TTMTask

@synthesize rawText=_rawText;

// define constants for regular expressions
static NSString * const LineBreakPattern = @"(\\r|\\n)";
static NSString * const CompletedPattern = @"^x[ ]((\\d{4})-(\\d{2})-(\\d{2}))[ ]";
static NSString * const CompletionDatePattern = @"(?<=^x[ ])((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const PriorityTextPattern = @"^(\\([A-Z]\\)[ ])";
static NSString * const CreationDatePatternIncomplete = @"(?<=^|\\([A-Z]\\)[ ])((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const CreationDatePatternCompleted = @"(?<=^x[ ]((\\d{4})-(\\d{2})-(\\d{2}))[ ])((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const DueDatePattern = @"(?<=(^|[ ])due:)((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const FullDueDatePatternMiddleOrEnd = @"(([ ])due:)((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const FullDueDatePatternBeginning = @"^due:((\\d{4})-(\\d{2})-(\\d{2}))[ ]?|$";
static NSString * const ThresholdDatePattern = @"(?<=(^|[ ])t:)((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const FullThresholdDatePatternMiddleOrEnd = @"(([ ])t:)((\\d{4})-(\\d{2})-(\\d{2}))(?=[ ]|$)";
static NSString * const FullThresholdDatePatternBeginning = @"^t:((\\d{4})-(\\d{2})-(\\d{2}))[ ]?|$";
static NSString * const ProjectPattern = @"(?<=^|[ ])(\\+[^[ ]]+)";
static NSString * const ContextPattern = @"(?<=^|[ ])(\\@[^[ ]]+)";
static NSString * const TagPattern = @"(?<=^|[ ])([:graph:]+:[:graph:]+)";

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
    NSString *newRawText;
    
    if (!prependedDate ||
        [rawText isMatch:RX(CreationDatePatternIncomplete)] ||
        [rawText isMatch:RX(CreationDatePatternCompleted)]
        ) {

        // if no prepended date is passed, or if there is already a creation date, prepend nothing
        newRawText = rawText;
    
    } else if ([rawText isMatch:RX(PriorityTextPattern)]) {
        
        // if the rawText has a priority, prepend the date after the priority
        newRawText = [NSString stringWithFormat:@"%@%@%c%@",
                      [rawText substringToIndex:4],
                      [TTMDateUtility convertDateToString:prependedDate],
                      ' ',
                      [rawText substringFromIndex:4]];
        
    } else {
        
        // if the rawText has no priority, prepend the date at the beginning of the string
        newRawText = [NSString stringWithFormat:@"%@%c%@",
                      [TTMDateUtility convertDateToString:prependedDate],
                      ' ',
                      rawText];
    }
    
    [self setRawText:newRawText];
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
        _priority = '~';
        _contexts = @"";
        _contextsArray = nil;
        _projects = @"";
        _projectsArray = nil;
        _completionDateText = @"";
        _completionDate = nil;
        _dueDateText = @"";
        _dueDate = nil;
        _creationDateText = @"";
        _creationDate = nil;
        _thresholdDateText = @"";
        _thresholdDate = nil;
        _dueState = NotDue;
        _hasContexts = NO;
        _hasProjects = NO;
        return;
    }
    
    // set properties for non-blank strings
    _isBlank = NO;
    
    // completion date
    _completionDateText = [_rawText firstMatch:RX(CompletionDatePattern)];
    // Set completion date to the high date (9999-12-31) to ensure that tasks with no
    // completion date are sorted after tasks with a due date.
    NSDate *newCompletionDate = (_completionDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        [TTMDateUtility convertStringToDate:_completionDateText];
    _completionDate = (newCompletionDate == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        newCompletionDate;
    _isCompleted = [_rawText isMatch:RX(CompletedPattern)] && (newCompletionDate != nil);
    
    // priority
    _isPrioritized = [_rawText isMatch:RX(PriorityTextPattern)];
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
    
    // due date
    _dueDateText = [_rawText firstMatch:RX(DueDatePattern)];
    // Set due date to the high date (9999-12-31) to ensure that tasks with no due date
    // are sorted after tasks with a due date.
    NSDate *newDueDate = (_dueDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        [TTMDateUtility convertStringToDate:_dueDateText];
    if (newDueDate == nil) {
        _dueDate = [TTMDateUtility convertStringToDate:@"9999-12-31"];
        _dueDateText = @"";
    } else {
        _dueDate = newDueDate;
    }

    // creation date
    _creationDateText = _isCompleted ?
        [_rawText firstMatch:RX(CreationDatePatternCompleted)] :
        [_rawText firstMatch:RX(CreationDatePatternIncomplete)];
    // Set creation date to the high date (9999-12-31) to ensure that tasks with no
    // creation date are sorted after tasks with a creation date.
    NSDate *newCreationDate = (_creationDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"9999-12-31"] :
        [TTMDateUtility convertStringToDate:_creationDateText];
    if (newCreationDate == nil) {
        _creationDate = [TTMDateUtility convertStringToDate:@"9999-12-31"];
        _creationDateText = @"";
    } else {
        _creationDate = newCreationDate;
    }

    // threshold date
    _thresholdDateText = [_rawText firstMatch:RX(ThresholdDatePattern)];
    // Set threshold date to the low date (1900-01-01) to ensure that tasks with no
    // threshold date are properly sorted/displated when filtered.
    NSDate *newThresholdDate = (_thresholdDateText == nil) ?
        [TTMDateUtility convertStringToDate:@"1900-01-01"] :
        [TTMDateUtility convertStringToDate:_thresholdDateText];
    if (newThresholdDate == nil) {
        _thresholdDate = [TTMDateUtility convertStringToDate:@"1900-01-01"];
        _thresholdDateText = @"";
    } else {
        _thresholdDate = newThresholdDate;
    }
    
    // due state (past due, due today, not due)
    _dueState = [self getDueState];
    
    // threshold state (before, on, after threshold date)
    _thresholdState = [self getThresholdState];
}

- (NSString*)rawText {
    return _rawText;
}

- (NSAttributedString*)displayText:(BOOL)selected
                              font:(NSFont*)font
      useHighlightColorsInTaskList:(BOOL)useHighlightColorsInTaskList
                    completedColor:(NSColor*)completedColor
                     dueTodayColor:(NSColor*)dueTodayColor
                      overdueColor:(NSColor*)overdueColor
                      projectColor:(NSColor*)projectColor
                      contextColor:(NSColor*)contextColor
                          tagColor:(NSColor*)tagColor
                      dueDateColor:(NSColor*)dueDateColor
                thresholdDateColor:(NSColor*)thresholdDateColor
                 creationDateColor:(NSColor*)creationDateColor {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:self.rawText];
    NSRange fullStringRange = NSMakeRange(0, [as length]);
    
    [as beginEditing];

    // Apply font to the entire string.
    // This was added because applying boldface to the task priority was resetting the font
    // of the priority substring to the default font.
    [as addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, as.length)];
    
    // Apply strikethrough and light gray color to completed tasks when they are displayed
    // in the tableView.
    if (self.isCompleted) {
        [as addAttribute:NSStrikethroughStyleAttributeName
                   value:(NSNumber*)kCFBooleanTrue
                   range:fullStringRange];
        [as addAttribute:NSForegroundColorAttributeName
                   value:[NSColor lightGrayColor]
                   range:fullStringRange];
        return as;
    }
    
    // Apply boldface to the task priority.
    if (self.isPrioritized) {
        [as applyFontTraits:NSBoldFontMask range:NSMakeRange(0, 3)];
    }
    
    // Only change colors if row is not selected and user wants to see highlight colors.
    if (selected || !useHighlightColorsInTaskList) {
        return as;
    }
    
    // Color due texts.
    if (self.dueState == DueToday) {
        [as applyColorToFullStringRange:dueTodayColor];
    }
    
    // Color overdue texts.
    if (self.dueState == Overdue) {
        [as applyColorToFullStringRange:overdueColor];
    }
    
    // Color projects.
    [as applyColor:projectColor toRegexPatternMatches:ProjectPattern];
    
    // Color contexts.
    [as applyColor:contextColor toRegexPatternMatches:ContextPattern];
    
    // Color tags.
    [as applyColor:tagColor toRegexPatternMatches:TagPattern];
    
    // Color due dates.
    [as applyColor:dueDateColor toRegexPatternMatches:FullDueDatePatternBeginning];
    [as applyColor:dueDateColor toRegexPatternMatches:FullDueDatePatternMiddleOrEnd];
    
    // Color threshold dates.
    [as applyColor:thresholdDateColor toRegexPatternMatches:FullThresholdDatePatternBeginning];
    [as applyColor:thresholdDateColor toRegexPatternMatches:FullThresholdDatePatternMiddleOrEnd];

    // Color creation dates (incomplete tasks only).
    [as applyColor:creationDateColor toRegexPatternMatches:CreationDatePatternIncomplete];
    
    [as endEditing];
    return [as copy];
}

#pragma mark - Append and Prepend Methods

- (void)appendText:(NSString*)textToAppend {
    if (self.isBlank) {
        self.rawText = textToAppend;
        return;
    }
    
    self.rawText = [self.rawText stringByAppendingFormat:@"%c%@", ' ', textToAppend];
}

- (void)prependText:(NSString*)textToPrepend {
    if (self.isBlank) {
        self.rawText = textToPrepend;
        return;
    }

    NSUInteger insertionIndex;
    
    if (self.isCompleted && [self.creationDateText length] > 0) {
        // For completed tasks with creation date, prepend text after the completion date and creation date
        insertionIndex = 24;
    } else if (self.isCompleted && [self.creationDateText length] == 0) {
        // For completed tasks with no creation date, prepend text after the completion date
        insertionIndex = 13;
    } else if (self.isPrioritized && [self.creationDateText length] > 0) {
        // For incomplete tasks with a creation date, prepend text after priority and creation date.
        insertionIndex = 15;
    } else if (self.isPrioritized && [self.creationDateText length] == 0) {
        // For incomplete tasks with a priority and no creation date, prepend text after priority.
        insertionIndex = 4;
    } else if ([self.creationDateText length] > 0) {
        // For incomplete tasks with a creation date, prepend text after creation date.
        insertionIndex = 11;
    } else {
        // For all other types of tasks, prepend text to the beginning of the task.
        insertionIndex = 0;
    }
    
    if (insertionIndex == 0)
    {
        self.rawText = [NSString stringWithFormat:@"%@%@%@", textToPrepend, @" ", self.rawText];
        return;
    }

    NSString *rawTextPrefix = [self.rawText substringWithRange:NSMakeRange(0, insertionIndex - 1)];
    NSString *rawTextRemainder = [self.rawText substringFromIndex:insertionIndex];
    NSArray *rawTextComponents = @[rawTextPrefix, textToPrepend, rawTextRemainder];
    self.RawText = [rawTextComponents componentsJoinedByString:@" "];

//    NSString *separator = @" ";
//    NSString *rawTextRemainder = self.rawText;
//    NSArray *stringComponents = nil;
//    NSString *trimmedPriorityText = [self.fullPriorityText substringToIndex:3];
//
//    if (self.isPrioritized && self.creationDateText != nil) {
//        rawTextRemainder = [self.rawText substringFromIndex:15];
//        stringComponents = @[trimmedPriorityText, self.creationDateText,
//                             textToPrepend, rawTextRemainder  ];
//    } else if (self.isPrioritized && self.creationDateText == nil) {
//        rawTextRemainder = [self.rawText substringFromIndex:4];
//        stringComponents = @[trimmedPriorityText, textToPrepend, rawTextRemainder];
//    } else if (self.creationDateText != nil) {
//        rawTextRemainder = [self.rawText substringFromIndex:11];
//        stringComponents = @[self.creationDateText, textToPrepend, rawTextRemainder];
//    } else {
//        rawTextRemainder = self.rawText;
//        stringComponents = @[textToPrepend, rawTextRemainder];
//    }
//    self.rawText = [stringComponents componentsJoinedByString:separator];
}

#pragma Find/replace Method

- (void)replaceText:(NSString*)textToReplace withText:(NSString*)replacementText {
    self.rawText = [self.rawText stringByReplacingOccurrencesOfString:textToReplace
                                                           withString:replacementText];
}

#pragma mark - Due/Not Due Method

- (TTMDueState)getDueState {
    // completed tasks and those with no due dates are automatically not due
    if (nil == self.dueDate || self.isCompleted || [self.dueDateText isEqual:[NSNull null]])
        return NotDue;
    
    // If there is a due date, compare it to today's date to determine
    // if the task is overdue, not due, or due today.
    NSDate *todaysDate = [TTMDateUtility today];
    NSInteger interval = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
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

#pragma mark - Threshold Date Methods

- (void)setThresholdDate:(NSDate *)thresholdDate {
    NSString *newThresholdDateText = [TTMDateUtility convertDateToString:thresholdDate];
    // If the item has a threshold date, exchange the current threshold date with the new.
    // Else if the item does not have a threshold date, append the new threshold date to the task.
    self.rawText = (self.thresholdDateText != nil) ?
        [self.rawText replace:RX(ThresholdDatePattern) with:newThresholdDateText] :
        [self.rawText stringByAppendingFormat:@" t:%@", newThresholdDateText];
}

- (void)removeThresholdDate {
    // Blank and tasks without a threshold date do not get updated.
    if (self.isBlank || !self.thresholdDate) {
        return;
    }
    
    NSString *newRawText = [self.rawText replace:RX(FullThresholdDatePatternBeginning) with:@""];
    self.rawText = [newRawText replace:RX(FullThresholdDatePatternMiddleOrEnd) with:@""];
}

- (void)incrementThresholdDate:(NSInteger)days {
    // Blank tasks don't get updated threshold dates.
    if (self.isBlank) {
        return;
    }
    
    if (days == 0) {
        return;
    }
    
    // Get threshold date of the selected task.
    // If the selected task doesn't have a threshold date, use today as the due date.
    NSDate *oldThresholdDate = (self.thresholdDateText != nil) ?
        self.thresholdDate :
        [TTMDateUtility today];
    
    // Add days to that date to create the new due date.
    NSDate *newThresholdDate = [TTMDateUtility addDays:days toDate:oldThresholdDate];
    
    self.thresholdDate = newThresholdDate;
}

- (void)decrementThresholdDate:(NSInteger)days {
    [self incrementThresholdDate:(-1 * days)];
}

- (TTMThresholdState)getThresholdState {
    // If there is a threshold date, compare it to today's date to determine
    // if the task is overdue, not due, or due today.
    NSDate *todaysDate = [TTMDateUtility today];
    NSInteger interval = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                          fromDate:todaysDate
                                                            toDate:self.thresholdDate
                                                           options:0] day];
    if (interval < 0) {
        return AfterThresholdDate;
    } else if (interval > 0) {
        return BeforeThresholdDate;
    } else {
        return OnThresholdDate;
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
            self.rawText = [self.rawText stringByReplacingCharactersInRange:oldPriority
                            withString:[NSString stringWithFormat:
                                        @"%c%c%c%c", '(', priority, ')', ' ']];
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
    self.rawText = newRawText;
}

- (void)markIncomplete {
    // Incomplete tasks don't need to be marked incomplete again.
    // Blank tasks can't be marked incompleted.
    if (self.isBlank || !self.isCompleted) {
        return;
    }
    
    // Remove the completed task prepended substring and update all class properties.
    self.rawText = [RX(CompletedPattern) replace:self.rawText with:@""];
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
    
    self.dueDate = newDueDate;
}

- (void)incrementDueDate:(NSInteger)days {
    [self postponeTask:days];
}

- (void)decrementDueDate:(NSInteger)days {
    [self postponeTask:(-1 * days)];

}

- (void)setDueDate:(NSDate *)dueDate {
    // Blank tasks don't get due dates.
    if (self.isBlank) {
        return;
    }
    
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
    
    NSString *newRawText = [self.rawText replace:RX(FullDueDatePatternBeginning) with:@""];
    self.rawText = [newRawText replace:RX(FullDueDatePatternMiddleOrEnd) with:@""];
}

#pragma mark - NSCopying Methods

- (TTMTask*)copyWithZone:(NSZone *)zone {
    TTMTask *copy = [[self class] allocWithZone:zone];
    
    if (copy) {
        return [copy initWithRawText:self.rawText withTaskId:self.taskId];
    }
    
    return copy;
}

#pragma mark - IsEqual Methods

-(BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToTTMTask:object];
}

- (BOOL)isEqualToTTMTask:(TTMTask*)otherTask {
    if (!otherTask) {
        return NO;
    }
    
    BOOL haveEqualRawText = [self.rawText isEqualToString:otherTask.rawText];
    BOOL haveEqualTaskId = (self.taskId == otherTask.taskId);
    return haveEqualRawText && haveEqualTaskId;
}

- (NSUInteger)hash {
    return [self.rawText hash] ^ [@(self.taskId) hash];
}

@end
