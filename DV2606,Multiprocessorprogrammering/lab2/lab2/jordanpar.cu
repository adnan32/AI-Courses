//Task 3 -Gaussjordan using CUDA Adnan Altukleh & Abdulkarim Dawalibi

#include <stdio.h>

#define MAX_SIZE 2048
#define NUM_THREADS 1024
#define PRNT 0
typedef double matrix[MAX_SIZE][MAX_SIZE];

int	N;		/* matrix size		*/
int	maxnum;		/* max number of element*/
char* Init;		/* matrix init type	*/
int	PRINT;		/* print switch		*/
matrix	A;		/* matrix A		*/
double	b[MAX_SIZE];	/* vector b             */
double	y[MAX_SIZE];	/* vector y             */

/* forward declarations */
void work(void);
__global__ void device_elimination1(double *deviceA,int N, double *b, double *y, int k);
__global__ void device_elimination2(double *deviceA,int N, double *y, int k);
__global__ void device_division(double *deviceA,int N, int k, double *y, double *b);
__global__ void add_device_elimination1(double *deviceA,int N, double *b, double *y,int k);
__global__ void add_device_elimination2(double *deviceA,int N, double *b, double *y,int k);
void Init_Matrix(void);
void Print_Matrix(void);
void Init_Default(void);
int Read_Options(int, char**);

int
main(int argc, char** argv)
{

    // int i, timestart, timeend, iter;
    
    Init_Default();		/* Init default values	*/
    Read_Options(argc, argv);	/* Read arguments	*/
    Init_Matrix();		/* Init the matrix	*/
    work();
    

    if (PRINT == 1)
        Print_Matrix();
}
//reach each row by index xN

__global__ void device_division(double *deviceA, int N, int k, double *y, double *b){


    for (int j = k + 1; j < N; j++){
            
        deviceA[(k*N)+j] = deviceA[(k*N)+j] / deviceA[(k*N)+k]; /* Division step */
            
    }
    y[k] = b[k] / deviceA[(k*N)+k];
    deviceA[(k*N)+k] = 1.0;

}



__global__ void device_elimination2(double *deviceA, int N, double *y, int k) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    // Ensure we don't go past the end of the matrix
    if (i < k) { // Ensuring that we don't modify the pivot row
        for (int j = k + 1; j < N; j++) {
            deviceA[i * N + j] -= deviceA[i * N + k] * deviceA[k * N + j];
        }
    }

}





__global__ void device_elimination1(double *deviceA,int N, double *b, double *y,int k)
{
    int thread_id = blockIdx.x*blockDim.x +threadIdx.x;
    int rows_per_thread = N / NUM_THREADS;
    int i, j;
    int start = thread_id * rows_per_thread; 
    int end = start + rows_per_thread; 

        for (i = start; i < end; i++) {
            
            if (i > k) {
            for (j = k + 1; j < N; j++){
                //((1= row number)* (N means jump one row)) + element index in the row
                deviceA[(i*N)+j] = deviceA[(i*N)+j] - deviceA[(i*N)+k] * deviceA[(k*N)+j];
            }
            }
        }

}

__global__ void add_device_elimination1(double *deviceA,int N, double *b, double *y,int k){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i > k) {
        b[i] = b[i] - deviceA[(i*N)+k] * y[k];
        deviceA[(i*N)+k] = 0.0;
    }
}

__global__ void add_device_elimination2(double *deviceA,int N, double *b, double *y,int k){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < k) {
        y[i] -= deviceA[i * N + k] * y[k];
        deviceA[i * N + k] = 0.0;
    }
}

void work(void)
{
    int  k;
    
    /* Gaussian elimination algorithm, Algo 8.4 from Grama */
    double *deviceA;
    double *deviceY;
    double *deviceB;

    cudaMalloc(&deviceB,sizeof(double)*MAX_SIZE);
    cudaMalloc(&deviceY,sizeof(double)*MAX_SIZE);
    cudaMalloc(&deviceA,sizeof(matrix));

    cudaMemcpy(deviceA,A,sizeof(matrix), cudaMemcpyHostToDevice);
    cudaMemcpy(deviceY,y,sizeof(double)*MAX_SIZE, cudaMemcpyHostToDevice);
    cudaMemcpy(deviceB,b,sizeof(double)*MAX_SIZE, cudaMemcpyHostToDevice);

    for (k = 0; k < N; k++) { /* Outer loop */   
        
        device_division<<<1,1>>>(deviceA,N,k,deviceY,deviceB);
        
        device_elimination1<<<128, NUM_THREADS>>>(deviceA,N,deviceB,deviceY,k);
        cudaDeviceSynchronize();
        add_device_elimination1<<<2, NUM_THREADS>>>(deviceA,N,deviceB,deviceY,k);
        
        if(k>0){
            device_elimination2<<<2,NUM_THREADS>>>(deviceA,N,deviceY,k);
            cudaDeviceSynchronize();
            add_device_elimination2<<<2,NUM_THREADS>>>(deviceA,N,deviceB,deviceY,k);
        }
        
    }
    
    cudaMemcpy(A,deviceA,sizeof(matrix), cudaMemcpyDeviceToHost);
    cudaMemcpy(y,deviceY,sizeof(double)*MAX_SIZE, cudaMemcpyDeviceToHost);
    cudaFree(deviceA);
    cudaFree(deviceB);
    cudaFree(deviceY);

}

void
Init_Matrix()
{
    int i, j;

    printf("\nsize      = %dx%d ", N, N);
    printf("\nmaxnum    = %d \n", maxnum);
    printf("Init	  = %s \n", Init);
    printf("Initializing matrix...");

    if (strcmp(Init, "rand") == 0) {
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                if (i == j) /* diagonal dominance */
                    A[i][j] = (double)(rand() % maxnum) + 5.0;
                else
                    A[i][j] = (double)(rand() % maxnum) + 1.0;
            }
        }
    }
    if (strcmp(Init, "fast") == 0) {
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                if (i == j) /* diagonal dominance */
                    A[i][j] = 5.0;
                else
                    A[i][j] = 2.0;
            }
        }
    }

    /* Initialize vectors b and y */
    for (i = 0; i < N; i++) {
        b[i] = 2.0;
        y[i] = 1.0;
    }

    printf("done \n\n");
    if (PRINT == 1)
        Print_Matrix();
}

void
Print_Matrix()
{
    int i, j;

    printf("Matrix A:\n");
    for (i = 0; i < N; i++) {
        printf("[");
        for (j = 0; j < N; j++)
            printf(" %5.2f,", A[i][j]);
        printf("]\n");
    }
    printf("Vector y:\n[");
    for (j = 0; j < N; j++)
        printf(" %5.2f,", y[j]);
    printf("]\n");
    printf("\n\n");
}

void
Init_Default()
{
    N = MAX_SIZE;
    Init = "fast";
    maxnum = 15.0;
    PRINT = PRNT;
}

int
Read_Options(int argc, char** argv)
{
    char* prog;

    prog = *argv;
    while (++argv, --argc > 0)
        if (**argv == '-')
            switch (*++ * argv) {
            case 'n':
                --argc;
                N = atoi(*++argv);
                break;
            case 'h':
                printf("\nHELP: try sor -u \n\n");
                exit(0);
                break;
            case 'u':
                printf("\nUsage: gaussian [-n problemsize]\n");
                printf("           [-D] show default values \n");
                printf("           [-h] help \n");
                printf("           [-I init_type] fast/rand \n");
                printf("           [-m maxnum] max random no \n");
                printf("           [-P print_switch] 0/1 \n");
                exit(0);
                break;
            case 'D':
                printf("\nDefault:  n         = %d ", N);
                printf("\n          Init      = rand");
                printf("\n          maxnum    = 5 ");
                printf("\n          P         = 0 \n\n");
                exit(0);
                break;
            case 'I':
                --argc;
                Init = *++argv;
                break;
            case 'm':
                --argc;
                maxnum = atoi(*++argv);
                break;
            case 'P':
                --argc;
                PRINT = atoi(*++argv);
                break;
            default:
                printf("%s: ignored option: -%s\n", prog, *argv);
                printf("HELP: try %s -u \n\n", prog);
                break;
            }
}