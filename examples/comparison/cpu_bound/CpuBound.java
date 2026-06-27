public class CpuBound {
    public static void main(String[] args) {
        long acc = 0;
        final long n = 180_000_000L;
        for (long i = 0; i < n; i++) {
            long term = (i % 997) * 31;
            acc = (acc + term) % 997;
        }
        System.out.println(acc);
    }
}
