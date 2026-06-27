public class Fib {
    public static void main(String[] args) {
        final long steps = 375_000_000L;
        final long mod = 1_000_000_007L;
        long a = 0;
        long b = 1;
        for (long i = 0; i < steps; i++) {
            long t = (a + b) % mod;
            a = b;
            b = t;
        }
        System.out.println(b);
    }
}
