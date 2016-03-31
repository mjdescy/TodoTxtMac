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

#import "TTMFilterPredicates.h"
#import "TTMTask.h"

@implementation TTMFilterPredicates

- (id)init
{
    self = [super init];
    if (self) {
        // do nothing
    }
    return self;
}

#pragma mark - Default Filter Predicate Methods

+ (NSPredicate*)defaultFilterPredicate {
    static NSPredicate *defaultPredicate = nil;
    if (defaultPredicate == nil) {
        NSPredicate *defaultSubPredicate = [NSPredicate predicateWithFormat:@"rawText contains ''"];
        NSArray *subPredicates = @[defaultSubPredicate];
        defaultPredicate = [NSCompoundPredicate
                            andPredicateWithSubpredicates:subPredicates];
    }
    return defaultPredicate;
}

+ (NSData*)defaultFilterPredicateData {
    static NSData *defaultPredicateData = nil;
    if (defaultPredicateData == nil) {
        defaultPredicateData = [NSKeyedArchiver
                                archivedDataWithRootObject:[self defaultFilterPredicate]];
    }
    return defaultPredicateData;
}

+ (NSPredicate*)noFilterPredicate {
    return [self filterPredicateWithHideOptions];
}

+ (BOOL)hideFutureTasks {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideFutureTasks"];
}

+ (BOOL)hideHiddenTasks {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHiddenTasks"];
}


+ (NSPredicate*)filterPredicateWithHideOptions {
    NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
    if ([self hideFutureTasks]) {
        [subPredicates addObject:[self hideFutureTasksFilterSubPredicate]];
    }
    if ([self hideHiddenTasks]) {
        [subPredicates addObject:[self hideHiddenTasksFilterSubPredicate]];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate*)hideFutureTasksFilterSubPredicate {
    return [NSPredicate predicateWithFormat:@"thresholdState != %d", (int)ThresholdAfterToday];
}

+ (NSPredicate*)hideHiddenTasksFilterSubPredicate {
    return [NSPredicate predicateWithFormat:@"isHidden == 0"];
}

#pragma mark - Set Filter Predicate Methods

+ (void)setFilterPredicate:(NSPredicate*)predicate toUserDefaultsKey:(NSString*)key {
    NSData *filterPredicateData = [NSKeyedArchiver archivedDataWithRootObject:predicate];
    [[NSUserDefaults standardUserDefaults] setObject:filterPredicateData forKey:key];
}

+ (void)setFilterPredicate:(NSPredicate*)predicate toPresetNumber:(NSUInteger)presetNumber {
    [self setFilterPredicate:predicate toUserDefaultsKey:[self keyFromPresetNumber:presetNumber]];
}

+ (void)setActiveFilterPredicate:(NSPredicate*)predicate {
    [self setFilterPredicate:predicate toUserDefaultsKey:@"activeFilterPredicate"];
}

#pragma mark - Get Filter Predicate Methods

+ (NSPredicate*)getFilterPredicateFromUserDefaultsKey:(NSString*)key {
    NSData *filterPredicateData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:filterPredicateData];
}

+ (NSPredicate*)getFilterPredicateFromPresetNumber:(NSUInteger)presetNumber {
    if (presetNumber < 1 || presetNumber > 9) {
        return [self noFilterPredicate];
    }
    
    NSPredicate *defaultPredicate = [self filterPredicateWithHideOptions];
    
    NSPredicate *filterPresetSubPredicate = [self getFilterPredicateFromUserDefaultsKey:[self keyFromPresetNumber:presetNumber]];

    if ([self hideFutureTasks] || [self hideHiddenTasks]) {
        NSArray *subPredicates = @[defaultPredicate, filterPresetSubPredicate];
        return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    } else {
        return filterPresetSubPredicate;
    }
}

+ (NSString*)keyFromPresetNumber:(NSUInteger)presetNumber {
    if (presetNumber > 9) {
        return nil;
    }
    return [NSString stringWithFormat:@"filterPredicate%lu", (unsigned long)presetNumber];
}

+ (NSPredicate*)activeFilterPredicate {
    return [self getFilterPredicateFromPresetNumber:[self activeFilterPredicatePresetNumber]];
}

+ (void)setActiveFilterPredicatePresetNumber:(NSUInteger)presetNumber {
    [[NSUserDefaults standardUserDefaults] setObject:@(presetNumber) forKey:@"activeFilterPreset"];
}

+ (NSUInteger)activeFilterPredicatePresetNumber {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"activeFilterPreset"];
}

#pragma mark - Reset Filter Predicate Methods

+ (void)resetFilterPredicate:(NSUInteger)presetNumber {
    [self setFilterPredicate:[self defaultFilterPredicate] toPresetNumber:presetNumber];
}

+ (void)resetAllFilterPredicates {
    for (int i = 1; i <= 9; i++) {
        [self resetFilterPredicate:i];
    }
}

@end
