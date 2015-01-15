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

@interface TTMPreferencesController : NSWindowController

@property (nonatomic, retain) IBOutlet TTMAppController *appController;
@property (nonatomic, retain) NSFont *selectedFont;

#pragma mark - General Prefererences Methods

/*!
 * @method resetAllUserPreferencesToDefaults:
 * @abstract This method allows the user to reset all user preferences and 
 * filters to the defaults defined in TTMAppDelegate.
 */
- (IBAction)resetAllUserPreferencesToDefaults:(id)sender;

#pragma mark - Choose File Methods

/*!
 * @method chooseArchiveFile:
 * @abstract This method allows the user to choose the archive file (done.txt).
 */
- (IBAction)chooseArchiveFile:(id)sender;

/*!
 * @method chooseDefaultTodoFile:
 * @abstract This method allows the user to choose a default todo.txt file to open at startup.
 */
- (IBAction)chooseDefaultTodoFile:(id)sender;

/*!
 * @method chooseFileForUserDefaultsKey:withPrompt:
 * @abstract This method calls the file open method, allows the user to select a file,
 * and stores the file URL to a specified user default key.
 * @discussion This is a helper method called by chooseArchiveFile: and chooseDefaultTodoFile:.
 */
- (void)chooseFileForUserDefaultsKey:(NSString*)userDefaultsKey withPrompt:(NSString*)prompt;

#pragma mark - Font Change Methods

/*!
 * @method openFontPanel:
 * @abstract This method allows the user to choose a user font from the font panel.
 * @discussion The changeFont: method is called whenever the user changes the font in the font panel.
 */
- (IBAction)openFontPanel:(id)sender;

#pragma mark - Color Change Methods

/*!
 * @method colorChanged:
 * @abstract This method triggers a visual refresh of all open todo files.
 * @discussion This method is called whenever a user changes the color in an associated colorwell.
 */
- (IBAction)colorChanged:(id)sender;

@end
