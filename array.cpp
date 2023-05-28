
int main()
{
long int SIZE = 4;

long int arr1[SIZE][SIZE] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12},
        {13, 14, 15, 16}
    };

 long int arr2[SIZE][SIZE] = {
        {0, 0, 0, 1},
        {0, 0, 1, 0},
        {0, 1, 0, 0},
        {1, 0, 0, 0}
    };

 long int result[SIZE][SIZE];
    
 for (long int i = 0; i < SIZE; i++) {
        for (long int j = 0; j < SIZE; j++) {
            result[i][j] = 0;
            for (long int k = 0; k < SIZE; k++) {
                result[i][j] += arr1[i][k] * arr2[k][j];
            }
        }
    }


    while(1)
    {

    }
    return 0;
}
