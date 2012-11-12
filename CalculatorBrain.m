//
//  CalculatorBrain.m
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University.
//  All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize program = _program;

- (NSMutableArray *)programStack {
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program {
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program {
    return @"Implement this in Homework #2";
}

- (void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation {
    
    /* if the user presses clear nill out the stack */
    if([operation isEqualToString:@"C"]) {
        [self setProgramStack:nil];
    } else  {
        [self.programStack addObject:operation];
    }
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack {
    double result = 0;

    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if([operation isEqualToString:@"sin"]) {
            result = sin ([self popOperandOffProgramStack:stack]);
        } else if([operation isEqualToString:@"cos"]) {
            result = cos ([self popOperandOffProgramStack:stack]);
        } else if([operation isEqualToString:@"1/x"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if(divisor) result = 1 / divisor;
        } else if([operation isEqualToString:@"sqrt"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if(divisor) result = sqrt(divisor);
        } else if([operation isEqualToString:@"+/-"]) {
            result = -1 * [self popOperandOffProgramStack:stack];
        }
    }

    return result;
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

@end
