extern int printf(const char *format, ...);

#include <stdio.h>

int main() {
    double num1, num2;
    char operator;

    // Input two numbers and the operator
    printf("Enter first number: ");
    scanf("%lf", &num1);

    printf("Enter operator (+, -, *, /): ");
    scanf(" %c", &operator);  // Note: there's a space before %c to skip whitespace

    printf("Enter second number: ");
    scanf("%lf", &num2);

    // Perform the calculation based on the operator
    double result;
    switch (operator) {
        case '+':
            result = num1 + num2;
            break;
        case '-':
            result = num1 - num2;
            break;
        case '*':
            result = num1 * num2;
            break;
        case '/':
            // Check if dividing by zero
            if (num2 == 0) {
                printf("Error: Division by zero\n");
                return 1;  // Return non-zero to indicate an error
            }
            result = num1 / num2;
            break;
        default:
            printf("Error: Invalid operator\n");
            return 1;  // Return non-zero to indicate an error
    }

    // Print the result
    printf("Result: %lf\n", result);

    return 0;
}

