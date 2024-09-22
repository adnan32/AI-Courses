//Abdulkarim Dawalibi and Adnan Altukleh
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <math.h>

#define PERMS 0644
struct my_msgbuf {  //create the struct which will contain the values we send to the other processors
   long mtype;
   int mtext;
};

int main(void) {
   struct my_msgbuf buf;
   int msqid;
   int len;
   key_t key;

   system("touch msgq.txt");

   if ((key = ftok("msgq.txt", 'B')) == -1) {
      perror("ftok");
      exit(1);
   }

   if ((msqid = msgget(key, PERMS | IPC_CREAT)) == -1) {  //create a msg queue
      perror("msgget");
      exit(1);
   }
   printf("message queue: ready to send messages.\n");

   buf.mtype = 1; /* we don't really care in this case */
   sleep(5);

   for (int i = 0; i<50; i++)
   {
      buf.mtext = ((int) rand() % RAND_MAX);
      
      printf("sending: %d", buf.mtext);
      if (msgsnd(msqid, &buf, sizeof(buf.mtext), 0) == -1) //adding values to the queue
         {
         perror("msgsnd");
         }
      sleep(1);
      if (i == 49)
      {   
         if (msgctl(msqid, IPC_RMID, NULL) == -1) { // destroying the queue
         perror("msgctl");
         exit(1);
         }
      }
   }
   
   printf("message queue: done sending messages.\n");
   return 0;
}
