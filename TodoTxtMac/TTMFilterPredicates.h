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

@interface TTMFilterPredicates : NSObject

#pragma mark - Default Filter Predicate Methods

/*!
 * @method defaultFilterPredicate:
 * @abstract This method returns a default (blank) filter predicate for use with TTMDocument.
 */
+ (NSPredicate*)defaultFilterPredicate;

/*!
 * @method defaultFilterPredicateData:
 * @abstract This method returns a default (blank) filter predicate in the form of an NSData
 * object, from defaultFitlerPredicate:, for use in user defaults.
 */
+ (NSData*)defaultFilterPredicateData;

/*!
 * @method noFilterPredicate:
 * @abstract This method returns a filter predicate for use when the filter is disabled.
 */
+ (NSPredicate*)noFilterPredicate;

#pragma mark - Set Filter Predicate Methods

/*!
 * @method setFilterPredicate:toUserDefaultsKey:
 * @abstract This method sets a filter predicate value to the user defaults.
 * @param predicate The predicate to set to user defaults.
 * @param key The user defaults key to set the predicate to.
 */
+ (void)setFilterPredicate:(NSPredicate*)predicate toUserDefaultsKey:(NSString*)key;

/*!
 * @method setFilterPredicate:toPresetNumber:
 * @abstract This method sets a filter predicate value to the user defaults.
 * @param predicate The predicate to set to user defaults.
 * @param presetNumber The (user-facing) preset number to set the predicate to.
 */
+ (void)setFilterPredicate:(NSPredicate*)predicate toPresetNumber:(NSUInteger)presetNumber;

/*!
 * @method setActiveFilterPredicate:
 * @abstract This method sets the active filter predicate in user defaults.
 * @param predicate The predicate to set as the active filter predicate in user defaults.
 */
+ (void)setActiveFilterPredicate:(NSPredicate*)predicate;

#pragma mark - Get Filter Predicate Methods

/*!
 * @method getFilterPredicateFromUserDefaultsKey:
 * @abstract This method gets a filter predicate value from the user defaults.
 * @param key The user defaults key to get the predicate from.
 */
+ (NSPredicate*)getFilterPredicateFromUserDefaultsKey:(NSString*)key;

/*!
 * @method getFilterPredicateFromPresetNumber:
 * @abstract This method gets a filter predicate value from the user defaults.
 * @param presetNumber The (user-facing) preset number to get the predicate for.
 */
+ (NSPredicate*)getFilterPredicateFromPresetNumber:(NSUInteger)presetNumber;

/*!
 * @method keyFromPresetNumber:
 * @abstract This method returns the user defaults key name for a given preset number.
 * @param presetNumber The (user-facing) preset number to get the key name for.
 */
+ (NSString*)keyFromPresetNumber:(NSUInteger)presetNumber;

/*!
 * @method getActiveFilterPredicate:
 * @abstract This method returns the active filter predicate from user defaults.
 * @param presetNumber The (user-facing) preset number to get the key name for.
 */
+ (NSPredicate*)getActiveFilterPredicate;

#pragma mark - Reset Filter Predicate Methods

/*!
 * @method resetAllFilterPredicates:
 * @abstract This method clears/resets a single filter preset to the default filter predicate
 * returned by defaultFilterPredicate:.
 */
+ (void)resetFilterPredicate:(NSUInteger)presetNumber;

/*!
 * @method resetAllFilterPredicates:
 * @abstract This method clears/resets all filters to the default filter predicate
 * returned by defaultFilterPredicate:.
 */
+ (void)resetAllFilterPredicates;

@end
