//
//  CalculatorBrain.h
//  RPN Calculator
//
//  Created by Vegard Solheim Thériault on 1/19/13.
//  Copyright (c) 2013 Vegard Solheim Thériault. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject


@property (readonly) id program;

- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)variable;
- (void)pushOperation:(NSString *)operation;
- (void)clearStack;
- (void)removeLastInput;

+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValue:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;


@end
