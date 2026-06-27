#include "geom.h"

Point make_point(int x, int y) {
    Point p;
    p.x = x;
    p.y = y;
    return p;
}

int point_sum(Point p) {
    return p.x + p.y;
}

int geom_add(int a, int b) {
    return a + b;
}
