//
//  CalculatorBrain.h
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

@property (nonatomic, readonly) id program;

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;

@end
