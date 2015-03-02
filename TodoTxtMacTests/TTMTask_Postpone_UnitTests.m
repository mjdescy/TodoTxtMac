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
#import <XCTest/XCTest.h>
#import "TTMTask.h"
#import "TTMDateUtility.h"

@interface TTMTask_Postpone_UnitTests : XCTestCase

@property NSUInteger taskId;

@end

@implementation TTMTask_Postpone_UnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.taskId = 10;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_Postpone_ByOneDayWhenTaskHasDueDateAtEnd_ShouldIncrementDueDateByOneDay {
    NSString *rawText = @"pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:1];
    NSString *expectedRawText = @"pick up groceries due:2020-02-01";
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}

- (void)test_Postpone_ByOneDayWhenTaskHasDueDateInMiddle_ShouldIncrementDueDateByOneDay {
    NSString *rawText = @"pick up groceries due:2020-01-31 +Personal";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:1];
    NSString *expectedRawText = @"pick up groceries due:2020-02-01 +Personal";
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}
- (void)test_Postpone_ByOneDayWhenTaskHasDueDateAtBeginning_ShouldIncrementDueDateByOneDay {
    NSString *rawText = @"due:2020-01-31 pick up groceries";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:1];
    NSString *expectedRawText = @"due:2020-02-01 pick up groceries";
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}

- (void)test_Postpone_ByOneDayWhenTaskHasNoDueDate_ShouldAppendDueDateOfTomorrow {
    NSString *rawText = @"pick up groceries";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:1];
    NSDate *tomorrow = [TTMDateUtility addDays:1 toDate:[TTMDateUtility today]];
    NSString *expectedRawText = [NSString stringWithFormat:@"%@%@%@",
                                 rawText,
                                 @" due:",
                                 [TTMDateUtility convertDateToString:tomorrow]];
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}

- (void)test_Postpone_ByNegativeOneDayWhenTaskHasDueDateAtEnd_ShouldDecrementDueDateByOneDay {
    NSString *rawText = @"pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:-1];
    NSString *expectedRawText = @"pick up groceries due:2020-01-30";
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}

- (void)test_Postpone_ByNegativeOneDayWhenTaskHasDueDateInMiddle_ShouldDecrementDueDateByOneDay {
    NSString *rawText = @"pick up groceries due:2020-01-31 +Personal";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:-1];
    NSString *expectedRawText = @"pick up groceries due:2020-01-30 +Personal";
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}
- (void)test_Postpone_ByNegativeOneDayWhenTaskHasDueDateAtBeginning_ShouldDecrementDueDateByOneDay {
    NSString *rawText = @"due:2020-01-31 pick up groceries";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:-1];
    NSString *expectedRawText = @"due:2020-01-30 pick up groceries";
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}

- (void)test_Postpone_ByNegativeOneDayWhenTaskHasNoDueDate_ShouldAppendDueDateOfYesterday {
    NSString *rawText = @"pick up groceries";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    [task postponeTask:-1];
    NSDate *yesterday = [TTMDateUtility addDays:-1 toDate:[TTMDateUtility today]];
    NSString *expectedRawText = [NSString stringWithFormat:@"%@%@%@",
                                 rawText,
                                 @" due:",
                                 [TTMDateUtility convertDateToString:yesterday]];
    XCTAssertEqualObjects(expectedRawText, task.rawText);
}

@end
