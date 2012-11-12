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
    
    if(self.userIsInTheMiddleOfPressingEnter) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)enterPressed {
    if(self.display.text)
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfPressingEnter = NO;
}

- (IBAction)clearPressed {
    self.display.text = @"";
}

@end
