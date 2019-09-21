#PURPOSE - Given a number, this program computes the
#          factorial.  For example, the factorial of
#          3 is 3 * 2 * 1, or 6.  The factorial of
#          4 is 4 * 3 * 2 * 1, or 24, and so on.
#

#This program shows how to call a function recursively.

.section .data

#This program has no global data

.section .text

.globl _start
.globl factorial        #this is unneeded unless we want to share
		        #this function among other programs
_start:
mov $4, %rdi             #The factorial takes one argument - the
		         #number we want a factorial of.  So, it
                         #gets moved into rdi as the first
                         #parameter
call  factorial          #run the factorial function
                 
mov  %rax, %rdi         #factorial returns the answer in %rax, but
                        #we want it in %rdi to send it as our exit
                        #status
mov  $60, %rax          
syscall                 #call the kernel’s exit function

#This is the actual function definition
.type factorial,@function
factorial:
push %r12               # r12 is callee-saved so we need to
                        # push the current value of r12 before
                        # we use it

mov %rdi, %r12           # store the parameter in r12

cmp  $1, %rdi           #If the number is 1, that is our base
                        #case, and we simply return (1 is
                        #already in %rax as the return value)
je base_case
dec  %rdi               #otherwise, decrease the value
call  factorial         #call factorial

imul %r12, %rax     #multiply that by the result of the
                    #last call to factorial (in %rax)
                    #the answer is stored in %rax, which
                    #is good since that’s where return
                    #values go.
jmp end_factorial

base_case:
mov %rdi, %rax

end_factorial:

pop %r12            # restore r12 to it's original value
ret                 #return to the function (this pops th
