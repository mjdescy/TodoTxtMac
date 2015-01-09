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

#import <Foundation/Foundation.h>

/*!
 * @class TTMTask
 * @abstract TTMTask represents a single todo.txt task.
 * @discussion A single task is a single line in the todo.txt file, which is in a specific format.
 * @seealso Todo.txt format specification: 
 * https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format
 */
@interface TTMTask : NSObject

/*! Defines the three due states of a task: Overdue, Due Today, and Not Due */
typedef enum : NSUInteger {
    Overdue,
    DueToday,
    NotDue
} TTMDueState;

/*! Defines the three threshold date-related states of a task: before, after, 
    and on the threshold date */
typedef enum : NSUInteger {
    BeforeThresholdDate,
    OnThresholdDate,
    AfterThresholdDate
} TTMThresholdState;

#pragma mark - Properties

/*! Raw text of the task (a single line in the todo.txt file) */
@property (nonatomic, readwrite, setter = setRawText:, getter = rawText) NSString *rawText;

/*! The line number in todo.txt file, starting at zero */
@property (nonatomic, readonly) NSUInteger taskId;

@property (nonatomic, readonly) NSString *fullPriorityText;
@property (nonatomic, readonly) NSString *priorityText;
@property (nonatomic, readonly) unichar priority;
@property (nonatomic, readonly) NSString *dueDateText;
@property (nonatomic, readonly) NSDate *dueDate;
@property (nonatomic, readonly) NSString *creationDateText;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSString *completionDateText;
@property (nonatomic, readonly) NSDate *completionDate;
@property (nonatomic, readonly) NSString *thresholdDateText;
@property (nonatomic, readonly) NSDate *thresholdDate;
@property (nonatomic, readonly, copy) NSArray *contextsArray;
@property (nonatomic, readonly, copy) NSString *contexts;
@property (nonatomic, readonly) BOOL hasContexts;
@property (nonatomic, readonly, copy) NSArray *projectsArray;
@property (nonatomic, readonly, copy) NSString *projects;
@property (nonatomic, readonly) BOOL hasProjects;
@property (nonatomic, readonly) TTMDueState dueState;
@property (nonatomic, readonly) TTMThresholdState thresholdState;
@property (nonatomic, readonly) BOOL isCompleted;
@property (nonatomic, readonly) BOOL isPrioritized;
@property (nonatomic, readonly) BOOL isBlank;

#pragma mark - Init Methods

/*!
 * @method initWithRawText:withTaskId:withPrependedDate:
 * @abstract Initializes task object with a task ID number, raw text, and a prepended date 
 * (or no date if nil is submitted).
 * @discussion This function initializes the task and sets up all its properties.
 * @param taskId An integer that represents the task's line number (ID) in the todo.txt file.
 * @param rawText The raw text that represents a task in the Todo.txt format.
 * @param prependedDate The creation date of the task to prepend to the task.
 * @result Returns the newly initiatized object or an error.
 * @seealso Todo.txt format specification:
 * https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format
 */
- (id)initWithRawText:(NSString*)rawText withTaskId:(NSInteger)taskId
   withPrependedDate:(NSDate*)prependedDate;

/*!
 * @method initWithRawText:withTaskId:
 * @abstract Initializes task object with a task ID number and raw text.
 * @discussion This function initializes the task and sets up all its properties.
 * @param taskId An integer that represents the task's line number (ID) in the todo.txt file.
 * @param rawText The raw text that represents a task in the Todo.txt format.
 * @result Returns the newly initiatized object or an error.
 * @seealso Todo.txt format specification:
 * https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format
 */
- (id)initWithRawText:(NSString*)rawText withTaskId:(NSInteger)taskId;

#pragma mark - rawText Methods

/*!
 * @method setRawText:
 * @abstract Changes raw text of the task.
 * @discussion This function initializes the task and sets up all its properties other than 
 * the taskId number.
 * @param rawText The raw text that represents a task in the Todo.txt format.
 * @seealso Todo.txt format specification. 
 * https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format
 */
- (void)setRawText:(NSString*)rawText;

/*!
 * @method setRawText:withPrependedDate:
 * @abstract Changes raw text of the task and prepends a date if a creation date if one 
 * does not already exist in the first parameter.
 * @discussion This function initializes the task and sets up all its properties other than 
 * the taskId number.
 * @param rawText The raw text that represents a task in the Todo.txt format.
 * @param taskId An integer that represents the task's line number (ID) in the todo.txt file.
 * @param prependedDate A date, which represents the task creation date, to prepend to 
 * the task's raw text.
 * @seealso Todo.txt format specification.
 * https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format
 */
- (void)setRawText:(NSString*)rawText withPrependedDate:(NSDate*)prependedDate;

/*!
 * @method displayText:
 * @abstact Returns the task's raw text as a formatted string for display.
 * @return Returns an attributed string to be used for display in the user interface.
 * @discussion For good MVC compartmentalization, this method does not access the application's
 * user defaults. To customize the display text's colors and styles based on user defaults, 
 * write a similar method to displayText: in a controller class and call that instead.
 */
- (NSAttributedString*)displayText;

#pragma mark - Due/Not Due Method

/*!
 * @method getDueState:
 * @abstract Compares the task's DueDate property to today's date and determines
 * the due status of the task (overdue, due today, or not due).
 * @return Returns a TTMDueState enum type value that indicates a task is "Overdue", "Not Due", 
 * or "Due Today".
 * @discussion This method sets the property dueState.
 */
- (TTMDueState)getDueState;

#pragma mark - Threshold State Method

/*!
 * @method getThresholdState:
 * @abstract Compares the task's thresholdDate property to today's date and determines
 * the status of the task (today's date is before, on, or after the threshold date).
 * @return Returns a TTMThresholdState enum type value that indicates whether today is before,
   on, or after a task's threshold date.
 * or "Due Today".
 * @discussion This method sets the property thresholdState.
 */
- (TTMThresholdState)getThresholdState;

#pragma mark - Priority Methods

/*!
 * @method setPriorityTo:
 * @abstract Sets the priority of a task, whether or not it already has
 * a priority assigned.
 * @param priority This is the priority to set the task to. It must be a capital letter [A-Z],
 * as in @"A".
 * @discussion The priority parameter is not passed with parentheses, as in "(A)", 
 * as it is written in the todo.txt file.
 */
- (void)setPriority:(unichar)priority;

/*!
 * @method increasePriority:
 * @abstract Increases the priority of a task by one step.
 * @discussion If the task has no priority, set priority to 'A'.
 */
- (void)increasePriority;

/*!
 * @method decreasePriority:
 * @abstract Decreases the priority of a task by one step.
 * @discussion If the task has no priority, set priority to 'A'.
 */
- (void)decreasePriority;

/*!
 * @method removePriority:
 * @abstract Removes the priority of a task.
 */
- (void)removePriority;

#pragma mark - Completion Methods

/*!
 * @method markComplete:
 * @abstract Marks an incomplete task as complete by prepending "x YYYY-mm-dd " to the raw text.
 * @discussion This method is usually called via the toggleCompletionStatus: method.
 */
- (void)markComplete;

/*!
 * @method markIncomplete:
 * @abstract Marks a completed task as incomplete by removing the prepended
 * "x YYYY-mm-dd " from the raw text.
 * @discussion This method is usually called via the toggleCompletionStatus method.
 */
- (void)markIncomplete;

/*!
 * @method toggleCompletionStatus:
 * @abstract Toggles completion status of a task.
 * @discussion This method calls the method markIncomplete or the method markIncomplete.
 */
- (void)toggleCompletionStatus;

# pragma mark - Postpone and Set Due Date Methods

/*!
 * @method postponeTask;
 * @abstract Postpones a task by the number of days provided.
 * @discussion This method will set a due date if none already exists. If a negative number
 * is passed to it, the due date will move up rather than back.
 */
- (void)postponeTask:(NSInteger)days;

/*!
 * @method setDueDate:
 * @abstract Sets the due date.
 * @param dueDate The due date to set.
 * @discussion The dueDate parameter is not a string, it is an NSDate value.
 * Handling of "natural language" due dates would have be handled prior to invoking this method.
 */
- (void)setDueDate:(NSDate *)dueDate;

/*!
 * @method removeDueDate;
 * @abstract Removes the due date from the task's raw text.
 */
- (void)removeDueDate;

@end