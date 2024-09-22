//Abdulkarim Dawalibi and Adnan Altukleh
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define SIZE 1024
pthread_t thread[SIZE];
pthread_t thread_init[SIZE];
static double a[SIZE][SIZE];
static double b[SIZE][SIZE];
static double c[SIZE][SIZE];

static void*
init_matrix(void* arg)
{
    unsigned long i = (unsigned long) arg;

    for (unsigned long j = 0; j < SIZE; j++) {
        /* Simple initialization, which enables us to easy check
            * the correct answer. Each element in c will have the same
            * value as SIZE after the matmul operation.
            */
        a[i][j] = 1.0;
        b[i][j] = 1.0;
    }
}
static void*
matmul_seq(int row) // multiplying ecah row 
{
    unsigned long i = (unsigned long) row;
    unsigned long j, k;

    
    for (j = 0; j < SIZE; j++) {        
        c[i][j] = 0.0;
        for (k = 0; k < SIZE; k++){
            c[i][j] = c[i][j] + a[i][k] * b[k][i];
        }
    }
    
}

static void
print_matrix(void)
{
    int i, j;

    for (i = 0; i < SIZE; i++) {
        for (j = 0; j < SIZE; j++)
	        printf(" %7.2f", c[i][j]);
	    printf("\n");
    }
}

int main(int argc, char **argv)
{
    int k;

    for (unsigned long i = 0; i<SIZE; i++)
    {
        k=pthread_create(&thread_init[i],NULL,(void *)init_matrix,(void*)i); //creating treads to create the matrix
        if(k!=0)
        {
            printf("\n Thread creation error \n");
            exit(1);
        }
    }
    for(unsigned long i=0;i<SIZE;i++)
    {
        k=pthread_join(thread_init[i],NULL);
    }
    
    for (unsigned long i = 0; i<SIZE; i++)
    {
        k=pthread_create(&thread[i],NULL,(void *)matmul_seq,(int*)i); //creating threads to multiply the matrix
        if(k!=0)
        {
            printf("\n Thread creation error \n");
            exit(1);
        }
    }
    for(unsigned long i=0;i<SIZE;i++)
    {
        k=pthread_join(thread[i],NULL);
    }
    //print_matrix();
}

        