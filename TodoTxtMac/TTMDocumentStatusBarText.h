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

@class TTMDocument;

@interface TTMDocumentStatusBarText : NSObject

extern NSString* const TTMAllStatusBarAllTaskCountTag;
extern NSString* const TTMAllCompletedTaskCount;
extern NSString* const TTMAllIncompleteTaskCount;
extern NSString* const TTMAllDueTodayTaskCount;
extern NSString* const TTMAllOverdueTaskCount;
extern NSString* const TTMAllNotDueTaskCount;
extern NSString* const TTMAllProjectsCount;
extern NSString* const TTMAllContextsCount;
extern NSString* const TTMAllPrioritiesCount;
extern NSString* const TTMAllActiveFilterNumber;
extern NSString* const TTMAllActiveSortNumber;
extern NSString* const TTMShownStatusBarAllTaskCountTag;
extern NSString* const TTMShownCompletedTaskCount;
extern NSString* const TTMShownIncompleteTaskCount;
extern NSString* const TTMShownDueTodayTaskCount;
extern NSString* const TTMShownOverdueTaskCount;
extern NSString* const TTMShownNotDueTaskCount;
extern NSString* const TTMShownProjectsCount;
extern NSString* const TTMShownContextsCount;
extern NSString* const TTMShownPrioritiesCount;
extern NSString* const TTMActiveFilterNumber;
extern NSString* const TTMActiveSortNumber;
extern NSString* const TTMActiveSortName;

@property (nonatomic, retain) TTMDocument *document;
@property (nonatomic) NSString *format;

#pragma mark - Init Method

/*!
 * @method initWithTTMDocument:format:
 * @abstract This is the proper init method to call. A source document and format string must 
 * be passed to this class for proper functionality.
 * @param sourceDocument A TTMDocument, which contains metadata from which to build a string.
 * @param format A format string, containing plaintext and tags.
 */
- (id)initWithTTMDocument:(TTMDocument*)sourceDocument format:(NSString*)format;

#pragma mark - Metadata Method

/*!
 * @method documentMetadata:
 * @abstract This is a convenience method that creates a dictionary with tags as keys and
 * document metadata values as objects. This dictionary is used in the statusBarText: method.
 */
- (NSDictionary*)documentMetadata;

#pragma mark - Output/Property Methods

/*!
 * @method statusBarText:
 * @abstract This method produces text for the task list status bar. It builds the output string
 * by replacing tags within the format property string with document metadata.
 */
- (NSString*)statusBarText;

/*!
 * @method availableTags:
 * @abstract This method returns a list of tags available for the user to insert into the status
 * bar format string.
 */
+ (NSArray*)availableTags;

/*!
 * @method defaultFormat:
 * @abstract This method returns the default status bar format string. 
 */
+ (NSString*)defaultFormat;

@end
