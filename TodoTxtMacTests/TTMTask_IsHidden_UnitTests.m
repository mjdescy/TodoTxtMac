/**
 * @author Michael Descy
 * @copyright 2014-2016 Michael Descy
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

@interface TTMTask_IsHidden_UnitTests : XCTestCase

@property NSString *rawText;
@property NSUInteger taskId;

@end

@implementation TTMTask_IsHidden_UnitTests

- (void)setUp {
    [super setUp];
    self.taskId = 10;
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_IsHidden_WhenHidden_ShouldBeTrue_Case1 {
    NSString *rawText = @"h:1 x 2020-01-31 pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertTrue(task.isHidden);
}

- (void)test_IsHidden_WhenHidden_ShouldBeTrue_Case2 {
    NSString *rawText = @"x 2020-01-31 h:1 pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertTrue(task.isHidden);
}

- (void)test_IsHidden_WhenHidden_ShouldBeTrue_Case3 {
    NSString *rawText = @"h:1 x 2020-01-31 pick up groceries due:2020-01-31 h:1";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertTrue(task.isHidden);
}

- (void)test_IsHidden_WhenHidden_ShouldBeFalse_Case1 {
    NSString *rawText = @"x 2020-01-31 pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertFalse(task.isHidden);
}

- (void)test_IsHidden_WhenHidden_ShouldBeFalse_Case2 {
    NSString *rawText = @"h:1x 2020-01-31 pick up groceries due:2020-01-31";
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:self.taskId];
    XCTAssertFalse(task.isHidden);
}

@end


