#include <stdbool.h>
#include <stdint.h>

__attribute__((noreturn))
void _start() {
    int a = 0;
    int b = 0x100;

    for (int i = 1; i < 10; i ++) {
        a += i;
    }

    while (true) {
        b -= 1;
    }

}
