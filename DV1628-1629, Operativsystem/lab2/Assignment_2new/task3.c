#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define traces 100000
#define True 1
#define False 0

int main(int argc, char *argv[])
{
    if (argc == 4)
    {
        int page_fault= 0;
        int indx = 0;
        int found = True;
        int phys_pages = atoi(argv[1]); 
        int arr[phys_pages];
        memset(arr, -1,sizeof(int)*phys_pages);
        int page_size = atoi(argv[2]);
        char filename[sizeof(argv[3])];
        strcpy(filename, argv[3]);
        printf("No physical pages = %d, page size = %d\n", phys_pages, page_size);
        FILE *fptr;
        fptr = fopen(filename, "r");
        if (fptr == NULL)
        {
            printf("File error");
            return 0;
        }
        printf("Reading memory trace from %s... Read 100000 memory references\n",argv[3]);
        int reference;
        int counter = 0;
        for (int i= 0; i<traces; i++)
        {
            indx = 0;
            fscanf(fptr, "%d",&reference);
            reference = reference/ page_size; 
            while(indx < phys_pages) 
            {
                
                if (arr[indx] == reference)
                {
                    found = True; 
                    counter += 1;
                    indx+= phys_pages;
                    
                }
                else
                {
                    
                    found = False;
                    
                }
                indx += 1;
            }

            if (!found)
            {
                page_fault += 1;
                memmove(arr,arr+1, sizeof(int)*(phys_pages-1));
                arr[phys_pages-1]= reference;
            }
        }
        
        printf("Result: %d page faults\n", page_fault);
        // printf("counter:%d\n", counter);
        
        fclose(fptr);
    } 
    else
    {
        printf("Too many parameters or some parameter is missed!!");
    }
    
    return 0;
}