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

#import "TTMDocument.h"
#import "TTMTask.h"
#import "TTMDateUtility.h"
#import "TTMTableView.h"
#import "TTMTableViewDelegate.h"
#import "TTMFilterPredicates.h"
#import "TTMFieldEditor.h"
#import "RegExCategories.h"
#import "TTMTasklistMetadata.h"
#import "TTMDocumentStatusBarText.h"

@implementation TTMDocument

#pragma mark - Instance Variables

static NSString * const RelativeDueDatePattern = @"(?<=due:)\\S*";

#pragma mark - init Methods

- (id)init
{
    self = [super init];
    if (self) {
        [[self undoManager] disableUndoRegistration];
        _taskList = [[NSMutableArray alloc] init];
        _arrayController = [[NSArrayController alloc] initWithContent:_taskList];
        _preferredLineEnding = @"\n";
        _usesWindowsLineEndings = NO;
        _activeFilterPredicateNumber = [TTMFilterPredicates activeFilterPredicatePresetNumber];
        [self.undoManager setLevelsOfUndo:[[NSUserDefaults standardUserDefaults]
                                           integerForKey:@"levelsOfUndo"]];
        [[self undoManager] enableUndoRegistration];

        _lastInternalModificationDate = nil;
    }

    return self;
}

- (void)awakeFromNib {
    // Set custom field editor.
    
    // Set arrayController sort type.
    self.activeSortType = [[NSUserDefaults standardUserDefaults] integerForKey:@"taskListSortType"];
    [self sortTaskList:self.activeSortType];

    // Load active filter predicate.
    self.activeFilterPredicate = [TTMFilterPredicates activeFilterPredicate];
    
    // Set up drag and drop for tableView.
    [self.tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];

    [self setTaskListFont];

    [self setTableWidthToWidthOfContents];

    // Observe array controller selection to update "selected tasks" count in status bar
    [self.arrayController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
    
    // Observe self to update search field filter
    [self addObserver:self forKeyPath:@"searchFieldPredicate" options:NSKeyValueObservingOptionNew context:nil];
    
    // Observe NSUserDefaults to update undo-related preferences
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"levelsOfUndo"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];

    // Observe NSUserDefaults to update filter-related preferences
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate1"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate2"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate3"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate4"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate5"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate6"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate7"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate8"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"filterPredicate9"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
}

- (NSString *)windowNibName {
    return @"TTMDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    // Add any code here that needs to be executed once the windowController
    // has loaded the document's window.
    [self setStatusBarVisable:[[NSUserDefaults standardUserDefaults] boolForKey:@"showStatusBar"]];
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)client {
    if (!self.customFieldEditor) {
        self.customFieldEditor = [[TTMFieldEditor alloc] init];
    }
    [self.customFieldEditor setFieldEditor:YES];
    self.customFieldEditor.projectsArray = self.tasklistMetadata.projectsArray;
    self.customFieldEditor.contextsArray = self.tasklistMetadata.contextsArray;
    self.customFieldEditor.drawsBackground = YES;
    self.customFieldEditor.backgroundColor = [NSColor whiteColor];
    return self.customFieldEditor;
}

#pragma mark - File Loading and Saving Methods

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Prepare file contents to save.
    NSMutableString *fileData = [[NSMutableString alloc] init];
    for (int i = 0; i < [self.taskList count]; i++) {
        if ([[self.taskList objectAtIndex:i] isKindOfClass:[TTMTask class]]) {
            NSString *line = [[self.taskList objectAtIndex:i] rawText];
            // Append the string to fileData if it is not null.
            // Appending a null causes an exception.
            if (line) {
                [fileData appendString:line];
                [fileData appendString:self.preferredLineEnding];
            }
        }
    }
    return [fileData dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Read file contents.
    NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!fileContents) {
        if (outError != nil) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                            code:NSFileReadUnknownError
                                        userInfo:nil];
        }
        return NO;
    }

    // Check the line endings in the file, and remember if Windows line endings ("\r\n") are used.
    self.usesWindowsLineEndings = ([fileContents rangeOfString:@"\r\n"].location != NSNotFound);
    self.preferredLineEnding = (self.usesWindowsLineEndings) ? @"\r\n" : @"\n";
    
    // Split contents of file into an array of strings.
    // Note: A file with Windows line endings ("\r\n") may also have Unix line endings ("\n").
    // This can happen if a text file is created on Windows, then is edited on the Mac
    // (in TextEdit, for example).
    // Because inconsistent line endings can exist, for files with Windows line endings,
    // we remove the carriage return character prior to splitting the file contents into
    // an array of strings.
    NSArray *rawTextStrings = (self.usesWindowsLineEndings) ?
        [[fileContents stringByReplacingOccurrencesOfString:@"\r" withString:@""] componentsSeparatedByString:@"\n"] :
        [fileContents componentsSeparatedByString:@"\n"];

    // Refresh the arrayController and tableView
    [self addTasksFromArray:rawTextStrings removeAllTasksFirst:YES undoActionName:@""];

    [self updateLastInternalModificationDate];

    return YES;
}

- (void)updateLastInternalModificationDate {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
        NSError *outError;
        [fileCoordinator coordinateReadingItemAtURL:self.fileURL options:0 error:&outError byAccessor:^(NSURL *fileURL) {
            NSError *error;
            NSDate *fileDate;
            [fileURL getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
            self.lastInternalModificationDate = fileDate;
        }];
}

- (IBAction)reloadFile:(id)sender {
    [[self.undoManager prepareWithInvocationTarget:self] replaceAllTasks:[self.taskList copy]];
    [self.undoManager setActionName:NSLocalizedString(@"Reload File", @"Undo Reload File")];
    
    // retain selected items, because selection is lost when the file/arrayController is reloaded
    NSArray *taskListSelectedItemsList = [self getTaskListSelections];
    
    // Reload the file.
    NSError *error;
    [self revertToContentsOfURL:self.fileURL ofType:@"NSString" error:&error];

    // re-set selected items
    [self setTaskListSelections:taskListSelectedItemsList];
    
    [self updateTaskListMetadata];
}

- (NSArray*)getTaskListSelections {
    return [[self.arrayController selectedObjects] copy];
}

- (void)setTaskListSelections:(NSArray*)taskListSelectedItems {
    if (taskListSelectedItems == nil) {
        return;
    }

    NSMutableArray *selectedItems = [NSMutableArray arrayWithArray:taskListSelectedItems];
    NSMutableArray *itemsToSelect = [NSMutableArray array];
    
    for (TTMTask *task in [self.arrayController arrangedObjects]) {
        int i = 0;
        BOOL selected = NO;
        while (i < [selectedItems count] && !selected) {
            TTMTask *selection = [selectedItems objectAtIndex:i];
            if ([task.rawText isEqualToString:selection.rawText]) {
                [itemsToSelect addObject:task];
                [selectedItems removeObjectAtIndex:i];
                selected = YES;
            }
            else {
                i++;
            }
        }
    }
    [self.arrayController setSelectedObjects:itemsToSelect];
}

- (void)presentedItemDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSynchronousFileAccessUsingBlock:^{
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
            NSError *outError;
            [fileCoordinator coordinateReadingItemAtURL:self.fileURL options:0 error:&outError byAccessor:^(NSURL *fileURL) {
                NSError *error;
                NSDate *fileDate;
                [fileURL getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
                if (![self.lastInternalModificationDate isEqualToDate:fileDate]) {
                    [self reloadFile:self];
                }
            }];
        }];
    });
}

+ (BOOL)autosavesInPlace {
    return YES;
}

#pragma mark - Undo/Redo Methods

- (void)replaceAllTasks:(NSArray*)newTasks {
    [[self.undoManager prepareWithInvocationTarget:self] replaceAllTasks:[[self.arrayController arrangedObjects] copy]];
    NSRange range = NSMakeRange(0, [[self.arrayController arrangedObjects] count]);
    
    // retain selected items, because selection is lost when the file/arrayController is reloaded
    NSArray *taskListSelectedItemsList = [self getTaskListSelections];
    
    // Save the current filter number.
    NSUInteger filterNumber = self.activeFilterPredicateNumber;
    
    // Remove the current filter.
    [self removeTaskListFilter];
    
    // remove all tasks
    [self.arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    // add new tasks
    [self.arrayController addObjects:newTasks];
    
    // Refresh the task list.
    [self refreshTaskListWithSave:NO];
    
    // Re-apply the filter active before the file was reloaded.
    [self changeActiveFilterPredicateToPreset:filterNumber];
    
    // re-set selected items
    [self setTaskListSelections:taskListSelectedItemsList];
}


- (void)replaceTasks:(NSArray*)oldTasks withTasks:(NSArray*)newTasks {
    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.arrayController removeObjects:oldTasks];
    [self.arrayController addObjects:newTasks];
    [self refreshTaskListWithSave:YES];
}

- (void)addTasks:(NSArray*)newTasks {
    [[self.undoManager prepareWithInvocationTarget:self] removeTasks:newTasks];
    [self.arrayController addObjects:newTasks];
    [self refreshTaskListWithSave:YES];
}

- (void)removeTasks:(NSArray*)oldTasks {
    [[self.undoManager prepareWithInvocationTarget:self] addTasks:oldTasks];
    [self.arrayController removeObjects:oldTasks];
    [self refreshTaskListWithSave:YES];
}

- (void)undoArchiveTasks:(NSArray*)archivedTasks fromArchiveFile:(NSString*)archiveFilePath {
    [self addTasks:archivedTasks];
    [self removeTasks:archivedTasks fromArchiveFile:archiveFilePath];
}

#pragma mark - Add/Remove Task Methods

- (TTMTask*)createWorkingTaskWithRawText:(NSString*)rawText withTaskId:(NSUInteger)newTaskId {
    // Convert natural-language due dates, such as "due:today" and "due:tomorrow", to YYYY-MM-DD.
    NSString *relativeDueDateText = [rawText firstMatch:RX(RelativeDueDatePattern)];
    NSString *relativeDueDateReplacementText =
        [TTMDateUtility dateStringFromNaturalLanguageString:relativeDueDateText];
    if (relativeDueDateReplacementText != nil) {
        rawText = [rawText replace:RX(RelativeDueDatePattern)
                              with:relativeDueDateReplacementText];
    }
    
    // Optionally prepend the creation date and create the task.
    BOOL prependDate = [[NSUserDefaults standardUserDefaults] boolForKey:@"prependDateOnNewTasks"];
    TTMTask *workingTask = (prependDate) ?
        [[self.arrayController newObject] initWithRawText:rawText
                                               withTaskId:newTaskId
                                        withPrependedDate:[TTMDateUtility today]] :
        [[self.arrayController newObject] initWithRawText:rawText withTaskId:newTaskId];
    return workingTask;
}

- (IBAction)moveFocusToNewTaskTextField:(id)sender {
    [self.textField becomeFirstResponder];
}

- (void)removeAllTasks {
    for (TTMTask *task in self.taskList) {
        [self.arrayController removeObject:task];
    }
}

- (void)addTasksFromArray:(NSArray*)rawTextStrings
      removeAllTasksFirst:(BOOL)removeAllTasksFirst
     undoActionName:(NSString*)undoActionName {
    if (removeAllTasksFirst) {
        [self removeAllTasks];
    }
    
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    NSUInteger newTaskId = (self.arrayController == nil) ?
                            [self.taskList count] :
                            [[self.arrayController arrangedObjects] count];
    for (NSString *rawTextString in rawTextStrings) {
        if (rawTextString.length > 0) {
            TTMTask *newTask;
            if (removeAllTasksFirst) {
                newTask = [[TTMTask alloc]
                           initWithRawText:(NSString*)rawTextString
                           withTaskId:newTaskId++];
                [self.arrayController addObject:newTask];
            } else {
                newTask = [self createWorkingTaskWithRawText:(NSString*)rawTextString
                                                  withTaskId:newTaskId++];
                [self.arrayController addObject:newTask];
            }
            [newTasks addObject:[newTask copy]];
        }
    }
    
    if ([undoActionName length] > 0) {
        [self.undoManager setActionName:undoActionName];
        [[self.undoManager prepareWithInvocationTarget:self] removeTasks:newTasks];
    }
    
    if (removeAllTasksFirst) {
        [self visualRefreshOnly:self];
    } else {
        [self updateTaskListMetadata];
    }    
}

- (IBAction)addNewTask:(id)sender {
    NSString *newTaskText = [self.textField stringValue];
    
    // Reject zero-length input.
    if ([newTaskText length] == 0) {
        return;
    }
    
    NSUInteger newTaskId = [[self.arrayController arrangedObjects] count];
    TTMTask *newTask = [self createWorkingTaskWithRawText:newTaskText
                                               withTaskId:newTaskId];
    
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    [newTasks addObject:[newTask copy]];
    [[self.undoManager prepareWithInvocationTarget:self] removeTasks:newTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Add New Task", @"Undo Add New Task")];
    
    [self.arrayController addObject:newTask];
    [self reapplyActiveFilterPredicate];
    [self refreshTaskListWithSave:YES];
    [self.textField setStringValue:@""];
    
    // Optionally move focus to the task list depending on the user setting.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"moveToTaskListAfterTaskCreation"]) {
        if ([self.arrayController.selectedObjects containsObject:newTask]) {
            [self tabFromTextFieldToTaskList];
            [self.tableView scrollRowToVisible:self.tableView.selectedRow];
        }
    }
}

- (void)tabFromTextFieldToTaskList {
    // Simulate a tab press.
    unichar keyChar = 9;
    NSString *keyDownString = [NSString stringWithCharacters:&keyChar length:1];
    NSPoint point = {0, 0};
    NSEvent *newEvent =[NSEvent keyEventWithType:NSKeyDown
                                        location:point
                                   modifierFlags:0
                                       timestamp:[NSDate timeIntervalSinceReferenceDate]
                                    windowNumber:self.windowForSheet.windowNumber
                                         context:nil
                                      characters:keyDownString
                     charactersIgnoringModifiers:keyDownString
                                       isARepeat:NO
                                         keyCode:keyChar];
    [NSApp postEvent:newEvent atStart:YES];
}

- (void)addNewTasksFromClipboard:(id)sender {
    [self addNewTasksFromPasteBoard:[NSPasteboard generalPasteboard]];
}

- (void)addNewTasksFromDragAndDrop:(id)sender {
    [self.undoManager setActionName:NSLocalizedString(@"Drag and Drop", @"Undo Drag and Drop")];
    [self addNewTasksFromPasteBoard:[sender draggingPasteboard]];
}

- (void)addNewTasksFromPasteBoard:(NSPasteboard*)pasteboard {
    NSString *pasteboardText = [pasteboard stringForType:NSPasteboardTypeString];
    if ([pasteboardText length] == 0) {
        return;
    }
    
    NSArray *rawTextStrings = [pasteboardText
                               componentsSeparatedByCharactersInSet:
                               [NSCharacterSet newlineCharacterSet]];
    
    [self addTasksFromArray:rawTextStrings
        removeAllTasksFirst:NO undoActionName:NSLocalizedString(@"Paste", @"Undo Paste")];
    [self reapplyActiveFilterPredicate];
    [self refreshTaskListWithSave:YES];
}

- (IBAction)copyTaskToNewTask:(id)sender {
    // cancel if multiple rows are selected
    if ([[self.arrayController selectedObjects] count] != 1) {
        return;
    }
    
    TTMTask *task = [[self.arrayController selectedObjects] objectAtIndex:0];
    [self.textField setStringValue:task.rawText];
    [self moveFocusToNewTaskTextField:self];
}

#pragma mark - Update Task Methods

- (void)refreshTaskListWithSave:(BOOL)saveToFile {
    // retain selected items, because selection is lost when the file/arrayController is reloaded
    NSArray *taskListSelectedItemsList = [self getTaskListSelections];

    // Optionally save the file.
    if (saveToFile) {
        [self saveToFile];
    }

    // Re-sort the table.
    [self.arrayController rearrangeObjects];
    // Reload table.
    [self.tableView reloadData];
    [self setTableWidthToWidthOfContents];

    // re-set selected items
    [self setTaskListSelections:taskListSelectedItemsList];
    
    // Update the lists of projects and contexts.
    [self updateTaskListMetadata];
}

- (void)saveToFile {
    [self autosaveWithImplicitCancellability:YES completionHandler:^(NSError * _Nullable errorOrNil) {
        [self updateLastInternalModificationDate];
    }];
}

- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation {
    return YES;
}

- (IBAction)visualRefreshOnly:(id)sender {
    [self setTaskListFont];
    [self reapplyActiveFilterPredicate];
    [self.tableView reloadData];
    [self setTableWidthToWidthOfContents];
    [self updateTaskListMetadata];
}

- (void)setTaskListFont {
    self.usingUserFont = [[NSUserDefaults standardUserDefaults] boolForKey:@"useUserFont"];
    if (self.usingUserFont) {
        self.userFont = [NSFont userFontOfSize:0.0];
    } else {
        self.userFont = [NSFont controlContentFontOfSize:0];
    }
    [self.rawTextCell setFont:self.userFont];
}

- (IBAction)updateSelectedTask:(id)sender {
    // cancel if multiple rows are selected
    if ([[self.arrayController selectedObjects] count] != 1) {
        return;
    }
    
    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (void)initializeUpdateSelectedTask {
    self.originalTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                              copyItems:YES];
}

- (void)finalizeUpdateSelectedTask:(NSString*)rawText {
    NSArray *newTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    
    NSMutableArray *newTaskStrings = [[NSMutableArray alloc] init];
    BOOL taskWasCompleted = NO;
    BOOL recurringTasksWereCreated = NO;
    BOOL prependDate = [[NSUserDefaults standardUserDefaults] boolForKey:@"prependDateOnNewTasks"];
    
    for (TTMTask *task in newTasks) {
        // if task is being marked complete...
        if (task.isCompleted) {
            taskWasCompleted = YES;
        }
        if (task.isCompleted && task.isRecurring) {
            TTMTask *newTaskBase = [task copy];
            [newTaskBase markIncomplete];
            TTMTask *newTask = [newTaskBase newRecurringTask];
            if (newTask != nil) {
                recurringTasksWereCreated = YES;
                if (prependDate) {
                    [newTask removeCreationDate];
                }
                [newTaskStrings addObject:newTask.rawText];
            }
        }
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks
                                                            withTasks:self.originalTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Edit Task", @"Undo Edit Task")];
    self.originalTasks = nil;
    
    if (taskWasCompleted && [[NSUserDefaults standardUserDefaults] integerForKey:@"archiveTasksUponCompletion"]) {
        [self archiveCompletedTasks:self];
    } else {
        [self refreshTaskListWithSave:YES];
    }
    
    if (recurringTasksWereCreated) {
        [self addTasksFromArray:newTaskStrings removeAllTasksFirst:NO undoActionName:NSLocalizedString(@"Add Recurring Task", @"")];
    }
}

- (IBAction)toggleTaskCompletion:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    NSMutableArray *newTaskStrings = [[NSMutableArray alloc] init];
    
    BOOL recurringTasksWereCreated = NO;
    BOOL prependDate = [[NSUserDefaults standardUserDefaults] boolForKey:@"prependDateOnNewTasks"];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        // if task is being marked complete...
        if (!task.isCompleted) {
            if (task.isRecurring) {
                TTMTask *newTask = [task newRecurringTask];
                if (newTask != nil) {
                    if (prependDate) {
                        [newTask removeCreationDate];
                    }
                    [newTaskStrings addObject:newTask.rawText];
                    recurringTasksWereCreated = YES;
                }
            }
        }
        
        [task toggleCompletionStatus];
        [newTasks addObject:[task copy]];
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Toggle Completion", @"Undo Toggle Completion")];

    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"archiveTasksUponCompletion"]) {
        [self archiveCompletedTasks:self];
    } else {
        [self refreshTaskListWithSave:YES];
    }

    if (recurringTasksWereCreated) {
        [self addTasksFromArray:newTaskStrings removeAllTasksFirst:NO undoActionName:NSLocalizedString(@"Add Recurring Tasks", @"")];
        [self reapplyActiveFilterPredicate];
    }
}

- (IBAction)deleteSelectedTasks:(id)sender {
    NSAlert *deletePrompt = [[NSAlert alloc] init];
    deletePrompt.messageText = @"Delete";
    deletePrompt.informativeText = @"Are you sure you want to delete all selected tasks?";
    [deletePrompt addButtonWithTitle:@"OK"];
    [deletePrompt addButtonWithTitle:@"Cancel"];
    [deletePrompt beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSArray *oldTasks = [[NSArray alloc]
                                 initWithArray:[self.arrayController selectedObjects]
                                 copyItems:YES];
            [[self.undoManager prepareWithInvocationTarget:self] addTasks:oldTasks];
            [self.undoManager setActionName:NSLocalizedString(@"Delete Tasks", @"Undo Delete Tasks")];
            
            [self.arrayController removeObjectsAtArrangedObjectIndexes:[self.tableView selectedRowIndexes]];
            [self refreshTaskListWithSave:YES];
        }
    }];
}

- (IBAction)appendText:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Append Text";
    alert.informativeText = @"Text to append to each selected task:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 295, 24)];
    [input setStringValue:@""];
    [alert setAccessoryView:input];
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn || [[input stringValue] length] == 0) {
            return;
        }

        NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                 copyItems:YES];
        NSMutableArray *newTasks = [[NSMutableArray alloc] init];
        
        for (TTMTask *task in [self.arrayController selectedObjects]) {
            [task appendText:[input stringValue]];
            [newTasks addObject:[task copy]];
        }
        
        [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
        [self.undoManager setActionName:NSLocalizedString(@"Append Text", @"Undo Append Text")];
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}

- (IBAction)prependText:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Prepend Text";
    alert.informativeText = @"Text to prepend to each selected task:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 295, 24)];
    [input setStringValue:@""];
    [alert setAccessoryView:input];
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn || [[input stringValue] length] == 0) {
            return;
        }
        
        NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                 copyItems:YES];
        NSMutableArray *newTasks = [[NSMutableArray alloc] init];
        
        for (TTMTask *task in [self.arrayController selectedObjects]) {
            [task prependText:[input stringValue]];
            [newTasks addObject:[task copy]];
        }
        
        [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
        [self.undoManager setActionName:NSLocalizedString(@"Prepend Text", @"Undo Prepend Text")];
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}

- (IBAction)replaceText:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Replace Text";
    alert.informativeText = @"Text to find and replace in each selected task:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [NSBundle.mainBundle loadNibNamed:@"TTMFindReplace" owner:self topLevelObjects:nil];
    [alert setAccessoryView:self.findReplaceView];
    
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn || [[self.findText stringValue] length] == 0) {
            return;
        }
        
        NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                 copyItems:YES];
        NSMutableArray *newTasks = [[NSMutableArray alloc] init];
        
        for (TTMTask *task in [self.arrayController selectedObjects]) {
            [task replaceText:[self.findText stringValue] withText:[self.replaceText stringValue]];
            [newTasks addObject:[task copy]];
        }
        
        [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
        [self.undoManager setActionName:NSLocalizedString(@"Replace Text", @"Undo Replace Text")];
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}

#pragma mark - Priority Methods

- (IBAction)setPriority:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Set Priority";
    alert.informativeText = @"Priority:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 295, 24)];
    [input setStringValue:@""];
    [alert setAccessoryView:input];
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn || [[input stringValue] length] == 0) {
            return;
        }
        
        NSString *uppercaseInputString = [[input stringValue] uppercaseString];
        unichar priority = [uppercaseInputString characterAtIndex:0];
        NSCharacterSet *validPriorityCharacters = [NSCharacterSet uppercaseLetterCharacterSet];
        if (![validPriorityCharacters characterIsMember:priority]) {
            return;
        }
        
        NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                 copyItems:YES];
        NSMutableArray *newTasks = [[NSMutableArray alloc] init];
        
        for (TTMTask *task in [self.arrayController selectedObjects]) {
            [task setPriority:priority];
            [newTasks addObject:[task copy]];
        }
        
        [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
        [self.undoManager setActionName:NSLocalizedString(@"Set Priority", @"Undo Set Priority")];

        [self refreshTaskListWithSave:YES];
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}

- (IBAction)increasePriority:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task increasePriority];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Increase Priority", @"Undo Increase Priority")];
}

- (IBAction)decreasePriority:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task decreasePriority];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Decrease Priority", @"Undo Decrease Priority")];
}

- (IBAction)removePriority:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task removePriority];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Remove Priority", @"Undo Remove Priority")];
}

# pragma mark - Postpone/Due Date Methods

- (IBAction)setDueDate:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Due date";
    alert.informativeText = @"Set the due date:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSDatePicker *input = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0, 0, 110, 24)];
    [input setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    [input setDateValue:[TTMDateUtility today]];
    [alert setAccessoryView:input];
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                     copyItems:YES];
            NSMutableArray *newTasks = [[NSMutableArray alloc] init];
            
            for (TTMTask *task in [self.arrayController selectedObjects]) {
                [task setDueDate:[input dateValue]];
                [newTasks addObject:[task copy]];
            }

            [self refreshTaskListWithSave:YES];

            [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
            [self.undoManager setActionName:NSLocalizedString(@"Set Due Date", @"Undo Set Due Date")];
        }
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}

- (IBAction)increaseDueDateByOneDay:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task incrementDueDate:1];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Increase Due Date", @"Undo Increase Due Date")];
}

- (IBAction)decreaseDueDateByOneDay:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task decrementDueDate:1];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Decrease Due Date", @"Undo Decrease Due Date")];
}

- (IBAction)removeDueDate:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task removeDueDate];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Remove Due Date", @"Undo Remove Due Date")];
}

- (IBAction)postpone:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Postpone";
    alert.informativeText = @"Days to postpone task:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 295, 24)];
    [input setStringValue:@""];
    [alert setAccessoryView:input];
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn &&
            [[input stringValue] length] != 0 &&
            [input integerValue] != 0) {
            NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                     copyItems:YES];
            NSMutableArray *newTasks = [[NSMutableArray alloc] init];
            
            for (TTMTask *task in [self.arrayController selectedObjects]) {
                [task postponeTask:[input integerValue]];
                [newTasks addObject:[task copy]];
            }

            [self refreshTaskListWithSave:YES];

            [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
            [self.undoManager setActionName:NSLocalizedString(@"Postpone", @"Undo Postpone")];
        }
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}

#pragma mark - Threshold Date Methods

- (IBAction)setThresholdDate:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Threshold Date";
    alert.informativeText = @"Set the threshold date:";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSDatePicker *input = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0, 0, 110, 24)];
    [input setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    [input setDateValue:[TTMDateUtility today]];
    [alert setAccessoryView:input];
    
    // Define the completion handler for the modal sheet.
    void (^completionHandler)(NSModalResponse returnCode) = ^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                                     copyItems:YES];
            NSMutableArray *newTasks = [[NSMutableArray alloc] init];
            
            for (TTMTask *task in [self.arrayController selectedObjects]) {
                [task setThresholdDate:[input dateValue]];
                [newTasks addObject:[task copy]];
            }

            [self refreshTaskListWithSave:YES];

            [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
            [self.undoManager setActionName:NSLocalizedString(@"Set Threshold Date", @"Undo Set Threshold Date")];
        }
    };
    
    [alert beginSheetModalForWindow:self.windowForSheet completionHandler: completionHandler];
}


- (IBAction)increaseThresholdDateByOneDay:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task incrementThresholdDate:1];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Increase Threshold Date", @"Undo Increase Threshold Date")];
}

- (IBAction)decreaseThresholdDateByOneDay:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task decrementThresholdDate:1];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Decrease Threshold Date", @"Undo Decrease Threshold Date")];
}

- (IBAction)removeThresholdDate:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    NSMutableArray *newTasks = [[NSMutableArray alloc] init];
    
    for (TTMTask *task in [self.arrayController selectedObjects]) {
        [task removeThresholdDate];
        [newTasks addObject:[task copy]];
    }

    [self refreshTaskListWithSave:YES];

    [[self.undoManager prepareWithInvocationTarget:self] replaceTasks:newTasks withTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Remove Threshold Date", @"Undo Remove Threshold Date")];
}

#pragma mark - Sorting Methods

- (void)sortTaskList:(TTMTaskListSortType)sortType {
    
    // set up sort descriptors for the arrayController
    NSSortDescriptor *isPrioritizedDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"isPrioritized"
                                    ascending:NO
                                     selector:@selector(compare:)];
    NSSortDescriptor *priorityDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"priority"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *hasProjectsDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"hasProjects"
                                    ascending:NO
                                     selector:@selector(compare:)];
    NSSortDescriptor *projectDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"projects"
                                    ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *hasContextsDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"hasContexts"
                                    ascending:NO
                                     selector:@selector(compare:)];
    NSSortDescriptor *contextDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"contexts"
                                    ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *dueStateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"dueState"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *dueDateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"dueDate"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *creationDateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"creationDate"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *completionDateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"completionDate"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *taskIdDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"taskId"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *completedDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"isCompleted"
                                    ascending:YES
                                     selector:@selector(compare:)];
    NSSortDescriptor *thresholdDateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"thresholdDate"
                                ascending:YES
                                 selector:@selector(compare:)];
    NSSortDescriptor *alphabeticalDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"rawText"
                                    ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
    
    // apply sort descriptors, depending on sort type, to the arrayController
    NSArray *sortDescriptors;
    switch (sortType) {
        case TTMSortOrderInFile:
            sortDescriptors = @[taskIdDescriptor];
            break;
        case TTMSortPriority:
            sortDescriptors = @[isPrioritizedDescriptor, priorityDescriptor, completedDescriptor,
                                dueStateDescriptor, dueDateDescriptor, thresholdDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortProject:
            sortDescriptors = @[hasProjectsDescriptor, projectDescriptor, priorityDescriptor,
                                completedDescriptor, dueDateDescriptor, thresholdDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortContext:
            sortDescriptors = @[hasContextsDescriptor, contextDescriptor, isPrioritizedDescriptor,
                                priorityDescriptor, completedDescriptor, dueDateDescriptor, thresholdDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortDueDate:
            sortDescriptors = @[dueDateDescriptor, isPrioritizedDescriptor, priorityDescriptor,
                                thresholdDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortCreationDate:
            sortDescriptors = @[creationDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortCompletionDate:
            sortDescriptors = @[completionDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortThresholdDate:
            sortDescriptors = @[thresholdDateDescriptor, isPrioritizedDescriptor, priorityDescriptor, completedDescriptor, dueStateDescriptor, dueDateDescriptor, taskIdDescriptor];
            break;
        case TTMSortAlphabetical:
            sortDescriptors = @[alphabeticalDescriptor];
            break;
        default:
            sortDescriptors = @[taskIdDescriptor];
            break;
    }
    [self.arrayController setSortDescriptors:sortDescriptors];
    
    // Update the active sort type.
    self.activeSortType = sortType;
    
    // Change the default sort type.
    [[NSUserDefaults standardUserDefaults] setInteger:sortType forKey:@"taskListSortType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateTaskListMetadata];
}

- (IBAction)sortTaskListUsingTagforPreset:(id)sender {
    [self sortTaskList:[sender tag]];
}

#pragma mark - Filter Methods

- (NSPredicate*)combineFilterPresetPredicate:(NSPredicate*)filterPresetPredicate
                   withSearchFilterPredicate:(NSPredicate*)searchFilterPredicate {
    if (searchFilterPredicate == nil && filterPresetPredicate == nil) {
        return nil;
    }
    
    if (searchFilterPredicate == nil && filterPresetPredicate != nil) {
        return filterPresetPredicate;
    }
    
    if (searchFilterPredicate != nil && filterPresetPredicate == nil) {
        return searchFilterPredicate;
    }
    
    // if (searchFilterPredicate != nil && filterPresetPredicate != nil)
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                                      @[filterPresetPredicate, searchFilterPredicate]];
    return predicate;
}

- (IBAction)filterTaskListUsingTagforPreset:(id)sender {
    [self changeActiveFilterPredicateToPreset:[sender tag]];
}

- (void)removeTaskListFilter {
    [self changeActiveFilterPredicateToPreset:0];
}

- (void)reapplyActiveFilterPredicate {
    [self changeActiveFilterPredicateToPreset:self.activeFilterPredicateNumber];
}

- (void)changeActiveFilterPredicateToPreset:(NSUInteger)presetNumber {
    NSPredicate *filterPresetPredicate = [TTMFilterPredicates
                                          getFilterPredicateFromPresetNumber:presetNumber];
    self.activeFilterPredicate = [self combineFilterPresetPredicate:filterPresetPredicate
                                          withSearchFilterPredicate:self.searchFieldPredicate];
    [TTMFilterPredicates setActiveFilterPredicate:self.activeFilterPredicate];
    [TTMFilterPredicates setActiveFilterPredicatePresetNumber:presetNumber];
    self.activeFilterPredicateNumber = presetNumber;
    [self updateTaskListMetadata];
}

#pragma mark - Archiving Methods

- (IBAction)archiveCompletedTasks:(id)sender {
    NSString *archiveFilePath = [[NSUserDefaults standardUserDefaults]
                                 objectForKey:@"archiveFilePath"];
    if ([archiveFilePath length] == 0) {
        NSAlert *noArchiveFilePrompt = [[NSAlert alloc] init];
        noArchiveFilePrompt.messageText = @"No archive file set";
        noArchiveFilePrompt.informativeText = @"No archive file is set. Assign an archive file in Preferences and try again.";
        [noArchiveFilePrompt addButtonWithTitle:@"Dismiss"];
        [noArchiveFilePrompt beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSModalResponse returnCode) {
            // do nothing
        }];
        return;
    }
    
    // Collect indexes of all completed tasks, and build string containing all completed tasks.
    NSMutableIndexSet *completedTasksIndexSet = [[NSMutableIndexSet alloc] init];
    NSMutableString *completedTasksString = [[NSMutableString alloc] init];
    NSMutableArray *archivedTasks = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [[self.arrayController arrangedObjects] count]; i++) {
        TTMTask *task = [[self.arrayController arrangedObjects] objectAtIndex:i];
        if (task.isCompleted) {
            [completedTasksIndexSet addIndex:i];
            [completedTasksString appendString:self.preferredLineEnding]; // assumption may be wrong
            [completedTasksString appendString:task.rawText];
            [archivedTasks addObject:[task copy]];
        }
    }
    
    // Abort if no completed tasks were found.
    if ([completedTasksIndexSet count] == 0) {
        return;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"allowUndoOfArchiveCommand"]) {
        [self.undoManager setActionName:NSLocalizedString(@"Archive Tasks", @"Undo Archive Tasks")];
        [[self.undoManager prepareWithInvocationTarget:self] undoArchiveTasks:archivedTasks
                                                              fromArchiveFile:archiveFilePath];
    }
    
    @try {
        // Append string containing all completed tasks to archive file.
        [self appendString:completedTasksString toArchiveFile:archiveFilePath];
        
        // Delete all completed tasks.
        [self.arrayController removeObjectsAtArrangedObjectIndexes:completedTasksIndexSet];

        // Refresh the tableView and save the file.
        [self refreshTaskListWithSave:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception reason]);
        [self refreshTaskListWithSave:NO];
    }
}

- (void)appendString:(NSString*)content toArchiveFile:(NSString*)archiveFilePath {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:archiveFilePath];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else {
        [content writeToFile:archiveFilePath
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:nil];
    }
}

- (void)removeTasks:(NSArray*)tasksToRemove fromArchiveFile:(NSString*)archiveFilePath {
    NSURL *archiveFileURL = [[NSURL alloc] initFileURLWithPath:archiveFilePath];
    NSError *err = [[NSError alloc] init];
    NSString *fileContents = [[NSString alloc] initWithContentsOfURL:archiveFileURL
                                                            encoding:NSUTF8StringEncoding
                                                               error:&err];
    
    BOOL usesWindowsLineEndings = ([fileContents rangeOfString:@"\r\n"].location != NSNotFound);
    NSString *preferredLineEnding = (usesWindowsLineEndings) ? @"\r\n" : @"\n";
    NSMutableArray *rawTextStrings = [[NSMutableArray alloc] initWithArray:[fileContents componentsSeparatedByString:preferredLineEnding]];

    for (TTMTask *task in tasksToRemove) {
        for (long j = [rawTextStrings count] - 1; j > 0; j--) {
            if ([[rawTextStrings objectAtIndex:j] isEqualToString:task.rawText]) {
                [rawTextStrings removeObjectAtIndex:j];
                break;
            }
        }
    }

    [self.undoManager setActionName:NSLocalizedString(@"Remove Tasks From Archive",
                                                      @"Undo Remove Tasks From Archive")];
    [[self.undoManager prepareWithInvocationTarget:self] archiveCompletedTasks:self];
    
    NSString *content = [rawTextStrings componentsJoinedByString:preferredLineEnding];
    [content writeToFile:archiveFilePath
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:nil];
}


#pragma mark - NSDocument Method Overrides

// Override normal copy handler to copy selected tasks from the task list.
// This does not get called when the field editor is active.
- (IBAction)copy:(id)sender {
    NSMutableArray *selectedTasksRawText = [[NSMutableArray alloc] init];
    NSIndexSet *selectedRowIndexes = [self.arrayController selectionIndexes];
    
    for (NSUInteger i = [selectedRowIndexes firstIndex];
         i != NSNotFound;
         i = [selectedRowIndexes indexGreaterThanIndex:i]) {
        NSString *rawText = [(TTMTask*)[[self.arrayController arrangedObjects]
                                        objectAtIndex:i] rawText];
        [selectedTasksRawText addObject:rawText];
    }
    
    NSString *clipboardTextString = [selectedTasksRawText componentsJoinedByString:@"\n"];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:clipboardTextString forType:NSStringPboardType];
}

// Override normal cut handler to cut selected tasks from the task list.
// This does not get called when the field editor is active.
- (IBAction)cut:(id)sender {
    NSArray *oldTasks = [[NSArray alloc] initWithArray:[self.arrayController selectedObjects]
                                             copyItems:YES];
    [[self.undoManager prepareWithInvocationTarget:self] addTasks:oldTasks];
    [self.undoManager setActionName:NSLocalizedString(@"Cut", @"Undo Cut")];

    [self copy:sender];
    [self.arrayController removeObjectsAtArrangedObjectIndexes:[self.tableView selectedRowIndexes]];
    [self refreshTaskListWithSave:YES];
}

- (IBAction)paste:(id)sender {
    [self.undoManager setActionName:NSLocalizedString(@"Paste", @"Undo Paste")];
    [self addNewTasksFromClipboard:self];
}

#pragma mark - Menu Item Validation Methods

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    // Note: Parent menu item tags rather than titles are queried so we don't need to worry about
    // internationalization of menu item title strings.
    
    // Check active sort menu item.
    if ([menuItem.parentItem tag] == SORTMENUTAG) {
        if (menuItem.tag == self.activeSortType) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
    // Check active filter menu item.
    if ([menuItem.parentItem tag] == FILTERMENUTAG) {
        if (menuItem.tag == self.activeFilterPredicateNumber) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
    // Toggle show/hide status bar menu title
    if (menuItem.tag == STATUSBARMENUITEMTAG) {
        if (self.statusBarVisable) {
            [menuItem setTitle:@"Hide Status Bar"];
        } else {
            [menuItem setTitle:@"Show Status Bar"];
        }
    }
    // Toggle copy task to new task menu item.
    if (menuItem.tag == COPYTASKTONEWTASKMENUTAG) {
        NSInteger selectedCount = [[self.arrayController selectedObjects] count];
        BOOL enabled = (selectedCount == 1);
        return enabled;
    }
    // Toggle task menu items.
    if ([menuItem.parentItem tag] == TASKMENUTAG) {
        BOOL enabled = (self.tableView.editedRow == -1);
        return enabled;
    }

    return [super validateMenuItem:menuItem];
}

#pragma mark - Find Methods

- (IBAction)moveFocusToSearchBox:(id)sender {
    [self.searchField setRefusesFirstResponder:NO];
    [self.windowForSheet makeFirstResponder:self.searchField];
    // Starting in OS X 10.10 Yosemite, setting refusesFirstResponder to YES without a delay causes
    // the search box to not be editable.
    [self performSelector:@selector(makeSearchBoxRefuseFocus:) withObject:self afterDelay:0.5];
}

- (IBAction)makeSearchBoxRefuseFocus:(id)sender {
    [self.searchField setRefusesFirstResponder:YES];
}

#pragma mark - Tasklist Metadata Methods

- (void)updateTaskListMetadata {
    // Update tasklist metadata.
    if (!self.tasklistMetadata) {
        self.tasklistMetadata = [[TTMTasklistMetadata alloc] init];
    }
    [self.tasklistMetadata updateMetadataFromTaskArray:self.taskList];
    
    // Update filtered tasklist metadata.
    if (!self.filteredTasklistMetadata) {
        self.filteredTasklistMetadata = [[TTMTasklistMetadata alloc] init];
    }
    [self.filteredTasklistMetadata
     updateMetadataFromTaskArray:[self.arrayController arrangedObjects]];
    
    // Update status bar text
    [self updateStatusBarText];
}

- (IBAction)showTasklistMetadata:(id)sender {
    [self updateTaskListMetadata];
    
    // Display tasklist metadata in a modal sheet.
    if (!self.tasklistMetadataSheet) {
        [[NSBundle mainBundle] loadNibNamed:@"TTMTasklistMetadata" owner:self topLevelObjects:nil];
    }
    [self.windowForSheet beginSheet:self.tasklistMetadataSheet completionHandler:nil];
}

- (IBAction)hideTasklistMetadata:(id)sender {
    [self.windowForSheet endSheet:self.tasklistMetadataSheet];
    [self.tasklistMetadataSheet close];
    self.tasklistMetadataSheet = nil;
}

#pragma mark - Status Bar Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selection"]) {
        [self updateStatusBarText];
        return;
    }
    
    if ([keyPath isEqualToString:@"searchFieldPredicate"]) {
        [self reapplyActiveFilterPredicate];
        return;
    }
    
    if ([keyPath isEqualToString:@"levelsOfUndo"]) {
        [self.undoManager setLevelsOfUndo:[[NSUserDefaults standardUserDefaults] integerForKey:@"levelsOfUndo"]];
        return;
    }

    if ([keyPath isEqualToString:@"filterPredicate1"]) {
        [self visualRefreshIfFilterChangedAtPreset:1];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate2"]) {
        [self visualRefreshIfFilterChangedAtPreset:2];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate3"]) {
        [self visualRefreshIfFilterChangedAtPreset:3];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate4"]) {
        [self visualRefreshIfFilterChangedAtPreset:4];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate5"]) {
        [self visualRefreshIfFilterChangedAtPreset:5];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate6"]) {
        [self visualRefreshIfFilterChangedAtPreset:6];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate7"]) {
        [self visualRefreshIfFilterChangedAtPreset:7];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate8"]) {
        [self visualRefreshIfFilterChangedAtPreset:8];
        return;
    }
    if ([keyPath isEqualToString:@"filterPredicate9"]) {
        [self visualRefreshIfFilterChangedAtPreset:9];
        
    }
}

- (void)visualRefreshIfFilterChangedAtPreset:(int)presentNumber {
    if (self.activeFilterPredicateNumber == presentNumber) {
        [self visualRefreshOnly:self];
    }
}

- (void)updateStatusBarText {
    NSString *format = [[NSUserDefaults standardUserDefaults] stringForKey:@"statusBarFormat"];
    TTMDocumentStatusBarText *txt = [[TTMDocumentStatusBarText alloc]
                                     initWithTTMDocument:self
                                     format:format];
    self.statusBarText = [txt statusBarText];
}

- (BOOL)statusBarVisable {
    return ([self.bottomConstraint constant] != 0.0);
}

- (void)setStatusBarVisable:(BOOL)flag {
    CGFloat bottomBorderHeight = (flag) ? 22.0 : 0.0;
    [self.bottomConstraint setConstant:bottomBorderHeight];
    [self.windowForSheet setContentBorderThickness:bottomBorderHeight forEdge:NSMinYEdge];
    [self.statusBarTextField setHidden:!flag];
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:@"showStatusBar"];
}

- (IBAction)toggleStatusBarVisability:(id)sender {
    [self setStatusBarVisable:!self.statusBarVisable];
}

// MARK - Column resizing methods

- (void)setTableWidthToWidthOfContents {
    CGFloat currentWidth = self.tableView.tableColumns.lastObject.width;
    CGFloat tableContentWidth = [self tableViewContentWidth];
    [self.tableView.tableColumns.lastObject setMinWidth:tableContentWidth];
    if (currentWidth > tableContentWidth) {
        [self.tableView.tableColumns.lastObject setWidth:tableContentWidth];
    }
}

- (CGFloat)tableViewContentWidth {
    NSTableView * tableView = self.tableView;
    NSRect rect = NSMakeRect(0,0, INFINITY, tableView.rowHeight);
    NSInteger columnIndex = 0;
    CGFloat maxSize = 0;
    for (NSInteger i = 0; i < tableView.numberOfRows; i++) {
        NSCell *cell = [tableView preparedCellAtColumn:columnIndex row:i];
        NSSize size = [cell cellSizeForBounds:rect];
        maxSize = MAX(maxSize, size.width);
    }
    return maxSize;
}

@end
