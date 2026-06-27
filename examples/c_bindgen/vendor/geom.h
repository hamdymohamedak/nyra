#ifndef GEOM_H
#define GEOM_H

typedef struct Point {
    int x;
    int y;
} Point;

Point make_point(int x, int y);
int point_sum(Point p);
int geom_add(int a, int b);

#endif
