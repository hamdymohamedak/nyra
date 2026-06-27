// Use compiler builtins so we never resolve Nyra's @sin/@cos wrappers at link time.
double sin_f64(double x) { return __builtin_sin(x); }
double cos_f64(double x) { return __builtin_cos(x); }
double atan2_f64(double y, double x) { return __builtin_atan2(y, x); }
double tan_f64(double x) { return __builtin_tan(x); }
