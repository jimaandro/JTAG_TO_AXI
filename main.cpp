
int main()
{
    long int a=1;
    long int b=1;
    long int c=0;
    for ( long int i=0; i<3; i++)
    {
        c=a+ a*b/a;
        a=c;
        b=c;
    }
    while(1)
    {

    }
    return 0;
}
