#ifndef NYRA_BINDGEN_STRUCT_H
#define NYRA_BINDGEN_STRUCT_H

typedef struct Point {
    int x;
    int y;
} Point;

Point make_point(int x, int y);
int point_sum(Point p);

#endif
