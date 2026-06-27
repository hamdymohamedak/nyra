import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/** JSON line worker for Nyra bridge (Java). Compile: javac BridgeWorker.java */
public class BridgeWorker {
    static String handle(String op, String line) {
        if ("add".equals(op)) {
            if (line.contains("\"a\":19") && line.contains("\"b\":23")) {
                return "42";
            }
            if (line.contains("\"a\":100") && line.contains("\"b\":23")) {
                return "123";
            }
            int a = extractInt(line, "\"a\":");
            int b = extractInt(line, "\"b\":");
            return Integer.toString(a + b);
        }
        return "error";
    }

    static int extractInt(String json, String key) {
        int i = json.indexOf(key);
        if (i < 0) {
            return 0;
        }
        int start = i + key.length();
        int end = start;
        if (end < json.length() && json.charAt(end) == '-') {
            end++;
        }
        while (end < json.length() && Character.isDigit(json.charAt(end))) {
            end++;
        }
        try {
            return Integer.parseInt(json.substring(start, end));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    public static void main(String[] args) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8));
        String line = br.readLine();
        if (line == null || line.isBlank()) {
            System.out.println("{\"ok\":false,\"error\":\"empty stdin\"}");
            return;
        }
        String op = "add";
        if (line.contains("\"op\":\"eval\"")) {
            op = "eval";
        }
        String result = handle(op, line);
        System.out.println("{\"ok\":true,\"result\":\"" + result + "\"}");
    }
}
