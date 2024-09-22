//Abdulkarim Dawalibi and Adnan Altukleh
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <math.h>
#include <stdlib.h>
#define SHMSIZE 128
#define SHM_R 0400
#define SHM_W 0200
#define True 1
#define False 0
#define buffer_size 10


float RandomBetween(float smallNumber, float bigNumber)  // function that returns a random float number 
    {
        float diff = bigNumber - smallNumber;
        return (((float) rand() / RAND_MAX) * diff) + smallNumber;
    }

int main(int argc, char **argv)
{
		
	struct shm_struct { 
		int buffer[buffer_size];
		unsigned empty;
		unsigned int head;
		unsigned int tail;
		float slep;
	}; //Create a struct to store the buffer size and to indicate if the buffer is full or empty
	volatile struct shm_struct *shmp = NULL;  // Create a pointer to the struct
	char *addr = NULL; // create a char pointer
	pid_t pid = -1; // create a process id
	int var1 = 0, var2 = 0, shmid = -1;  //create two variables and another one with shared memory id
	struct shmid_ds *shm_buf; 

	/* allocate a chunk of shared memory */
	shmid = shmget(IPC_PRIVATE, SHMSIZE, IPC_CREAT | SHM_R | SHM_W); 
	shmp = (struct shm_struct *) shmat(shmid, addr, 0); 
	shmp->empty = False;
	shmp->head = 0;
	shmp->tail = 0;
	pid = fork();
	if (pid != 0) {
		/* here's the parent, acting as producer */
		while (var1 < 100) {
			/* write to shmem */
			var1++;                               
			while (shmp->empty == True);/* busy wait until the buffer is empty */
			
			shmp->buffer[shmp->head] = var1; //add value to the buffer
			printf("Sending %d\n",shmp->buffer[shmp->head]); fflush(stdout);
			shmp->slep = RandomBetween(0.1f,0.5f);
			sleep(shmp->slep);
			shmp->head = (shmp->head +1) % buffer_size;
			shmp->empty = True;
			
			

			
		}
		shmdt(addr);
		shmctl(shmid, IPC_RMID, shm_buf);
	} else {
		/* here's the child, acting as consumer */
		while (var2 < 100) {
			/* read from shmem */
			while (shmp->empty == False); /* busy wait until there is something */
			var2 = shmp->buffer[shmp->tail];
			printf("Received %d\n", shmp->buffer[shmp->tail]); fflush(stdout);
			shmp->slep = RandomBetween(0.2f,2.0f);
			sleep(shmp->slep);
			shmp->tail = (shmp->tail +1) % buffer_size;
			shmp->empty = False;
			

			
			

		}
		shmdt(addr); //dellocate the shared memory 
		shmctl(shmid, IPC_RMID, shm_buf);
	}
}

