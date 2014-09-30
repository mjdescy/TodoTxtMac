//
//  TTMMetadataTests.m
//  TodoTxtMac
//
//  Created by Michael Descy on 8/9/14.
//  Copyright (c) 2014 Michael Descy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TTMTask.h"
#import "TTMTasklistMetadata.h"

@interface TTMTasklistMetadataTests : XCTestCase

@property NSMutableArray *taskList;
@property TTMTasklistMetadata *tasklistMetadata;

@end

@implementation TTMTasklistMetadataTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSArray *rawTaskList = @[
                             @"(A) Task 1 @Context1 +Project1",
                             @"x 2014-10-01 Task 2 +Project1 due:2014-01-31",
                             @"(C) Task 3 +Project1 @Context1 due:9999-01-01",
                             @"(C) Task 4 +Project2 due:9999-12-31",
                             @"(A) Task 5 +Project2 @Context2 due:2014-01-31"
                            ];
    self.taskList = [NSMutableArray array];
    NSInteger i = 0;
    for (NSString *rawTaskText in rawTaskList) {
        TTMTask *task = [[TTMTask alloc] initWithRawText:rawTaskText withTaskId:i];
        [self.taskList addObject:task];
        i++;
    }
    
    self.tasklistMetadata = [[TTMTasklistMetadata alloc] init];
    [self.tasklistMetadata updateMetadataFromTaskArray:self.taskList];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAllTaskCount
{
    XCTAssertEqual(self.tasklistMetadata.allTaskCount, 5);
}

- (void)testIncompleteTaskCount
{
    XCTAssertEqual(self.tasklistMetadata.incompleteTaskCount, 4);
}

- (void)testCompletedTaskCount
{
    XCTAssertEqual(self.tasklistMetadata.completedTaskCount, 1);
}

- (void)testDueTodayTaskCount
{
    XCTAssertEqual(self.tasklistMetadata.dueTodayTaskCount, 0);
}

- (void)testOverdueTaskCount
{
    XCTAssertEqual(self.tasklistMetadata.overdueTaskCount, 1);
}

- (void)testNotDueTaskCount
{
    XCTAssertEqual(self.tasklistMetadata.notDueTaskCount, 4);
}

- (void)testProjectsArray
{
    NSArray *projects = @[
                          @"+Project1",
                          @"+Project2"
                         ];
    XCTAssertEqualObjects(self.tasklistMetadata.projectsArray, projects);
}

- (void)testContextsArray
{
    NSArray *contexts = @[
                          @"@Context1",
                          @"@Context2"
                         ];
    XCTAssertEqualObjects(self.tasklistMetadata.contextsArray, contexts);
}

- (void)testPrioritiesArray
{
    NSArray *priorities = @[
                            @"A",
                            @"C"
                           ];
    XCTAssertEqualObjects(self.tasklistMetadata.prioritiesArray, priorities);
}

- (void)testProjectTaskCounts
{
    NSDictionary *projectTaskCounts = @{
                                        @"+Project1" : @3,
                                        @"+Project2" : @2
                                       };
    XCTAssertEqualObjects(self.tasklistMetadata.projectTaskCounts, projectTaskCounts);
}

- (void)testContextTaskCounts
{
    NSDictionary *contextTaskCounts = @{
                                        @"@Context1" : @2,
                                        @"@Context2" : @1
                                        };
    XCTAssertEqualObjects(self.tasklistMetadata.contextTaskCounts, contextTaskCounts);
}

- (void)testPriorityTaskCounts
{
    NSDictionary *priorityTaskCounts = @{
                                         @"A" : @2,
                                         @"C" : @2
                                        };
    XCTAssertEqualObjects(self.tasklistMetadata.priorityTaskCounts, priorityTaskCounts);
}

@end
