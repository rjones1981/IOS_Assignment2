//
//  CalculatorViewController.m
//  RPNCalculator
//
//  Created by Rabun Jones on 11/3/12.
//  Copyright (c) 2012 edu.standford.cs193p.rjones. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic, strong) CalculatorBrain *brain;
@property BOOL userIsInTheMiddleOfPressingEnter;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize brain = _brain;
@synthesize userIsInTheMiddleOfPressingEnter;

- (CalculatorBrain *)brain {
    if(!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    if(userIsInTheMiddleOfPressingEnter) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfPressingEnter = YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender {
    
    
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)clearPressed {
    self.display.text = @"";
}

- (IBAction)enterPressed {
    if(self.display.text)
        //[self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfPressingEnter = NO;
}

- (IBAction)setVariableWithOperandPressed:(UIButton *)sender {
    [self.brain setVariableAsOperand:sender.currentTitle];
}

- (IBAction)solvePressed {
    
    /* take expression on calculator and eval it using various values */
    NSString *expression = self.display.text;
    
    /* dictionary contains NSNumber value and NSString key */
    NSMutableDictionary *testVars = [[NSMutableDictionary alloc] init];
    [testVars setValue:[NSNumber numberWithDouble:[@"2" doubleValue]] forKey:@"x"];
    [testVars setValue:[NSNumber numberWithDouble:[@"4" doubleValue]] forKey:@"a"];
    [testVars setValue:[NSNumber numberWithDouble:[@"6" doubleValue]]forKey:@"b"];
    
    /* eval the expression using the brain and set the text */
    double result = [CalculatorBrain evaluateExpression:expression usingVariableValues:testVars];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    
}

@end
