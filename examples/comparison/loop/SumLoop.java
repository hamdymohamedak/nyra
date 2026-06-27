public class SumLoop {
    public static void main(String[] args) {
        long sum = 0;
        final long n = 375_000_000L;
        final long mod = 1_000_000_007L;
        for (long i = 0; i < n; i++) {
            sum = (sum + i) % mod;
        }
        System.out.println(sum);
    }
}
