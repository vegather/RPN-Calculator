//
//  RPNViewController.m
//  RPN Calculator
//
//  Created by Vegard Solheim Thériault on 1/19/13.
//  Copyright (c) 2013 Vegard Solheim Thériault. All rights reserved.
//

#import "RPNViewController.h"
#import "CalculatorBrain.h"

@interface RPNViewController ()
//Variables
@property (nonatomic) BOOL userIsInTheMiddleOfTypingANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

//Outlets
@property (weak, nonatomic) IBOutlet UILabel *testVariableValuesLabel;
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *enteredCalculations;
@end


@implementation RPNViewController
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

#pragma mark - Instatiation

- (CalculatorBrain *)brain
{
    //Lazily instantiate brain object
    if (_brain == nil)
    {
        _brain = [[CalculatorBrain alloc]init];
    }
    return _brain;
}

- (NSDictionary *)testVariableValues
{
    if (_testVariableValues == nil)
    {
        _testVariableValues = [[NSDictionary alloc]init];
    }
    return _testVariableValues;
}

#pragma mark - Main Buttons

- (IBAction)digitPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfTypingANumber)
    {
        //When user adds e point, check if there is one there already
        if ([sender.currentTitle isEqualToString:@"."])
        {
            //See if there is a "." there already
            if ([self.display.text rangeOfString:@"."].location == NSNotFound)
            {
                self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
            }
        }
        else
        {
            self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
        }
    }
    else
    {
        //If user starts with a point, add a zero before it
        if ([sender.currentTitle isEqualToString:@"."])
        {
            self.display.text = @"0.";
        }
        else
        {
            self.display.text = sender.currentTitle;
        }
        
        self.userIsInTheMiddleOfTypingANumber = YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    //Press enter if the user is typing, to save them the extra press
    if (self.userIsInTheMiddleOfTypingANumber)
    {
        [self enterPressed];
    }
    //Push the operation to the brain
    [self.brain pushOperation:sender.currentTitle];
    
    [self updateLabels];
}

- (IBAction)enterPressed
{
    //Push number to operand stack
    [self.brain pushOperand:[self.display.text doubleValue]];
    NSLog(@"programStack is: %@", self.brain.program);
    self.enteredCalculations.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    //User is no longer typing
    self.userIsInTheMiddleOfTypingANumber = NO;
}

#pragma mark - Other Buttons

- (IBAction)variablePressed:(UIButton *)sender
{
    [self.brain pushVariable:sender.currentTitle];
    self.enteredCalculations.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (IBAction)plusOrMinusPressed:(UIButton *)sender
{
    //If the Display's text number is not 0 and user is typing, multiply the number by -1
    if ((![self.display.text isEqualToString:@"0"]) && self.userIsInTheMiddleOfTypingANumber == YES)
    {
        double currentValue = [self.display.text doubleValue];
        double result = currentValue * -1;
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}

- (IBAction)clearPressed
{
    self.display.text = @"0";                       //Reset Display
    self.enteredCalculations.text = @"";            //Reset EnteredCalculations
    self.userIsInTheMiddleOfTypingANumber = NO;     //User is NOT in the middle of typing
    [self.brain clearStack];                        //Clear the Brain's stack
    self.testVariableValuesLabel.text = @"";
}

- (IBAction)undoPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfTypingANumber)
    {
        //If there is something in the display, remove the last char.
        //Otherwise set display to 0
        if (self.display.text.length > 1)
        {
            self.display.text = [self.display.text substringToIndex:(self.display.text.length - 1)];
        }
        else
        {
            self.display.text = @"0";
            self.userIsInTheMiddleOfTypingANumber = NO;
        }
    }
    else
    {
        [self.brain removeLastInput];
        [self updateLabels];
    }
}

- (IBAction)testAPressed:(UIButton *)sender
{
    self.testVariableValues = @{@"a" : [NSNumber numberWithInt:5],
                                @"b" : [NSNumber numberWithInt:3],
                                @"x" : [NSNumber numberWithInt:10]};
    
    [self updateLabels];
}

- (IBAction)testBPressed:(UIButton *)sender
{
    self.testVariableValues = @{@"a" : [NSNumber numberWithInt:0],
                                @"b" : [NSNumber numberWithInt:0],
                                @"x" : [NSNumber numberWithInt:0]};
    
    [self updateLabels];
}

- (IBAction)testCPressed:(UIButton *)sender
{
    self.testVariableValues = @{@"a" : [NSNumber numberWithInt:-5],
                                @"b" : [NSNumber numberWithInt:5],
                                @"x" : [NSNumber numberWithInt:0]};
    
    [self updateLabels];
}

- (IBAction)testNilPressed:(UIButton *)sender
{
    self.testVariableValues = nil;
    
    [self updateLabels];
}

#pragma mark - Helper Methods

- (void)updateLabels
{
    id outputOfProgram = [CalculatorBrain runProgram:self.brain.program usingVariableValue:self.testVariableValues];
    if ([outputOfProgram isKindOfClass:[NSNumber class]])
    {
        self.display.text = [NSString stringWithFormat:@"%g", [outputOfProgram doubleValue]];
        
        NSArray *variablesUsedInCurrentProgram = [[CalculatorBrain variablesUsedInProgram:self.brain.program] allObjects];
        self.testVariableValuesLabel.text = @"";
        for (int i = 0; variablesUsedInCurrentProgram.count > i; i++)
        {
            if ([variablesUsedInCurrentProgram[i] isKindOfClass:[NSString class]])
            {
                NSString *formatedVariable;
                if (i == variablesUsedInCurrentProgram.count - 1)
                {
                    NSString *variableName = [self.testVariableValues objectForKey:[variablesUsedInCurrentProgram objectAtIndex:i]];
                    formatedVariable = [NSString stringWithFormat:@"%@: %@", variablesUsedInCurrentProgram[i], variableName];
                }
                else
                {
                    NSString *variableName = [self.testVariableValues objectForKey:[variablesUsedInCurrentProgram objectAtIndex:i]];
                    formatedVariable = [NSString stringWithFormat:@"%@: %@, ", variablesUsedInCurrentProgram[i], variableName];
                }
                self.testVariableValuesLabel.text = [self.testVariableValuesLabel.text stringByAppendingString:formatedVariable];
            }
        }
        
        self.enteredCalculations.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    }
    else if ([outputOfProgram isKindOfClass:[NSString class]])
    {
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                            message:outputOfProgram
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [errorAlert show];
    }
    
    
}

@end
