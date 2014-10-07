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
@class TTMTask;

@interface TTMTasklistMetadata : NSObject

#pragma mark - Properties

@property (nonatomic) NSMutableSet *projectsSet;
@property (nonatomic) NSMutableSet *contextsSet;
@property (nonatomic) NSMutableSet *prioritiesSet;
@property (nonatomic) NSArray *contextsArray;
@property (nonatomic) NSArray *projectsArray;
@property (nonatomic) NSArray *prioritiesArray;
@property (nonatomic) NSMutableDictionary *projectTaskCounts;
@property (nonatomic) NSMutableDictionary *contextTaskCounts;
@property (nonatomic) NSMutableDictionary *priorityTaskCounts;
@property (nonatomic) NSInteger allTaskCount;
@property (nonatomic) NSInteger completedTaskCount;
@property (nonatomic) NSInteger incompleteTaskCount;
@property (nonatomic) NSInteger dueTodayTaskCount;
@property (nonatomic) NSInteger overdueTaskCount;
@property (nonatomic) NSInteger notDueTaskCount;
@property (nonatomic) NSInteger projectsCount;
@property (nonatomic) NSInteger contextsCount;
@property (nonatomic) NSInteger prioritiesCount;

/*!
 * @method updateMetadataFromTaskArray:
 * @abstract Generates metadata from a list of tasks.
 * @param taskArray An array of TTMTask objects.
 */
- (void)updateMetadataFromTaskArray:(NSArray*)taskArray;

/*!
 * @method initialize:
 * @abstract Initializes the class. Called in method updateMetadataFromTaskArray:.
 */
- (void)initialize;

/*!
 * @method initialize:
 * @abstract Helper function to populate task counts in the properties projectTaskCounts,
 * contextTaskCounts, and priorityTaskCounts. Called in method updateMetadataFromTaskArray:.
 */
- (void)incrementCountsInDictionary:(NSMutableDictionary*)dictionary FromArray:(NSArray*)array;

@end
