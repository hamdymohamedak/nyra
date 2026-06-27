public class Nested {
    public static void main(String[] args) {
        long sum = 0;
        final int n = 4000;
        final long mod = 1_000_000_007L;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                sum = (sum + (long) i * j) % mod;
            }
        }
        System.out.println(sum);
    }
}
