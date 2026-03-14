extern int printf(const char *format, ...);

#include <stdio.h>

#define MAX_SIZE 10  // Maximum array size

void inputArray(int arr[MAX_SIZE][MAX_SIZE], int size) {
    printf("Enter the elements of the %dx%d array:\n", size, size);
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printf("Element [%d][%d]: ", i, j);
            scanf("%d", &arr[i][j]);
        }
    }
}

void addArrays(int arr1[MAX_SIZE][MAX_SIZE], int arr2[MAX_SIZE][MAX_SIZE], int result[MAX_SIZE][MAX_SIZE], int size) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            result[i][j] = arr1[i][j] + arr2[i][j];
        }
    }
}

void subtractArrays(int arr1[MAX_SIZE][MAX_SIZE], int arr2[MAX_SIZE][MAX_SIZE], int result[MAX_SIZE][MAX_SIZE], int size) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            result[i][j] = arr1[i][j] - arr2[i][j];
        }
    }
}

void multiplyArrays(int arr1[MAX_SIZE][MAX_SIZE], int arr2[MAX_SIZE][MAX_SIZE], int result[MAX_SIZE][MAX_SIZE], int size) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            result[i][j] = 0;  // Initialize each element to 0
            for (int k = 0; k < size; k++) {
                result[i][j] += arr1[i][k] * arr2[k][j];
            }
        }
    }
}

void printArray(int arr[MAX_SIZE][MAX_SIZE], int size) {
    printf("Resultant array:\n");
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printf("%d ", arr[i][j]);
        }
        printf("\n");
    }
}

int main() {
    int size;

    // Input the size of the array
    printf("Enter the size of the NxN array (max %d): ", MAX_SIZE);
    scanf("%d", &size);

    if (size <= 0 || size > MAX_SIZE) {
        printf("Invalid array size.\n");
        return 1;
    }

    int arr1[MAX_SIZE][MAX_SIZE], arr2[MAX_SIZE][MAX_SIZE], result[MAX_SIZE][MAX_SIZE];

    // Input the first array
    printf("\nEnter the first array:\n");
    inputArray(arr1, size);

    // Input the second array
    printf("\nEnter the second array:\n");
    inputArray(arr2, size);

    // Perform addition
    addArrays(arr1, arr2, result, size);
    printf("\nAddition:\n");
    printArray(result, size);

    // Perform subtraction
    subtractArrays(arr1, arr2, result, size);
    printf("\nSubtraction:\n");
    printArray(result, size);

    // Perform multiplication
    multiplyArrays(arr1, arr2, result, size);
    printf("\nMultiplication:\n");
    printArray(result, size);

    return 0;
}

