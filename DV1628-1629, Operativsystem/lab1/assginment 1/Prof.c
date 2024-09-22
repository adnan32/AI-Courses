//Abdulkarim Dawalibi and Adnan Altukleh
#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include<semaphore.h>
#include <sys/types.h>
#include <unistd.h>

#define min_sleep 2
#define mean_sleep 5
#define max_sleep 8
#define maxs_sleep 10
pthread_t philosopher[5];
pthread_mutex_t chopstick[5];

unsigned int RandomBetween(unsigned int smallNumber, unsigned int bigNumber) //return a random number
    {
        unsigned int diff = bigNumber - smallNumber;
        return (((unsigned int) rand() / RAND_MAX) * diff) + smallNumber;
    } 
int is_odd(int arg) //check if the proffesor's number is odd or even
{
    return arg%2;
}


void *func(void* l)
{
    int n = (unsigned long)l; 
    printf("\nPhilosopher %d is thinking ",n);
    sleep(RandomBetween(min_sleep,mean_sleep));
    if (is_odd(n)){
        sleep(15);
    }
    
    
    pthread_mutex_lock(&chopstick[n]);

    printf("\nPhilosopher %d took the left fork number : %d ",n, n);
    printf("\nPhilosopher %d is thinking ",n);
    sleep(RandomBetween(min_sleep,max_sleep));

    pthread_mutex_lock(&chopstick[(n-1 == 0)? 5: n-1]);

    printf("\nPhilosopher %d took the right fork number : %d ",n, (n-1 == 0)? 5: n-1);

    printf("\nPhilosopher %d is eating ",n);
    sleep(RandomBetween(mean_sleep,maxs_sleep));
    
    pthread_mutex_unlock(&chopstick[n]);

    pthread_mutex_unlock(&chopstick[(n-1 == 0)? 5: n-1]);

    printf("\nPhilosopher %d Finished eating",n);
} 






int main()
{
    unsigned long i,k;
    void *msg;
    for(i=1;i<=5;i++)
    {
        k=pthread_mutex_init(&chopstick[i],NULL); //initialize the mutex
        if(k==-1)
            {
            printf("\n Mutex initialization failed");
            exit(1);
            }
    }
    for(i=1;i<=5;i++)
    {
        k=pthread_create(&philosopher[i],NULL,(void *)func,(void*)i);  //creating threads
        if(k!=0)
        {
            printf("\n Thread creation error \n");
            exit(1);
        }
    }
    for(i=1;i<=5;i++)
    {
        k=pthread_join(philosopher[i],&msg); //joining the therads wait for termination until all threads are done
        if(k!=0)
        {
            printf("\n Thread join failed \n");
            exit(1);
        }
    }
    for(i=1;i<=5;i++)
    {
        k=pthread_mutex_destroy(&chopstick[i]); //desttroy the mutex
        if(k!=0)
        {
            printf("\n Mutex Destroyed \n");
            exit(1);
        }
    }
    return 0;
}

