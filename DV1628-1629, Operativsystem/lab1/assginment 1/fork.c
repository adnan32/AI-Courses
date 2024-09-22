//Abdulkarim Dawalibi and Adnan Altukleh

#include <stdio.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>

int main(int argc, char **argv)
{

    pid_t pid_1;
    pid_1 = fork(); //creatring a child process
    unsigned i;
    unsigned niterations = 100;
    
    if (pid_1 == 0) // child process 
    {
        for (i = 0; i < niterations; ++i)
            printf("A = %d, ", i);          //prints letter A 100 times
    }

    else {
        pid_t pid_2;
        pid_2 = fork(); //creating another child in the parent process
        if (pid_2 == 0)  //child process
        {
        for (i = 0; i < niterations; ++i)
            printf("C = %d, ", i);  //prints letter C 100 times 
        }
        else //parent process
        {

        for (i = 0; i < niterations; ++i)
        {
            printf("B = %d, ", i);  //prints letter B 100  times 
        }
        printf("\nchild 1 id : %d", pid_1); //printing the children process ids in the parent process
        printf("\nchild 2 id : %d", pid_2);
        
        }
        
        
    }

    printf("\n");
    
    return 0;
}