//
//  CalculatorBrain.m
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University.
//  All rights reserved.
//

#import "CalculatorBrain.h"

#define VARIABLE_PREFIX @"%%"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize expression = _expression;

/* private static method that provides an instance of CalculatorBrain to run static methods */
+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

/* lazy init of the program stack that contains numbers, variables, and operations */
- (NSMutableArray *)programStack {
    if(_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

/* getter to return the expression */
- (id)expression {
    return [self.programStack copy];
}

/* set an operand into memory */
- (void)setOperand:(double)aDouble {
    [self.programStack addObject:[NSNumber numberWithDouble:aDouble]];
}

/* set a variable into memory */
- (void)setVariableAsOperand:(NSString *)variableName {
    
    /* if we get a variable to put on the stack prepend %% so we can tell this is a variable in our expression and add to stack */
    [self.programStack addObject:[VARIABLE_PREFIX stringByAppendingString:variableName]];
}

/* add and operation to memory or clear memory */
- (double)performOperation:(NSString *)operation {
    
    /* if the user presses clear nill out the stack */
    if([operation isEqualToString:@"C"]) {
        [self setProgramStack:nil];
    } else  {
        [self.programStack addObject:operation];
    }
    return [[self class] runProgram:self.expression];
}

/* evaluate a given expression using variables passed in */
+ (double)evaluateExpression:(id)anExpression usingVariableValues:(NSDictionary *)variables {
    
    /* an expression should be of type NSArray to be valid */
    if([anExpression isKindOfClass:[NSArray class]]) {
    
        /* substitute values for variables when running program */
        NSArray *expressionToIterateOver = anExpression;
        NSMutableArray *mutableCopyOfExpression = [anExpression mutableCopy];
    
        for(id element in expressionToIterateOver) {
            
            /* if the type is string it could be a variable */
            if([element isKindOfClass:[NSString class]]) {

                /* see if string is a variable if so replace it in the mutable copy */
                NSString *value = element;
                NSRange variablePrefixRange = [value rangeOfString:VARIABLE_PREFIX];
                
                if(variablePrefixRange.location != NSNotFound) {
                    
                    /* variable */
                    NSRange variableNameRange = NSMakeRange(VARIABLE_PREFIX.length,1);
                    NSString *variableName = [value substringWithRange:variableNameRange];
                   
                    if([variables objectForKey:variableName]) {
                        /* set the variable value in place of the variable in the expression copy */
                    [mutableCopyOfExpression replaceObjectAtIndex:[expressionToIterateOver indexOfObject:element]
                                                       withObject:[variables objectForKey:variableName]];
                    }
                }
            }
        }
    
        /* after substitution start calculation on the updated mutable copy */
        return [CalculatorBrain popOperandOffProgramStack:mutableCopyOfExpression];
    
    } else {
        return nil;
    }
}

/* private static method to process the stack */
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

+ (id)propertyListForExpression:(id)anExpression {
    
    /* take in an immutable NSArray expression and return mutable property list */
    if([anExpression isKindOfClass:[NSArray class]]) {
        return [anExpression mutableCopy];
    } else {
        return nil;
    }
}

+ (id)expressionForPropertyList:(id)propertyList {
    
    /* take in a NSMutableArray propertyList and return and immutable NSArray representing the expression */
    if([propertyList isKindOfClass:[NSMutableArray class]]) {
        return [propertyList copy];
    } else {
        return nil;
    }
}

+ (NSSet *)variablesInExpression:(id)anExpression {
    return nil;
}

+ (NSString *)descriptionOfExpression:(id)anExpression {
    return nil;
}

@end
