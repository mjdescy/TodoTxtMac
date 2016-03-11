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

#import "TTMPreferencesController.h"
#import "TTMAppController.h"
#import "TTMDocumentStatusBarText.h"

@implementation TTMPreferencesController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _availableStatusBarTags = [NSArray arrayWithArray:[TTMDocumentStatusBarText availableTags]];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib {
    NSFontPanel *fontPanel = [NSFontPanel sharedFontPanel];
    [fontPanel display];
}

#pragma mark - *** Window delegation ***

- (BOOL)windowShouldClose:(NSWindow *)window {
    return [window makeFirstResponder:nil]; // validate editing
}

#pragma mark - General Prefererences Methods

- (IBAction)resetAllUserPreferencesToDefaults:(id)sender {
    NSAlert *resetPrompt = [[NSAlert alloc] init];
    resetPrompt.messageText = @"Reset user preferences";
    resetPrompt.informativeText = @"Are you sure you want to do this? You will lose all settings and customizations.";
    [resetPrompt addButtonWithTitle:@"OK"];
    [resetPrompt addButtonWithTitle:@"Cancel"];
    [resetPrompt beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self.appController resetUserDefaults:self];
            [self.appController visualRefreshAll:self];
        }
    }];
}

#pragma mark - Choose File Methods

- (IBAction)chooseArchiveFile:(id)sender {
    [self chooseFileForUserDefaultsKey:@"archiveFilePath" withPrompt:@"Choose Archive File"];
}

- (IBAction)chooseDefaultTodoFile:(id)sender {
    [self chooseFileForUserDefaultsKey:@"defaultTodoFilePath" withPrompt:@"Choose todo.txt File"];
}

- (void)chooseFileForUserDefaultsKey:(NSString*)userDefaultsKey withPrompt:(NSString*)prompt {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setPrompt:prompt];
    [panel setAllowedFileTypes:@[@"txt", @"TXT", @"todo", @"TODO", @""]];
    
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        for (NSURL *fileURL in [panel URLs]) {
            [[NSUserDefaults standardUserDefaults] setValue:[fileURL path] forKey:userDefaultsKey];
        }
    }
}

#pragma mark - Font Change Methods

- (IBAction)openFontPanel:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setTarget:self];
    [fontManager setSelectedFont:[NSFont userFontOfSize:0.0] isMultiple:NO];
    [fontManager orderFrontFontPanel:self];
    [self.appController visualRefreshAll:self];
}

- (void)changeFont:(id)fontManager {
    self.selectedFont = [fontManager convertFont:self.selectedFont];
    [self.appController visualRefreshAll:self];
}

- (NSFont*)selectedFont {
    return [NSFont userFontOfSize:0.0];
}

- (void)setSelectedFont:(NSFont*)newFont {
    [NSFont setUserFont:newFont];
}

#pragma mark - Color Change Methods

- (IBAction)colorChanged:(id)sender {
    [self.appController visualRefreshAll:self];
}

#pragma mark - Status Bar Methods

- (IBAction)insertTagIntoStatusBarFormat:(id)sender {
    [[self.statusBarFormat currentEditor] insertText:self.statusBarTags.selectedObjects[0]];
}

- (IBAction)resetStatusBarFormatToDefault:(id)sender {
    NSAlert *resetPrompt = [[NSAlert alloc] init];
    resetPrompt.messageText = @"Reset status bar format to default?";
    resetPrompt.informativeText = @"Are you sure you want to do this? You will lose all status bar customizations.";
    [resetPrompt addButtonWithTitle:@"OK"];
    [resetPrompt addButtonWithTitle:@"Cancel"];
    [resetPrompt beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [[NSUserDefaults standardUserDefaults] setValue:[TTMDocumentStatusBarText defaultFormat]
                                                     forKey:@"statusBarFormat"];
            [self.appController visualRefreshAll:self];
        }
    }];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [self.appController visualRefreshAll:self];
}

@end
