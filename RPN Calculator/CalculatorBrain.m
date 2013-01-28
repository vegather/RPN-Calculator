//
//  CalculatorBrain.m
//  RPN Calculator
//
//  Created by Vegard Solheim Thériault on 1/19/13.
//  Copyright (c) 2013 Vegard Solheim Thériault. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

//Hope this works
//Hope this works as well
//This will hopefully push to server
//Try to push to server

@implementation CalculatorBrain
@synthesize programStack = _programStack;

#pragma mark - Instantiation

- (NSMutableArray *)programStack
{
    //Lazily instatiates the programStack
    if (_programStack == nil)
    {
        _programStack = [[NSMutableArray alloc]init];
    }
    return _programStack;
}

- (id)program
{
    //Getter for the program, which is simply the programStack (NSMutableArray *)
    return [self.programStack copy];
}

#pragma mark - Instance Methods

- (void)pushOperand:(double)operand
{
    //Pushes an operand to the programStack as an object of type NSNumber
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    //Pushes a variable to the programStack as an object of type NSString
    [self.programStack addObject:variable];
}

- (void)pushOperation:(NSString *)operation
{
    //Adds the operation to the programStack
    [self.programStack addObject:operation];
}

- (void)clearStack
{
    //Simply removes everything on the programStack
    [self.programStack removeAllObjects];
}

- (void)removeLastInput
{
    [self.programStack removeLastObject];
}

- (NSString *)description
{
    //Returns whatever is currently on the programStack
    return [NSString stringWithFormat:@"Stack = %@", self.programStack];
}

#pragma mark - Class Methods

+ (id)runProgram:(id)program
{
    //Runs the program with a nil dictionary. If no variables are entered, the program will
    //run normally. However, if variables are entered, but not defined in the dicionary,
    //they will be set to 0.
    return [self runProgram:program usingVariableValue:nil];
}

+ (id)runProgram:(id)program usingVariableValue:(NSDictionary *)variableValues
{
    //A mutable array to copy the program to. If the program is not an array, the stack will
    //be nil and "runProgram:usingVariableValues" will return nil.
    NSMutableArray *stack;
    //Checks if program is array with introspection
    if ([program isKindOfClass:[NSArray class]])
    {
        //Stores a mutable copy of the program to the stack. The copying is done, so that we
        //don't start passing around the actual program, but a copy of it. Besides, the
        //"popOperandOffStack" needs a mutable array to be able to chew through it.
        stack = [program mutableCopy];
        
        //Loops though each object of the program
        for (int i = 0; i < [stack count]; i++)
        {
            id obj = stack[i];
            //If the object IS a string and IS NOT an operation, it is most likely a variable.
            if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj])
            {
                //Guessing the object in the dictionary corresponding to key (value of the
                //variable) is a NSNumber. Store the object as id
                id value = [variableValues objectForKey:obj];
                
                //If it is not an NSNumber, set it to an NSNumber with the double value 0
                //When we call "program:" with the dictionary set to nil, every variable
                //will be set to 0, because they are not defined in a dictionary.
                if (![value isKindOfClass:[NSNumber class]])
                {
                    value = [NSNumber numberWithDouble:0];
                }
                //Replace the variable with its value
                [stack replaceObjectAtIndex:i withObject:value];
            }
        }
    }
    
    //Returns the result of all the calculations made including the varibles if present.
    return [self popOperandOffStack:stack];
}

+ (id)popOperandOffStack:(NSMutableArray *)stack
{
    //Sets result to 0 in case nothing works
    NSNumber *result = 0;
    
    NSString *errorMessage = @"";
    
    //Gets the last object on the stack
    id topOfStack = [stack lastObject];
    //If the last object is not nil, remove it
    if (topOfStack)
    {
        [stack removeLastObject];
    }
    
    //If the last object on the stack is a number, simply add it to the result
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = topOfStack;
    }
    
    //If the last object on the stack is a string, do the necessary calculations and
    //add the result to "result"
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"])
        {
            id first = [self popOperandOffStack:stack];
            id second = [self popOperandOffStack:stack];
            if (first && second)
            {
                double sum = [first doubleValue] + [second doubleValue];
                result = [NSNumber numberWithDouble:sum];
            }
            else
            {
                errorMessage = @"You need at least two operands before you can do this operation";
            }
            
        }
        else if ([operation isEqualToString:@"-"])
        {
            id second = [self popOperandOffStack:stack];
            id first = [self popOperandOffStack:stack];
            if (second && first)
            {
                double subtractionResult = [first doubleValue] - [second doubleValue];
                result = [NSNumber numberWithDouble:subtractionResult];
            }
            else
            {
                errorMessage = @"You need at least two operands before you can do this operation";
            }
        }
        else if ([operation isEqualToString:@"*"])
        {
            id first = [self popOperandOffStack:stack];
            id second = [self popOperandOffStack:stack];
            if (first && second)
            {
                double product = [first doubleValue] * [second doubleValue];
                result = [NSNumber numberWithDouble:product];
            }
            else
            {
                errorMessage = @"You need at least two operands before you can do this operation";
            }
            
        }
        else if ([operation isEqualToString:@"/"])
        {
            
            id devider = [self popOperandOffStack:stack];
            id upperNumber = [self popOperandOffStack:stack];
            if (devider && upperNumber)
            {
                if (devider != 0)
                {
                    double divisionResult = [upperNumber doubleValue] / [devider doubleValue];
                    result = [NSNumber numberWithDouble:divisionResult];
                }
                else
                {
                    errorMessage = @"You cannot devide by 0";
                }
            }
            else
            {
                errorMessage = @"You need at least two operands before you can do this operation";
            }
            
        }
        else if ([operation isEqualToString:@"sin"])
        {
            id number = [self popOperandOffStack:stack];
            if (number)
            {
                result = [NSNumber numberWithDouble:sin([number doubleValue])];
            }
            else
            {
                errorMessage = @"You need at least one operand before you can do this operation";
            }
            
        }
        else if ([operation isEqualToString:@"cos"])
        {
            id number = [self popOperandOffStack:stack];
            if (number)
            {
                result = [NSNumber numberWithDouble:cos([number doubleValue])];
            }
            else
            {
                errorMessage = @"You need at least one operand before you can do this operation";
            }
        }
        else if ([operation isEqualToString:@"sqrt"])
        {
            id rootNumber = [self popOperandOffStack:stack];
            if (rootNumber)
            {
                if ([rootNumber doubleValue] >= 0)
                {
                    result = [NSNumber numberWithDouble:sqrt([rootNumber doubleValue])];
                }
                else
                {
                    errorMessage = @"You cannot square a number below 0";
                }
            }
            else
            {
                errorMessage = @"You need at least one operand before you can do this operation";
            }
            
        }
        else if ([operation isEqualToString:@"π"])
        {
            result = [NSNumber numberWithDouble:M_PI];
        }
    }
    if (![errorMessage isEqualToString:@""])
    {
        return errorMessage;
    }
    else
    {
        return result;
    }
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *componentsArray = [NSMutableArray array];
    if ([program isKindOfClass:[NSArray class]])
    {
        NSMutableArray *stack = [program mutableCopy];
        while ([stack count] != 0)
        {
            NSString *component = [self descriptionOfTopOfStack:stack];
            [componentsArray addObject:component];
        }
    }
    return [componentsArray componentsJoinedByString:@", "];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    //Sets result to nil in case nothing works
    NSString *result;
    
    //Gets the last object on the stack
    id topOfStack = [stack lastObject];
    //If the last object is not nil, remove it
    if (topOfStack)
    {
        [stack removeLastObject];
    }
    
    //If the last object is a number, simply return it.
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [NSString stringWithFormat:@"%g", [topOfStack doubleValue]];
    }
    //If the last object is an operation or variable
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        if ([self operandsUsedByOperation:topOfStack] == 0)
        {
            result = topOfStack;
        }
        else if ([self operandsUsedByOperation:topOfStack] == 1)
        {
            NSString *operand = [self descriptionOfTopOfStack:stack];
            result = [NSString stringWithFormat:@"%@(%@)", topOfStack, operand];
        }
        else if ([self operandsUsedByOperation:topOfStack] == 2)
        {
            NSString *lastComponent = [self descriptionOfTopOfStack:stack];
            NSString *firstComponent = [self descriptionOfTopOfStack:stack];
            //If the operation is a * or /, OR there is nothing left on the stack. Don't want extranous parantheses
            //around the entire thing.
            if ([topOfStack isEqualToString:@"*"] || [topOfStack isEqualToString:@"/"] || [stack count] == 0)
            {
                //If fistcomponent contains a + or -, I want a parantheses around that
                //###############THIS CREATES EXTRANOUS PARENTHESES#################
                //Think the solution is to find out what the latest operation was, and operate accordingly
                if ([firstComponent rangeOfString:@"+"].location != NSNotFound ||
                    [firstComponent rangeOfString:@"-"].location != NSNotFound)
                {
                    result = [NSString stringWithFormat:@"(%@) %@ %@", firstComponent, topOfStack, lastComponent];
                }
                else
                {
                    result = [NSString stringWithFormat:@"%@ %@ %@", firstComponent, topOfStack, lastComponent];
                }
            }
            else
            {
                result = [NSString stringWithFormat:@"(%@ %@ %@)", firstComponent, topOfStack, lastComponent];
            }
        }
    }
    
    return result;
}

+ (int)operandsUsedByOperation:(NSString *)operation
{
    NSSet *oneOperandOperations = [NSSet setWithObjects:@"sin", @"cos", @"sqrt",nil];
    NSSet *twoOperandOperations = [NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
    
    if ([oneOperandOperations containsObject:operation]) return 1;
    else if ([twoOperandOperations containsObject:operation]) return 2;
    else return 0;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    //A set containing all the variables used in the given program
    NSMutableSet *variablesUsed;
    
    //Makes sure the program is actually an array with introspection
    if ([program isKindOfClass:[NSArray class]])
    {
        //A copy of the program as an array
        NSArray *stack = [program copy];
        //Sets the set variablesUsed as an empty set so we can start adding to it.
        variablesUsed = [NSMutableSet set];
        
        //Loops though every object of the program
        for (id obj in stack)
        {
            //If the object IS a string, but IS NOT an operation, it must be a variable
            if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj])
            {
                //...so add it to the set of variablesUsed.
                [variablesUsed addObject:obj];
            }
        }
        
        //If there was no variables however, set the NSMutableSet to nil so that we return nil
        //instead of an empty set.
        if ([variablesUsed count] == 0)
        {
            variablesUsed = nil;
        }
    }
    //return a copy og the set variablesUsed so we don1t pass around the actual set
    return [variablesUsed copy];
}

+ (BOOL)isOperation:(NSString *)operation
{
    //A set containing all the valid calculations
    NSSet *validOperations = [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"sin",
                              @"cos", @"sqrt", nil];
    //Checks if the the set contains the given operation, and if it does, return YES.
    if ([validOperations containsObject:operation]) return YES;
    //If not, then return NO.
    else return NO;
}



@end
