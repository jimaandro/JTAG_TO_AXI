
int main()
{
long int SIZE = 2;

long int arr1[SIZE][SIZE] = {
	{ 1, 2 },
	{ 3, 4 }
};

long int arr2[SIZE][SIZE] = {
	{ 2, 0 },
	{ 0, 2 }
};
 long int result[SIZE][SIZE] = {
	{ 0, 0 },
	{ 0, 0 }
};

  long int i, j, k;  
 for (i = 0; i < SIZE; i++) {
        for (j = 0; j < SIZE; j++) {
              for (k = 0; k < SIZE; k++) {
                result[i][j] += arr1[i][k] * arr2[k][j];
            
        }
    }
 }

    while(1)
    {

    }
    return 0;
}
