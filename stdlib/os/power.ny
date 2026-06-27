import "battery.ny"

extern fn hw_power_on_ac() -> i32
extern fn hw_power_cpu_temp_centi_c() -> i32

// 1 = on AC power, 0 = on battery, -1 = unknown.
fn power_on_ac() -> i32 {
    return hw_power_on_ac()
}

fn power_battery_percent() -> i32 {
    return battery_percent()
}

// CPU temperature in centi-degrees Celsius (4520 = 45.20 °C), or -1 if unavailable.
fn power_cpu_temp_centi_c() -> i32 {
    return hw_power_cpu_temp_centi_c()
}

fn power_cpu_temp_celsius_x10() -> i32 {
    let t = hw_power_cpu_temp_centi_c()
    if t < 0 {
        return -1
    }
    return t / 10
}
