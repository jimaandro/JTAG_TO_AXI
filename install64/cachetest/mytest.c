extern int printf(const char *format, ...);

#define SIZE 2

int main()
{


int arr1[SIZE][SIZE] = {
	{ 1, 2 },
	{ 3, 4 }
};

int arr2[SIZE][SIZE] = {
	{ 2, 0 },
	{ 0, 2 }
};
 int result[SIZE][SIZE] = {
	{ 0, 0 },
	{ 0, 0 }
};

 int i, j, k;  
 for (i = 0; i < SIZE; i++) {
        for (j = 0; j < SIZE; j++) {
              for (k = 0; k < SIZE; k++) {
                result[i][j] += arr1[i][k] * arr2[k][j];
            
        }
    }
 }

    // Printing the 2x2 array
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("%d ", result[i][j]);
        }
        printf("\n");
    }

  return 0;
}
