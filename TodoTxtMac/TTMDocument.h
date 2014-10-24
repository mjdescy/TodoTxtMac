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

#import <Cocoa/Cocoa.h>
@class TTMAppController;
@class TTMFieldEditor;
@class TTMTask;
@class TTMTasklistMetadata;

#define SORTMENUTAG   4000
#define FILTERMENUTAG 5000

typedef enum : NSUInteger {
    TTMSortOrderInFile,
    TTMSortPriority,
    TTMSortProject,
    TTMSortContext,
    TTMSortDueDate,
    TTMSortCreationDate,
    TTMSortCompletionDate,
    TTMSortAlphabetical
} TTMTaskListSortType;

typedef void (^TaskChangeBlock)(id, NSUInteger, BOOL*);

@interface TTMDocument : NSDocument

#pragma mark - Properties

// Data elements related to the task list
@property (nonatomic, copy) NSMutableArray *taskList;
@property (nonatomic) BOOL usesWindowsLineEndings;
@property (nonatomic, copy) NSString *preferredLineEnding;
@property (nonatomic, copy) NSArray *projectsArray;
@property (nonatomic, copy) NSArray *contextsArray;

// Window controls
@property (nonatomic, retain) IBOutlet NSTextField *textField;
@property (nonatomic, retain) IBOutlet NSSearchField *searchField;
@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet NSArrayController *arrayController;
@property (nonatomic, retain) IBOutlet NSCell *rawTextCell;
@property (nonatomic, retain) TTMFieldEditor *customFieldEditor;

// User font preference
@property (nonatomic) BOOL usingUserFont;
@property (nonatomic, retain) NSFont *userFont;

// Active filter predicate
@property (nonatomic, retain) NSPredicate *activeFilterPredicate;
@property (nonatomic) NSUInteger activeFilterPredicateNumber;

// Active sort type
@property (nonatomic) NSUInteger activeSortType;

// Tasklist metadata
@property (nonatomic) TTMTasklistMetadata *tasklistMetadata;
@property (nonatomic) TTMTasklistMetadata *filteredTasklistMetadata;
@property (nonatomic) IBOutlet NSWindow *tasklistMetadataSheet;

#pragma mark - File Loading and Saving Methods

/*!
 * @method reloadFile:
 * @abstract Reloads the task list file.
 */
- (IBAction)reloadFile:(id)sender;

#pragma mark - Add/Remove Task(s) methods

/*!
 * @method createWorkingTaskWithRawText:createWorkingTaskWithRawText
 * @abstract Creates a task object to be inserted into the task list.
 * @param rawText The text to base the task on
 * @param newTaskId The (zero-based) numerical position of the task within the todo.txt file.
 */
- (TTMTask*)createWorkingTaskWithRawText:(NSString*)rawText withTaskId:(NSUInteger)newTaskId;

/*!
 * @method moveFocusToNewTaskTextField:
 * @abstract Moves focus to the new task text field so the user can type in a new task.
 */
- (IBAction)moveFocusToNewTaskTextField:(id)sender;

/*!
 * @method removeAllTasks:
 * @abstract Removes all tasks from the task list.
 * @discussion This method is called before a todo.txt file is loaded.
 */
- (void)removeAllTasks;

/*!
 * @method addTasksFromArray:removeAllTasksFirst:
 * @abstract Add tasks from an array to the task list.
 * @param rawTextStrings The array of tasks' raw text strings.
 * @param removeAllRecordsFirst Set to YES if all records should be removed prior to adding tasks.
 */
- (void)addTasksFromArray:(NSArray*)rawTextStrings removeAllTasksFirst:(BOOL)removeAllRecordsFirst;

/*!
 * @method addNewTask:
 * @abstract Adds a new task to the task list based on the content of the text field.
 */
- (IBAction)addNewTask:(id)sender;

/*!
 * @method tabFromTextFieldToTaskList:
 * @abstract Simulate a tab keypress to move from the text field to the task list.
 * @discussion This method is optionally called in the addNewTask: method.
 */
- (void)tabFromTextFieldToTaskList;

/*!
 * @method addNewTasksFromClipboard:
 * @abstract Adds tasks on the clipboard (one or more tasks separated by line breaks)
 * to the task list.
 */
- (void)addNewTasksFromClipboard:(id)sender;

/*!
 * @method addNewTasksFromDragAndDrop:
 * @abstract Add tasks from drag and drop (of text) onto the task list.
 */
- (IBAction)addNewTasksFromDragAndDrop:(id)sender;

/*!
 * @method addNewTasksFromPasteBoard:
 * @abstract Adds tasks from a pasteboard to the task list.
 * @param pasteboard The pasteboard, either the general pasteboard or the dragging pasteboard.
 * @discussion This is a convenience method called from both addNewTasksFromClipboard: and
 * addNewTasksFromDragAndDrop:.
 */
- (void)addNewTasksFromPasteBoard:(NSPasteboard*)pasteboard;

#pragma mark - Update Task Methods

/*!
 * @method refreshTaskListWithSave:
 * @abstract Refresh the task list array controller and table view, and refresh
 * the lists of projects and contexts used for autocompletion. Optionally save the
 * file prior to calling the refresh.
 * @param saveToFile Set to YES to save the file before the refresh.
 */
- (void)refreshTaskListWithSave:(BOOL)saveToFile;

/*!
 * @method updateSelectedTask:
 * @abstract Set the selected task in the task list to edit mode.
 */
- (IBAction)updateSelectedTask:(id)sender;

/*!
 * @method forEachSelectedTaskExecuteBlock:
 * @abstract Executes a block for each selected task in the task list.
 * @param block A TaskChangeBlock that performs an action on a TTMTask object.
 * @discussion This method is called by various other methods in this class.
 */
- (void)forEachSelectedTaskExecuteBlock:(TaskChangeBlock)block;

/*!
 * @method toggleTaskCompletion:
 * @abstract Marks incomplete tasks completed. Marks complete tasks incomplete.
 */
- (IBAction)toggleTaskCompletion:(id)sender;

/*!
 * @method deleteSelectedTasks:
 * @abstract Delete selected tasks in the task list.
 */
- (IBAction)deleteSelectedTasks:(id)sender;

/*!
 * @method appendText:
 * @abstract Append text, entered in a modal sheet, to selected tasks.
 */
- (IBAction)appendText:(id)sender;

#pragma mark - Priority Methods

/*!
 * @method setPriority:
 * @abstract Sets the priority for selected tasks via a modal sheet.
 */
- (IBAction)setPriority:(id)sender;

/*!
 * @method increasePriority:
 * @abstract Increases the priority of selected tasks by 1, e.g. from B to A.
 */
- (IBAction)increasePriority:(id)sender;

/*!
 * @method decreasePriority:
 * @abstract Decreases the priority of selected tasks by 1, e.g. from A to B.
 */
- (IBAction)decreasePriority:(id)sender;

/*!
 * @method removePriority:
 * @abstract Removes the priority from selected tasks.
 */
- (IBAction)removePriority:(id)sender;

#pragma mark - Postpone and Due Date Methods

/*!
 * @method setDueDate:
 * @abstract Sets the due date for selected tasks via a modal sheet.
 */
- (IBAction)setDueDate:(id)sender;

/*!
 * @method increaseDueDateByOneDay:
 * @abstract Increases the due date of selected tasks by one day, e.g. from 2014-12-01 to 2014-12-02.
 */
- (IBAction)increaseDueDateByOneDay:(id)sender;

/*!
 * @method decreaseDueDateByOneDay:
 * @abstract Decreases the due date of selected tasks by one day, e.g. from 2014-12-02 to 2014-12-01.
 */
- (IBAction)decreaseDueDateByOneDay:(id)sender;

/*!
 * @method removeDueDate:
 * @abstract Removes due date from selected tasks.
 */
- (IBAction)removeDueDate:(id)sender;

/*!
 * @method postpone:
 * @abstract Postpones (increases) the due date of selected tasks by a user-entered number of days,
 * which is entered via a modal sheet.
 * @discussion This method can be used to decrease the due date of selected tasks, too, if the user
 * enters a negative number.
 */
- (IBAction)postpone:(id)sender;

#pragma mark - Sort Methods

/*!
 * @method sortTaskList:
 * @abstract Sorts the task list.
 * @param sortType An enum value that specifies the sort type.
 * @discussion This method also sets the default sort type to whatever sort type is passed to it.
 */
- (void)sortTaskList:(TTMTaskListSortType)sortType;

/*!
 * @method sortByOrderInFile:
 * @abstract Sorts the task list by the order of tasks in the todo.txt file.
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByOrderInFile:(id)sender;

/*!
 * @method sortByPriority:
 * @abstract Sorts the task list by priority.
 * @discussion Priority sort is a multi-level sort of the following task attributes, in order:
 * (1) Priority; (2) Is Completed; (3) Due State (overdue, due tuday, not due); (4) Due Date;
 * and (5) order in file (Task ID).
 * @discussion This method calls by the sortTaskList: method.
 */
- (IBAction)sortByPriority:(id)sender;

/*!
 * @method sortByProject:
 * @abstract Sorts the task list by project.
 * @discussion Project sort is a multi-level sort of the following task attributes, in order:
 * (1) Project; (2) Priority; (3) Is Completed; (4) Due State (overdue, due tuday, not due); 
 * (5) Due Date; and (6) order in file (Task ID).
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByProject:(id)sender;

/*!
 * @method sortByContext:
 * @abstract Sorts the task list by context.
 * @discussion Project sort is a multi-level sort of the following task attributes, in order:
 * (1) Context; (2) Priority; (3) Is Completed; (4) Due State (overdue, due tuday, not due);
 * (5) Due Date; and (6) order in file (Task ID).
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByContext:(id)sender;

/*!
 * @method sortByDueDate:
 * @abstract Sorts the task list by due date.
 * @discussion Due date sort is a multi-level sort of the following task attributes, in order:
 * (1) Due Date; (2) Priority; (3) order in file (Task ID).
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByDueDate:(id)sender;

/*!
 * @method sortByCreationDate:
 * @abstract Sorts the task list by creation date.
 * @discussion Due date sort is a multi-level sort of the following task attributes, in order:
 * (1) Creation Date; (2) Priority; (3) order in file (Task ID).
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByCreationDate:(id)sender;

/*!
 * @method sortByCompletionDate:
 * @abstract Sorts the task list by completion date.
 * @discussion Due date sort is a multi-level sort of the following task attributes, in order:
 * (1) Creation Date; (2) order in file (Task ID).
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByCompletionDate:(id)sender;

/*!
 * @method sortByAlphabetical:
 * @abstract Sorts the task list in alphabetical order of the tasks.
 * @discussion Due date sort is a signle-level sort of the task's raw text attribute.
 * @discussion This method calls the sortTaskList: method.
 */
- (IBAction)sortByAlphabetical:(id)sender;

#pragma mark - Filter Methods

/*!
 * @method removeTaskListFilter:
 * @abstract Removes the filter on the task list.
 */
- (IBAction)removeTaskListFilter:(id)sender;

/*!
 * @method applyTaskListFilter1:
 * @abstract Applies user-defined filter 1 to the task list.
 */
- (IBAction)applyTaskListFilter1:(id)sender;

/*!
 * @method applyTaskListFilter2:
 * @abstract Applies user-defined filter 2 to the task list.
 */
- (IBAction)applyTaskListFilter2:(id)sender;

/*!
 * @method applyTaskListFilter3:
 * @abstract Applies user-defined filter 3 to the task list.
 */
- (IBAction)applyTaskListFilter3:(id)sender;

/*!
 * @method applyTaskListFilter4:
 * @abstract Applies user-defined filter 4 to the task list.
 */

- (IBAction)applyTaskListFilter4:(id)sender;

/*!
 * @method applyTaskListFilter5:
 * @abstract Applies user-defined filter 5 to the task list.
 */
- (IBAction)applyTaskListFilter5:(id)sender;

/*!
 * @method applyTaskListFilter1:
 * @abstract Applies user-defined filter 6 to the task list.
 */
- (IBAction)applyTaskListFilter6:(id)sender;

/*!
 * @method applyTaskListFilter7:
 * @abstract Applies user-defined filter 7 to the task list.
 */
- (IBAction)applyTaskListFilter7:(id)sender;

/*!
 * @method applyTaskListFilter8:
 * @abstract Applies user-defined filter 8 to the task list.
 */
- (IBAction)applyTaskListFilter8:(id)sender;

/*!
 * @method applyTaskListFilter9:
 * @abstract Applies user-defined filter 9 to the task list.
 */
- (IBAction)applyTaskListFilter9:(id)sender;

/*!
 * @method reapplyActiveFilterPredicate:
 * @abstract Applies the active filter to the task list.
 */
- (void)reapplyActiveFilterPredicate;

/*!
 * @method changeActiveFilterPredicateToPreset:
 * @abstract Changes the active filter preset to the one the user selected.
 * @param presetNumber The preset number the user selected.
 */
- (void)changeActiveFilterPredicateToPreset:(NSUInteger)presetNumber;

#pragma mark - Archive Methods

/*!
 * @method archiveCompletedTasks:
 * @abstract Archives all completed tasks to the user-specified archive file.
 * @discussion The user must specify an archive file in the application's preferences.
 * There is only one archive file; any open task file will archive to the same file.
 */
- (IBAction)archiveCompletedTasks:(id)sender;

/*!
 * @method appendString:toArchiveFile:
 * @abstract Appends a string, which can contain one or more tasks, to another file.
 * @param content One or more tasks. Multiple tasks must be separated by line breaks.
 * @param archiveFilePath Archive file path. This path must be specified by the file path
 * saved in the application's preferences and obtained using the standard file open dialog.
 * @discussion This is a convenience method called by the archiveCompletedTasks: method.
 */
- (void)appendString:(NSString*)content toArchiveFile:(NSString*)archiveFilePath;

#pragma mark - Autocompletion Methods

/*!
 * @method updateProjectsAndContextsArrays:
 * @abstract Updates the arrays of projects and contexts used for autocompletion.
 * @discussion The projects and contexts arrays updated by this method are passed to the
 * custom field editor to allow for autocompletion of projects and contexts.
 */
- (void)updateProjectsAndContextsArrays;

#pragma mark - Find Methods

/*!
 * @method moveFocusToSearchBox:
 * @abstract Moves focus to the search box to find text.
 */
- (IBAction)moveFocusToSearchBox:(id)sender;

/*!
 * @method makeSearchBoxRefuseFocus:
 * @abstract Resets search box to refuse first responder (so user cannot tab to it).
 */
- (IBAction)makeSearchBoxRefuseFocus:(id)sender;

#pragma mark - Tasklist Metadata Methods

/*!
 * @method showTasklistMetadata:
 * @abstract Display tasklist metadata in a modal sheet.
 */
- (IBAction)showTasklistMetadata:(id)sender;

/*!
 * @method hideTasklistMetadata:
 * @abstract Hide tasklist metadata modal sheet.
 */
- (IBAction)hideTasklistMetadata:(id)sender;

@end
