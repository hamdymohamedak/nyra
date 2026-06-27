typedef struct Inner {
    int x;
} Inner;

typedef struct Outer {
    Inner inner;
    unsigned int y;
} Outer;

Outer make_outer(Inner i);
