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

@interface TTMTask_DueDate_UnitTests : XCTestCase

@property NSUInteger taskId;
@property NSDate *dueDate;
@property NSDate *highDate;

@end

@implementation TTMTask_DueDate_UnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.taskId = 10;
    self.dueDate = [TTMDateUtility convertStringToDate:@"2020-01-31"];
    self.highDate = [TTMDateUtility convertStringToDate:@"9999-12-31"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_DueDate_WhenAtEndOfTask_ShouldBeDueDate {
    NSString *rawText = @"pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertEqualObjects(task.dueDate, self.dueDate);
}

- (void)test_DueDate_WhenInMiddleOfTask_ShouldBeDueDate {
    NSString *rawText = @"pick up groceries due:2020-01-31 +Personal";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertEqualObjects(task.dueDate, self.dueDate);
}

- (void)test_DueDate_WhenAtStartOfTask_ShouldBeDueDate {
    NSString *rawText = @"due:2020-01-31 pick up groceries";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertEqualObjects(task.dueDate, self.dueDate);
}

- (void)test_DueDate_WhenIsEntireTask_ShouldBeDueDate {
    NSString *rawText = @"due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertEqualObjects(task.dueDate, self.dueDate);
}

- (void)test_DueDate_WhenMissingLeadingSpace_ShouldBeHighDate {
    NSString *rawText = @"pick up groceries-due:2020-01-31 +Personal";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertEqualObjects(task.dueDate, self.highDate);
}

- (void)test_DueDate_WhenMissingTrailingSpace_ShouldBeHighDate {
    NSString *rawText = @"pick up groceries due:2020-01-31+Personal";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertEqualObjects(task.dueDate, self.highDate);
}

@end
