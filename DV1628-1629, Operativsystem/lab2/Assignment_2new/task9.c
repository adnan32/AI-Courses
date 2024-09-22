#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define traces 100000
#define True 1
#define False 0

int search(int element, FILE *file, int rows_left, int pagesize)
{
    int hit = True;
    int searched_rows = 0;
    int next_row = -1; 
    while ( hit && (rows_left != searched_rows))
    {
        fscanf(file, "%d",&next_row);
        searched_rows += 1;
        if (element <= next_row && next_row < element + pagesize)
        {
            hit = False;
        }
    }
    return searched_rows;
}

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
        int inter = 0;
        printf("Reading memory trace from %s... Read 100000 memory references\n",argv[3]);
        int reference;
        int counter = 0;
        for (int i= 0; i<traces; i++)
        {
            indx = 0;
            fscanf(fptr, "%d",&reference);
            counter += 1;
            reference = (reference/page_size);
            while(indx < phys_pages) 
            {  
                if (arr[indx] == reference) 
                {
                    found = True;
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
                if (page_fault >= phys_pages)   
                {
                    int max_interval = -1;
                    int wanted_indx = -1;
                    page_fault += 1;
                    int current_pos = ftell(fptr); 
                    for (int m = 0; m < phys_pages; m++)
                    {
                        int interval = search(arr[m], fptr, (traces - counter), page_size);
                        if (max_interval < interval)
                        {
                            max_interval = interval;
                            wanted_indx = m;
                        }
                        fseek(fptr, current_pos, SEEK_SET);
                    }
                    arr[wanted_indx]= reference;

                }
                else
                {
                    page_fault += 1;
                    memmove(arr,arr+1, sizeof(int)*(phys_pages-1));
                    arr[phys_pages-1]= reference;
                } 
            }
        }
        printf("Result: %d page faults\n", page_fault);
        fclose(fptr);
    }
    else
    {
        printf("Too many parameters or some parameter is missed!!");
    }
    return 0;
}