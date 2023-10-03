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

#import <Foundation/Foundation.h>
@class TTMPreferencesController;
@class TTMFiltersController;

@interface TTMAppController : NSObject

// Constants for command-line argument names
extern NSString *const TodoFileArgument;

@property (nonatomic, retain) TTMPreferencesController *preferencesController;
@property (nonatomic, retain) TTMFiltersController *filtersController;

- (IBAction)openPreferencesWindow:(id)sender;
- (IBAction)openFiltersWindow:(id)sender;
- (IBAction)openWebSite:(id)sender;
- (IBAction)openPlaintextProductivityWebSite:(id)sender;
- (IBAction)openTodoTxtTipsPlaintextProductivityWebSite:(id)sender;

#pragma mark - User Defaults-related Methods

/*!
 * @method initializeUserDefaults:
 * @abstract This method sets up preferences managed by NSUserDefaultsController.
 */
- (void)initializeUserDefaults:(id)sender;

/*!
 * @method resetUserDefaults:
 * @abstract This method resets preferences managed by NSUserDefaultsController to default values.
 * It does not reset fitler-related preferences.
 */
- (void)resetUserDefaults:(id)sender;

#pragma mark - Command-line Argument-related Methods

/*!
 * @method openTodoFileFromCommandLineArgument:
 * @abstract This method opens a todo.txt file based on the command line argument. 
 * The name of the argument is defined in the TodoFileArgument constant.
 * If there is no command line argument, this method does nothing.
 */
- (void)openTodoFileFromCommandLineArgument;

/*!
 * @method commandLineArgumentTodoFile:
 * @abstract This method returns the value of the todo-file command line argument.
 * If there is no command-line argument, it returns null.
 */
- (NSString*)commandLineArgumentTodoFile;

/*!
 * @method openDoneFileFromCommandLineArgument:
 * @abstract This method opens a done.txt file based on the command line argument.
 * The name of the argument is defined in the DoneFileArgument constant.
 * If there is no command line argument, this method does nothing.
 */
- (void)openDoneFileFromCommandLineArgument;

/*!
 * @method commandLineArgumentDoneFile:
 * @abstract This method returns the value of the done-file command line argument.
 * If there is no command-line argument, it returns null.
 */
- (NSString*)commandLineArgumentDoneFile;

/*!
 * @method openDocumentFromFilePath:
 * @abstract This method opens a todo.txt file (TTMDocument) based on a file path.
 */
- (void)openDocumentFromFilePath:(NSString*)filePath;

/*!
 * @method openDocumentFromFilePath:
 * @abstract This method opens a todo.txt file (TTMDocument) based on a file URL.
 */
- (void)openDocumentFromFileURL:(NSURL*)fileURL;

#pragma mark - Open Default Todo.txt File Methods

/*!
 * @method openDefaultTodoFile:
 * @abstract This method opens the default todo.txt file (TTMDocument) based on user preferences.
 * If the user preference for opening a default todo.txt file on startup is disabled,
 * this method does nothing.
 */
-(void)openDefaultTodoFile;

#pragma mark - Close All Windows Methods

/*!
 * @method closeAllWindows:
 * @abstract This method closes all open windows.
 */
- (IBAction)closeAllWindows:(id)sender;

/*!
 * @method documentController:didCloseAll:contextInfo
 * @abstract This method is a completion handler for closeAllWindows. It does nothing.
 */
- (void)documentController:(NSDocumentController *)docController
               didCloseAll:(BOOL)didCloseAll
               contextInfo:(void *)contextInfo;

#pragma mark - Reload All Methods

/*!
 * @method reloadAll:
 * @abstract This method refreshes the task list from disk for all open windows.
 */
- (IBAction)reloadAll:(id)sender;

#pragma mark - Visual Refresh Methods

/*!
 * @method visualRefreshAll:
 * @abstract This method visually refreshes the task list for all open windows.
 */
- (IBAction)visualRefreshAll:(id)sender;

@end
