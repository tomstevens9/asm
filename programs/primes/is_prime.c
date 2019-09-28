#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

bool is_prime(uint64_t n) {
    // sqrt_n - Square root of n rounded to the closest integer below or equal to n
    // i - loop counter
    uint64_t sqrt_n, i;
    // hard code for value less than 3
    switch(n) {
        case 0:
        case 1:
            return false;
        case 2:
            return true;
    }
    sqrt_n = floor(sqrt(n));
    for (i = 2; i <= sqrt_n; ++i) {
        if (n % i == 0) {
            return false;
        }
    }
    return true;
}

int main(int argc, char *argv[]) {
    int limit, c, current;

    limit = atoi(argv[1]);
    c = 0;
    current = 0;
    while (c < limit) {
        if (is_prime(++current)) {
            ++c;
        }
    }
    printf("%d\n", current);
}
