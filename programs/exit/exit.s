#PURPOSE:       Simple program that exits and returns a
#               status code back to the Linux kernel
#

#INPUT:         none 
#

#OUTPUT:        returns a status code.  This can be viewed
#               by typing
#
#               echo $?
#
#               after running the program
#

#VARIABLES:
#               %aex holds the system call number
#               (this is always the case)
#
#               %ebx holds the return status
#
.section .data

.section .text

.globl _start
_start:
 mov $60, %rax  # this is the linux kernel command
                # number (system call) for exiting
                # a program
                
 mov $6, %rdi  # this is the status number we will
                # return to the operating system.
                # Change this around and it will
                # return different things to
                # echo $?

syscall         # this wakes up the kernel to run
                # the exit command
