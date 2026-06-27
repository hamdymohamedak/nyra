public class StructSum {
    static class Point {
        int x;
        int y;
    }

    public static void main(String[] args) {
        long sum = 0;
        final int n = 80_000_000;
        Point p = new Point();
        p.x = 1;
        p.y = 2;
        for (int i = 0; i < n; i++) {
            sum += p.x + p.y;
        }
        System.out.println(sum);
    }
}
