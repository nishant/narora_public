/* Nishant Arora
   UID: 114067067
   narora4
   CMSC 216 Project 6: A Simple Shell */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <err.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sysexits.h>
#include <fcntl.h>
#include "executor.h"
#include "command.h"

static void print_tree(struct tree *t);

int execute(struct tree *t) {
  int cd_check;

  /* empty tree */
  if(t == NULL) {
    return 0;
  }

  /* conjunction other than AND/PIPE */
  if(t->conjunction == NONE) {
    if (strcmp(t->argv[0], "exit") == 0) { /* exit */
      exit(0);

    } else if (strcmp(t->argv[0], "cd") == 0) { /* cd */
      if(t->argv[1] == NULL) { /* no specified dir */
        cd_check = chdir(getenv("HOME"));

       } else { /* specified dir */
         cd_check = chdir(t->argv[1]);
        }

        if(cd_check) { /* could not cd */
          printf("Failed to execute %s\n", t->argv[0]);
          fflush(stdout);
        }

      } else { /* proper execution */
        int input, output;
        pid_t child_pid;

        if((child_pid = fork()) < 0) { /* make child process; check for error */
          err(EX_OSERR, "fork error.");
        }

        if(child_pid == 0) { /* child */
          if (t->input != NULL) { /* input redirection */
            /* file open err check */
            if((input = open(t->input, O_RDONLY)) < 0) {
              err(EX_OSERR, "file opening error.");
            }
            if(dup2(input, STDIN_FILENO) < 0) { /* dup2 error check */
              err(EX_OSERR, "dup2 error.");
            }
            if(close(input) < 0) { /* file closing error check */
              err(EX_OSERR, "file closing error.");
            }

          } else if(t->output != NULL) { /* output redirection */
            /* file open err check */
            if(output = open(t->output, O_RDWR | O_CREAT | O_TRUNC, 0664) < 0) {
              err(EX_OSERR, "file opening error");
            }
            if(dup2(output, STDIN_FILENO) < 0) { /* dup2 error check */
              err(EX_OSERR, "dup2 error.");
            }
            if(close(output) < 0) { /* file closing error check */
              err(EX_OSERR, "file closing error.");
            }
          }

          execvp(t->argv[0], t->argv);
          /* error executing */
          printf("Failed to execute %s\n", t->argv[0]);
          exit(1);

        } else { /* parent */
          int status;
          wait(&status); /* wait on the child */
          return status;
        }
      }
    } else if(t->conjunction == AND) { /* conjunction is AND */
      if(t->input == NULL && t->output == NULL) {
        pid_t child_pid;

        if((child_pid = fork()) < 0) { /* make child process; check for error */
          err(EX_OSERR, "fork error.");
        }

        if(child_pid == 0) { /* child */
          if(execute(t->left) == 0) {
            if(execute(t->right) == 0) {
              exit(0);
            } else {
              exit(1);
            }
          } else {
            exit(1);
          }
        } else { /* parent */
          int status;
          wait(&status);
          return status;
        }
      }

      if(t->input != NULL) { /* input redirection */
        pid_t child_pid;

        if((child_pid = fork()) < 0) { /* make child process; check for error */
          err(EX_OSERR, "fork error.");
        }

        if(child_pid == 0) { /* child */
           int input;

           /* file opening err check */
           if((input = open(t->input, O_RDONLY)) < 0){
             err(EX_OSERR, "file opening error.");
           }
           if(dup2(input, STDIN_FILENO) < 0) { /* dup2 error check */
             err(EX_OSERR, "dup2 error.");
           }
           if(close(input) < 0) { /* file closing error check */
             err(EX_OSERR, "file closing error.");
           }

          if(execute(t->left) == 0) {
            if(execute(t->right) == 0) {
              exit(0);
            } else {
              exit(1);
            }
          } else {
            exit(1);
          }

        } else { /* parent */
          int status;
          wait(&status);
          return status;
        }

      } else if(t->output != NULL) { /* output redirection */
        int output;
        /* file opening err check */
        if((output = open(t->output, O_WRONLY)) < 0) {
          err(EX_OSERR, "file opening error.");
        }
        if (dup2(output, STDOUT_FILENO) < 0) {
          err(EX_OSERR, "dup2 error");
        }
        if (close(output) < 0) {
          err(EX_OSERR, "file closing error.");
        }

        pid_t child_pid;

        if((child_pid = fork()) < 0) { /* make child process */
          err(EX_OSERR, "fork error"); /* fork error check */
        }

        if(child_pid == 0) { /* child */
          if(execute(t->left) == 0) {
            if(execute(t->right) == 0) {
              exit(0);
            } else {
              exit(1);
            }
          } else {
            exit(1);
          }

        } else { /* parent */
          int status;
          wait(&status);
          return status;
        }
      }
      return 0;
    } else if (t->conjunction == PIPE) { /* conjunction is PIPE */
      int fd[2];
      pid_t child_pid;

      if((child_pid = fork()) == 0) { /* make child, if child */
        pid_t child_pipe;

        if(pipe(fd) < 0) { /* pipe error check */
          err(EX_OSERR,"pipe error.");
        }

        if((child_pipe = fork()) < 0) { /* make child process; check for err */
          err(EX_OSERR, "fork error.");
        }
        if(child_pipe == 0) { /* child */
          close(fd[0]); /* stop reading from pipe */ /**/

          if(dup2(fd[1], STDOUT_FILENO) < 0) {
            err(EX_OSERR, "dup2 error.");
          }

          if(execute(t->left) == 0) {
            exit(0);
          } else {
            exit(1);
          }
        } else { /* parent */
          int status;
          wait(&status);
          if(status) { /* failure if status != 0 */
            exit(1);
          }

          close(fd[1]); /* stop writing from pipe */ /**/

          if (dup2(fd[0], STDIN_FILENO) < 0) {
            err(EX_OSERR, "dup2 error.");
          }

          if(execute(t->right) == 0) {
            exit(0);
          } else {
            exit(-1);
          }
        }
      } else { /* second parent */
        int status_2;
        wait(&status_2);
        return status_2;
      }
    }
    return 0;
  }

static void print_tree(struct tree *t) {
   if (t != NULL) {
      print_tree(t->left);

      if (t->conjunction == NONE) {
         printf("NONE: %s, ", t->argv[0]);
      } else {
         printf("%s, ", conj[t->conjunction]);
      }
      printf("IR: %s, ", t->input);
      printf("OR: %s\n", t->output);

      print_tree(t->right);
   }
}
