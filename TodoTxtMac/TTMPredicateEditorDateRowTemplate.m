//
//  TTMPredicateEditorDateRowTemplate.m
//  TodoTxtMac
//
//  Created by Michael Descy on 3/24/14.
//  Copyright (c) 2014 Michael Descy. All rights reserved.
//

#import "TTMPredicateEditorDateRowTemplate.h"
#import "TTMDateUtility.h"

@implementation TTMPredicateEditorDateRowTemplate

- (NSPredicate*)predicateWithSubpredicates:(NSArray *)subpredicates {
    NSPredicate *p = [super predicateWithSubpredicates:subpredicates];

    if ([p isKindOfClass:[NSComparisonPredicate class]]) {
        
        // Get the date value from the "right" comparison property.
        NSComparisonPredicate *comparison = (NSComparisonPredicate*)p;
        NSExpression *right = [comparison rightExpression];
        NSDate *dateValue = [right constantValue];
        
        // Set the "right" comparison property to its date value stripped of its time part
        // (that is, as of 00:00:00).
        NSDate *dateWithoutTime = [TTMDateUtility dateWithoutTime:dateValue];
        right = [NSExpression expressionForConstantValue:dateWithoutTime];
        p = [NSComparisonPredicate
             predicateWithLeftExpression:[comparison leftExpression]
                         rightExpression:right
                                modifier:[comparison comparisonPredicateModifier]
                                    type:[comparison predicateOperatorType]
                                 options:[comparison options]];
    }
    return p;
}

@end
