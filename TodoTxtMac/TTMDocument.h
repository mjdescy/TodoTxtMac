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

#import <Cocoa/Cocoa.h>
@class TTMAppController;
@class TTMFieldEditor;
@class TTMTask;
@class TTMTasklistMetadata;
@class TTMTableView;
@class TTMTableViewDelegate;

#define SORTMENUTAG   4000
#define FILTERMENUTAG 5000
#define STATUSBARMENUITEMTAG 6000

typedef enum : NSUInteger {
    TTMSortOrderInFile,
    TTMSortPriority,
    TTMSortProject,
    TTMSortContext,
    TTMSortDueDate,
    TTMSortCreationDate,
    TTMSortCompletionDate,
    TTMSortThresholdDate,
    TTMSortAlphabetical
} TTMTaskListSortType;

@interface TTMDocument : NSDocument

#pragma mark - Properties

// Data elements related to the task list
@property (nonatomic, copy) NSMutableArray *taskList;
@property (nonatomic) BOOL usesWindowsLineEndings;
@property (nonatomic, copy) NSString *preferredLineEnding;

// Window controls
@property (nonatomic, retain) IBOutlet NSTextField *textField;
@property (nonatomic, retain) IBOutlet NSSearchField *searchField;
@property (nonatomic, retain) IBOutlet NSPredicate *searchFieldPredicate;
@property (nonatomic, retain) IBOutlet TTMTableView *tableView;
@property (nonatomic, retain) IBOutlet TTMTableViewDelegate *tableViewDelegate;
@property (nonatomic, retain) IBOutlet NSArrayController *arrayController;
@property (nonatomic, retain) IBOutlet NSCell *rawTextCell;
@property (nonatomic, retain) TTMFieldEditor *customFieldEditor;
@property (nonatomic, retain) IBOutlet NSTextField *statusBarTextField;
@property (nonatomic, retain) NSString *statusBarText;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, retain) IBOutlet NSView *findReplaceView;
@property (nonatomic, retain) IBOutlet NSTextField *findText;
@property (nonatomic, retain) IBOutlet NSTextField *replaceText;

// User font preference
@property (nonatomic) BOOL usingUserFont;
@property (nonatomic, retain) NSFont *userFont;

// Active filter predicate
@property (nonatomic, retain) NSPredicate *activeFilterPredicate;
@property (nonatomic) NSUInteger activeFilterPredicateNumber;

// Active sort type
@property (nonatomic) NSUInteger activeSortType;

// Tasklist metadata
@property (nonatomic, retain) TTMTasklistMetadata *tasklistMetadata;
@property (nonatomic, retain) TTMTasklistMetadata *filteredTasklistMetadata;
@property (nonatomic, retain) IBOutlet NSWindow *tasklistMetadataSheet;

// Task objects for undo/redo of task edits
@property (nonatomic, copy) NSArray *originalTasks;

#pragma mark - File Loading and Saving Methods

/*!
 * @method reloadFile:
 * @abstract Reloads the task list file.
 */
- (IBAction)reloadFile:(id)sender;

/*!
 * @method getTaskListSelections
 * @abstract This method gets/saves selected items in the task list before the reload:
 * method reloads the task list file, to allow for selections to be retained (as much as possible)
 * after the user reloads the file.
 */
- (NSMutableArray*)getTaskListSelections;

/*!
 * @method setTaskListSelections:
 * @param taskListSelections Array of task items to select
 * @abstract This method re-sets selected items in the task list after the reload:
 * method reloads the task list file, to allow for selections to be retained (as much as possible)
 * after the user reloads the file. This method makes a best effort to select the same tasks as
 * were selected before (which are to be returned by the getTaskListSelections: method prior to
 * reloading the file. Tasks that change (i.e., are completed or otherwise modified) or removed 
 * from the list will not be selected after reload. For duplicate tasks (those with identical
 * raw text), the first of the duplicate tasks will be selected.
 */
- (void)setTaskListSelections:(NSArray*)taskListSelectedItems;

#pragma mark - Undo/Redo Methods

/*!
 * @method replaceTasks:withTasks:
 * @abstract This method replaces one array of tasks with another in the task list. 
 * It is used for undo/redo operations.
 */
- (void)replaceTasks:(NSArray*)oldTasks withTasks:(NSArray*)newTasks;

/*!
 * @method addTasks:
 * @abstract This method adds an array of tasks to the task list.
 * It is used for undo/redo operations.
 */
- (void)addTasks:(NSArray*)newTasks;

/*!
 * @method addTasks:
 * @abstract This method removes an array of tasks from the task list.
 * It is used for undo/redo operations.
 */
- (void)removeTasks:(NSArray*)oldTasks;

/*!
 * @method addTasks:
 * @abstract This method performs and undo for the archive command.
 * It is used for undo/redo operations.
 */
- (void)undoArchiveTasks:(NSArray*)archivedTasks fromArchiveFile:(NSString*)archiveFilePath;

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
 * @method addTasksFromArray:removeAllTasksFirst:undoActionName
 * @abstract Add tasks from an array to the task list.
 * @param rawTextStrings The array of tasks' raw text strings.
 * @param removeAllRecordsFirst Set to YES if all records should be removed prior to adding tasks.
 * @param undoActionName Set to undo action name; blank if operation is not undoable
 */
- (void)addTasksFromArray:(NSArray*)rawTextStrings
      removeAllTasksFirst:(BOOL)removeAllRecordsFirst
           undoActionName:(NSString*)undoActionName;

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
 * @method visualRefreshOnly:
 * @abstract Refreshes the tableView control to apply color changes, etc., only.
 */
- (IBAction)visualRefreshOnly:(id)sender;

/*!
 * @method setTaskListFont:
 * @abstract Sets/changes font for task list.
 */
- (void)setTaskListFont;

/*!
 * @method updateSelectedTask:
 * @abstract Set the selected task in the task list to edit mode.
 */
- (IBAction)updateSelectedTask:(id)sender;

/*!
 * @method initializeUpdateSelectedTask:
 * @abstract Captures undo data for the update task list command, prior to the update being made.
 */
- (void)initializeUpdateSelectedTask;

/*!
 * @method finalizeUpdateSelectedTask:rawText
 * @abstract Finalizes preparation of undo data for the update task list command, 
 * after the update is made.
 */
- (void)finalizeUpdateSelectedTask:(NSString*)rawText;

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

/*!
 * @method prependText:
 * @abstract Prepend text, entered in a modal sheet, to selected tasks.
 */
- (IBAction)prependText:(id)sender;

/*!
 * @method replaceText:
 * @abstract Find and replace text, entered in a modal sheet, to selected tasks.
 */
- (IBAction)replaceText:(id)sender;

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

#pragma mark - Threshold Date Methods

/*!
 * @method setThresholdDate:
 * @abstract Sets the threshold date for selected tasks via a modal sheet.
 */
- (IBAction)setThresholdDate:(id)sender;

/*!
 * @method increaseThresholdDateByOneDay:
 * @abstract Increases the threshold date of selected tasks by one day, e.g. from 2014-12-01 to 2014-12-02.
 */
- (IBAction)increaseThresholdDateByOneDay:(id)sender;

/*!
 * @method decreaseDueDateByOneDay:
 * @abstract Decreases the threshold date of selected tasks by one day, e.g. from 2014-12-02 to 2014-12-01.
 */
- (IBAction)decreaseThresholdDateByOneDay:(id)sender;

/*!
 * @method removeThresholdDate:
 * @abstract Removes threshold date for selected tasks.
 */
- (IBAction)removeThresholdDate:(id)sender;

#pragma mark - Sort Methods

/*!
 * @method sortTaskList:
 * @abstract Sorts the task list.
 * @param sortType An enum value that specifies the sort type.
 * @discussion This method also sets the default sort type to whatever sort type is passed to it.
 */
- (void)sortTaskList:(TTMTaskListSortType)sortType;

/*!
 * @method sortTaskListUsingTagforPreset:
 * @abstract Sorts the task list, using the preset number found in the sender's tag.
 */
- (IBAction)sortTaskListUsingTagforPreset:(id)sender;

#pragma mark - Filter Methods

/*!
 * @method combineFilterPresetPredicate:withSearchFilterPredicate
 * @abstract Combines the filter preset predicate applied to the task list with the search field 
 * predicate in an "AND" fashion.
 */
- (NSPredicate*)combineFilterPresetPredicate:(NSPredicate*)filterPresetPredicate
                   withSearchFilterPredicate:(NSPredicate*)searchFilterPredicate;

/*!
 * @method filterTaskListUsingTagforPreset:
 * @abstract Sets the filter on the task list to a numbered preset, based on the sender's tag.
 * Filter preset 0 is defined to mean "no filter".
 */
- (IBAction)filterTaskListUsingTagforPreset:(id)sender;

/*!
 * @method removeTaskListFilter:
 * @abstract Removes the currently active filter.
 */
- (void)removeTaskListFilter;

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

- (void)removeTasks:(NSArray*)tasksToRemove fromArchiveFile:(NSString*)archiveFilePath;

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

#pragma mark - Status Bar Methods

/*!
 * @method updateStatusBarText:
 * @abstract Updates the status bar text, based on the properties of the TTMDocument.
 */
- (void)updateStatusBarText;

/*!
 * @method statusBarVisable:
 * @abstract Returns whether the status bar is visible.
 */
- (BOOL)statusBarVisable;

/*!
 * @method setStatusBarVisable:
 * @abstract Show or hide the status bar.
 * Each time this method is called the choice to show or hide the status bar is saved to user
 * defaults. The next window opened (including after relaunch) will either show or hide the 
 * status bar according to the flag passed to this method.
 * @param flag Set to true to show the status bar; set to false to hide the status bar.
 */
- (void)setStatusBarVisable:(BOOL)flag;

/*!
 * @method toggleStatusBarVisability:
 * @abstract Change whether the status bar is shown or hidden. 
 */
- (IBAction)toggleStatusBarVisability:(id)sender;

@end
