#include <stdbool.h>
#include <stdint.h>

__attribute__((noreturn))
void _start() {
    int a;
    int b = 0xfedcba98;

    // a[0] = 0;

    // for (int i = 1; ; i ++) {
    //     // a[i] = a[i-1] + i;
    //     a = a + i;
    // }

    while (true) {
        b -= 0x12345678;
    }

}
