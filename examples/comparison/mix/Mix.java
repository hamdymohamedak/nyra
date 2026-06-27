public class Mix {
    public static void main(String[] args) {
        long acc = 0;
        final long n = 270_000_000L;
        final long mod = 1_000_000_007L;
        for (long i = 0; i < n; i++) {
            long t = (i % 997) * 31;
            acc = (acc + t + (acc % 4099)) % mod;
        }
        System.out.println(acc);
    }
}
