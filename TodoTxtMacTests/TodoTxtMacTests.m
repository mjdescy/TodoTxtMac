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

#import <XCTest/XCTest.h>
#import "TTMTask.h"
#import "TTMDateUtility.h"

@interface TodoTxtMacTests : XCTestCase

@end

@implementation TodoTxtMacTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRawTextOfNormalTask {
    NSString *rawText = @"pick up groceries";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.rawText, rawText);
}

- (void)testInitWithRawTextwithTaskIdwithPrependedDate {
    NSString *rawText = @"pick up groceries";
    NSUInteger taskId = 0;    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:@"2020-01-01"];
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId withPrependedDate:date];
    XCTAssertEqualObjects(task.rawText, @"2020-01-01 pick up groceries");
}

- (void)testIsCompleted {
    NSString *rawText = @"x 2020-01-31 pick up groceries due:2020-01-31";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertTrue(task.isCompleted);
}

- (void)testDueDate {
    NSString *rawText = @"pick up groceries due:2020-01-31";
    NSUInteger taskId = 0;
    NSDate *date = [TTMDateUtility convertStringToDate:@"2020-01-31"];
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.dueDate, date);
}

- (void)testDueDateText {
    NSString *rawText = @"pick up groceries due:2020-01-31";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.dueDateText, @"2020-01-31");
}

- (void)testCreationDate {
    NSString *rawText = @"2020-01-01 pick up groceries";
    NSUInteger taskId = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *date = [dateFormatter dateFromString:@"2020-01-01 00:00:00 GMT"];
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId withPrependedDate:date];
    NSLog(@"creationDate: %@", task.creationDate);
    NSLog(@"date: %@", date);
    XCTAssertEqualObjects(task.creationDate, date);
}

- (void)testThresholdDate {
    NSString *rawText = @"pick up groceries t:2020-01-01 due:2020-01-31";
    NSUInteger taskId = 0;
    NSDate *date = [TTMDateUtility convertStringToDate:@"2020-01-01"];
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.thresholdDate, date);
}

- (void)testDateConversions {
    NSDate *firstDate = [TTMDateUtility convertStringToDate:@"2014-01-01"];
    NSLog(@"firstDate: %@", firstDate);
    NSString *firstDateString = [TTMDateUtility convertDateToString:firstDate];
    NSLog(@"firstDateString: %@", firstDateString);
    NSDate *secondDate = [TTMDateUtility convertStringToDate:firstDateString];
    NSLog(@"secondDate: %@", secondDate);
    XCTAssertEqualObjects(firstDate, secondDate);
}

- (void)testAddDaysToDate {
    NSDate *firstDate = [TTMDateUtility convertStringToDate:@"2014-01-01"];
    NSDate *secondDate = [TTMDateUtility convertStringToDate:@"2014-01-02"];
    NSDate *firstDateModified = [TTMDateUtility addDays:1 toDate:firstDate];
    NSLog(@"new date: %@", firstDateModified);
    XCTAssertEqualObjects(firstDateModified, secondDate);
}

- (void)testAddNegativeDaysToDate {
    NSDate *firstDate = [TTMDateUtility convertStringToDate:@"2014-01-02"];
    NSDate *secondDate = [TTMDateUtility convertStringToDate:@"2014-01-01"];
    NSDate *firstDateModified = [TTMDateUtility addDays:-1 toDate:firstDate];
    NSLog(@"new date: %@", firstDateModified);
    XCTAssertEqualObjects(firstDateModified, secondDate);
}

- (void)testPostponeTaskWithDueDate {
    NSString *rawText = @"pick up groceries due:2020-01-01";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    NSLog(@"due date before change: %@", task.dueDate);
    [task postponeTask:1];
    NSLog(@"due date after change: %@", task.dueDate);
    NSDate *date = [TTMDateUtility convertStringToDate:@"2020-01-02"];
    XCTAssertEqualObjects(task.dueDate, date);
}

- (void)testPostponeTaskNegativeWithDueDate {
    NSString *rawText = @"pick up groceries due:2020-01-02";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    [task postponeTask:-1];
    XCTAssertEqualObjects(task.dueDate, [TTMDateUtility convertStringToDate:@"2020-01-01"]);
}

- (void)testChangingRawTextToBlankString {
    NSString *rawText = @"pick up groceries";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    task.rawText = @"";
    XCTAssertEqualObjects(task.rawText, @"");
}

- (void)testProjects {
    NSString *rawText = @"pick up groceries +Chores +Shopping +Errands";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.projects, @"+Chores, +Errands, +Shopping");
}

- (void)testContexts {
    NSString *rawText = @"pick up groceries @Chores @Shopping @Errands";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.contexts, @"@Chores, @Errands, @Shopping");
}

- (void)testPriority {
    NSString *rawText = @"(A) pick up groceries @Chores @Shopping @Errands";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqualObjects(task.priorityText, @"A");
}

- (void)testIncreasePriority {
    NSString *rawText = @"(C) pick up groceries @Chores @Shopping @Errands";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    [task increasePriority];
    XCTAssertEqualObjects(task.priorityText, @"B");
}

- (void)testDecreasePriority {
    NSString *rawText = @"(A) pick up groceries @Chores @Shopping @Errands";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    [task decreasePriority];
    XCTAssertEqualObjects(task.priorityText, @"B");
}

- (void)testRemovePriority {
    NSString *rawText = @"(A) pick up groceries @Chores @Shopping @Errands";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    [task removePriority];
    XCTAssertEqualObjects(task.rawText, @"pick up groceries @Chores @Shopping @Errands");
}

- (void)testDueStateOverdue {
    NSString *rawText = @"(A) pick up groceries due:2001-01-01";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqual(task.dueState, Overdue);
}

- (void)testDueStateDueToday {
    NSString *rawTextPart1 = @"(A) pick up groceries due:";
    NSString *rawTextPart2 = [TTMDateUtility todayAsString];
    NSString *rawText = [rawTextPart1 stringByAppendingString:rawTextPart2];
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqual(task.dueState, DueToday);
}

- (void)testDueStateNotdue {
    NSString *rawText = @"(A) pick up groceries due:2020-12-31";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqual(task.dueState, NotDue);
}

- (void)testThresholdStateBefore {
    NSString *rawText = @"(A) pick up groceries t:2020-01-31 due:2020-01-31";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqual(task.thresholdState, BeforeThresholdDate);
}

- (void)testThresholdStateOn {
    NSString *rawTextPart1 = @"(A) pick up groceries t:";
    NSString *rawTextPart2 = [TTMDateUtility todayAsString];
    NSString *rawText = [rawTextPart1 stringByAppendingString:rawTextPart2];
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqual(task.thresholdState, OnThresholdDate);
}

- (void)testThresholdStateAfter {
    NSString *rawText = @"(A) pick up groceries t:2001-01-01 due:2020-01-31";
    NSUInteger taskId = 0;
    TTMTask *task = [[TTMTask alloc] initWithRawText:rawText withTaskId:taskId];
    XCTAssertEqual(task.thresholdState, AfterThresholdDate);
}



@end
