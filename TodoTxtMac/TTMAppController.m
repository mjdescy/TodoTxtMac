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

#import "TTMAppController.h"
#import "TTMPreferencesController.h"
#import "TTMFiltersController.h"

@implementation TTMAppController

// Constants for command-line argument names
NSString *const TodoFileArgument = @"todo-file";

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (IBAction)openPreferencesWindow:(id)sender {
    if (!self.preferencesController) {
        self.preferencesController = [[TTMPreferencesController alloc]
                                      initWithWindowNibName:@"TTMPreferences"];
    }
    [self.preferencesController showWindow:self];
}

- (IBAction)openFiltersWindow:(id)sender {
    if (!self.filtersController) {
        self.filtersController = [[TTMFiltersController alloc]
                                  initWithWindowNibName:@"TTMFilters"];
    }
    [self.filtersController showWindow:self];
}

- (IBAction)openWebSite:(id)sender {
    NSURL *helpURL = [NSURL URLWithString:@"http://mjdescy.github.io/TodoTxtMac/"];
    [[NSWorkspace sharedWorkspace] openURL:helpURL];
}

#pragma mark - Command-line Argument-related Methods

- (void)openTodoFileFromCommandLineArgument {
    NSString *fileToOpenOnLaunch = [self commandLineArgumentTodoFile];
    if (!fileToOpenOnLaunch) {
        return;
    }
    [self openDocumentFromFilePath:fileToOpenOnLaunch];
}

- (NSString*)commandLineArgumentTodoFile {
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    return [args stringForKey:TodoFileArgument];
}

- (void)openDocumentFromFilePath:(NSString*)filePath {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self openDocumentFromFileURL:fileURL];
}

- (void)openDocumentFromFileURL:(NSURL*)fileURL {
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fileURL
                                                                           display:YES
                                                                 completionHandler:NULL];
}

#pragma mark - Open Default Todo.txt File Methods

-(void)openDefaultTodoFile {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"openDefaultTodoFileOnStartup"]) {
        return;
    }
    [self openDocumentFromFilePath:[[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"defaultTodoFilePath"]];
}

@end
