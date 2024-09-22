//Abdulkarim Dawalibi and Adnan Altukleh
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#define num_thre 4
struct threadArgs {
	unsigned int id;
	unsigned int numThreads;
	unsigned int squareId;
};

void* child(void* params) {
	struct threadArgs *args = (struct threadArgs*) params;
	unsigned int childID = args->id;
	unsigned int numThreads = args->numThreads;
	args->squareId = args->id * args->id;
	printf("Greetings from child #%u of %u\n", childID, numThreads);
	return (void*)args;
	
}

int main(int argc, char** argv) {
	int* sq;
	pthread_t* children; // dynamic array of child threads
	struct threadArgs* args; // argument buffer
	unsigned int numThreads = num_thre;
	// get desired # of threads
	if (argc > 1)
		numThreads = atoi(argv[1]);
	children = malloc(numThreads * sizeof(pthread_t)); // allocate array of handles
	args = malloc(numThreads * sizeof(struct threadArgs)); // args vector
	for (unsigned int id = 0; id < numThreads; id++) {
		// create threads
		args[id].id = id;
		args[id].numThreads = numThreads;
		pthread_create(&(children[id]), // our handle for the child
			NULL, // attributes of the child
			child, // the function it should run
			(void*)&args[id]); // args to that function
	}
	printf("I am the parent (main) thread.\n");
	for (unsigned int id = 0; id < numThreads; id++) {
		pthread_join(children[id], (void**)&sq);
		struct threadArgs *mm = (struct threadArgs*) sq;
		printf("squaredId: %d of child %d\n", mm->squareId, mm->id);
	}
	free(args); // deallocate args vector
	free(children); // deallocate array
	return 0;
}
