//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Timothée Boucher on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

NSSet *validOperations, *twoOperandOperations, *oneOperandOperations, *noOperandOperations;

@implementation CalculatorBrain

@synthesize programStack = _programStack;

/* like a static block in java setup these variables before any instances of the class are created */
+(void) initialize {
    if (!validOperations) {
        validOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", @"π", @"+/-", @"+", @"-", @"*", @"/" , nil];
        twoOperandOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/" , nil];
        oneOperandOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", @"+/-", nil];
        noOperandOperations  = [[NSSet alloc] initWithObjects:@"π", nil];
    }
}

/* class utility method to see if a certain element is a variable or not */
+(BOOL)isVariable:(id)operand {
    return [operand isKindOfClass:[NSString class]] && ![validOperations containsObject:operand];
}

/* class utility method to see if a certain element is an operation or not */
+(BOOL)isOperation:(id)operation {
    return [operation isKindOfClass:[NSString class]] && [validOperations containsObject:operation];
}

/* getter for the porgram stack allows lazy init */
-(NSMutableArray *)programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

/* public interface for the state contained in the CalculatorBrain */
-(id) program {
    return [self.programStack copy];
}

/* recursive class utility method to return a human readable representation of the contents of the stack */
+(NSString *)descriptionOfTopOfStack:(id)stack previousOperation:(NSString *)previousOperation {
    NSString *result;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack stringValue];
    } else if ([self isVariable:topOfStack]) {
        result =  topOfStack;
    } else if ([self isOperation:topOfStack]) {
        if ([noOperandOperations containsObject:topOfStack]) {
            result = topOfStack;
        } else if ([oneOperandOperations containsObject:topOfStack]) {
            if ([topOfStack isEqualToString:@"+/-"]) topOfStack = @"-";
            result = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack previousOperation:nil]];
        } else {
            NSString *secondPart = [self descriptionOfTopOfStack:stack previousOperation:topOfStack];
            NSString *firstPart = [self descriptionOfTopOfStack:stack previousOperation:topOfStack];
            if ([topOfStack isEqualToString:@"+"] || [topOfStack isEqualToString:@"-"]) {
                if ([previousOperation isEqualToString:@"*"] || [previousOperation isEqualToString:@"/"]) {
                    result = [NSString stringWithFormat:@"(%@ %@ %@)", firstPart, topOfStack, secondPart];
                } else {
                    result = [NSString stringWithFormat:@"%@ %@ %@", firstPart, topOfStack, secondPart];
                }
            } else {
                result = [NSString stringWithFormat:@"%@ %@ %@", firstPart, topOfStack, secondPart];
            }
        }        
    } else {
        result = @"0";
    }
    return result;
}

/* public interface for returning human readable representation of the contents of the stack */
+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    NSMutableString *result;
    BOOL firstTimeInLoop = YES;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    while ([stack count]) {
        if (firstTimeInLoop) {
            result = [[self descriptionOfTopOfStack:stack previousOperation:nil] mutableCopy];
            firstTimeInLoop = NO;
        } else {
            [result appendFormat:@", %@", [self descriptionOfTopOfStack:stack previousOperation:nil]];
        }
    }
    return result;
}

/* add an operand to the stack */
-(void) pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

/* add a variable to the stack */
-(void) pushVariable:(NSString *)variable {
    if ([CalculatorBrain isVariable:variable]) {
        [self.programStack addObject:variable];
    }
}

/* perform a given operation on the elements in the stack */
- (id)performOperation:(NSString *)operation {
    if ([CalculatorBrain isOperation:operation]) {
        [self.programStack addObject:operation];
    }
    return [[self class] runProgram:self.program];
}

/* pop an operand off the stack */
-(double) popOperand {
    NSNumber *operandObject = [self.programStack lastObject];
    if (operandObject) [self.programStack removeLastObject];
    return [operandObject doubleValue];
}

/* recursive class method for evaluating the stack and running any operations */
+(id) popOperandOffProgramStack:(NSMutableArray *)stack {
    id result;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = topOfStack;
    } else if ([topOfStack isKindOfClass:[NSString class]]) { // if it's an NSString, it's an operation
        NSString *operation = topOfStack;
        if ([noOperandOperations containsObject:operation]) {
            if ([operation isEqualToString:@"π"]) {
                result = [NSNumber numberWithDouble:M_PI];
            }
        } else {
            id topOperand = [self popOperandOffProgramStack:stack];
            if ([topOperand isKindOfClass:[NSString class]]) {
                result = topOperand;
            } else if ([topOperand isKindOfClass:[NSNumber class]]) {
                if ([oneOperandOperations containsObject:operation]) {
                    if ([operation isEqualToString:@"sin"]) {
                        result = [NSNumber numberWithDouble:sin([topOperand doubleValue])];
                    } else if ([operation isEqualToString:@"cos"]) {
                        result = [NSNumber numberWithDouble:cos([topOperand doubleValue])];
                    } else if ([operation isEqualToString:@"sqrt"]) {
                        if ([topOperand compare:[NSNumber numberWithInt:0]] >= 0) {
                            result = [NSNumber numberWithDouble:sqrt([topOperand doubleValue])];
                        } else {
                            result = @"Can't get square root of negative number.";
                        }
                    } else if ([operation isEqualToString:@"+/-"]) {
                        result = [NSNumber numberWithDouble:-[topOperand doubleValue]];
                    }
                } else if ([twoOperandOperations containsObject:operation]) {
                    id secondTopOperand = [self popOperandOffProgramStack:stack];
                    if ([secondTopOperand isKindOfClass:[NSString class]]) {
                        result = secondTopOperand;
                    } else if ([secondTopOperand isKindOfClass:[NSNumber class]]) {
                        if ([operation isEqualToString:@"+"]) {
                            result = [NSNumber numberWithDouble:[secondTopOperand doubleValue] + [topOperand doubleValue]];
                        } else if ([operation isEqualToString:@"*"]) {
                            result = [NSNumber numberWithDouble:[secondTopOperand doubleValue] * [topOperand doubleValue]];
                        } else if ([operation isEqualToString:@"-"]) {
                            result = [NSNumber numberWithDouble:[secondTopOperand doubleValue] - [topOperand doubleValue]];
                        } else if ([operation isEqualToString:@"/"]) {
                            if ([topOperand isEqualToNumber:[NSNumber numberWithInt:0]]) {
                                result = @"Can't divide by zero";
                            } else {
                                result = [NSNumber numberWithDouble:[secondTopOperand doubleValue] / [topOperand doubleValue]];
                            }
                        }
                    } else {
                        result = @"Need second operand.";
                    }
                }
            }
        }
    }
    
    return result;
}

/* provides an instance of CalculatorBrain and runs the given program against it */
+ (id)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

/* provides an instance of CalculatorBrain and runs the given program with variables against it */
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) {
            id topOfStack = [stack objectAtIndex:i];
            if ([self isVariable:topOfStack]) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [stack replaceObjectAtIndex:i withObject:[formatter numberFromString:[variableValues objectForKey:topOfStack]]];
            }
        }
    }
    return [self runProgram:stack];
}

/* go through the program array and look for any variables */
+ (NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *foundVariables = [[NSMutableSet alloc] init]; 
    if ([program isKindOfClass:[NSArray class]]) {
        for (id programElement in program) {
            if ([self isVariable:programElement]) {
                [foundVariables addObject:programElement];
            }
        }
    }
    if ([foundVariables count]) {
        return [foundVariables copy]; 
    }
    return nil;
}

/* simply remove the last object from the stack */
-(void)undo {
    [self.programStack removeLastObject];
}

/* clear the memory for all of the calculator */
-(void) clearCalculator {
    [self.programStack removeAllObjects];
}


@end
