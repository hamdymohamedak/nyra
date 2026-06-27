enum LengthUnit {
    Meter
    Kilometer
    Centimeter
    Mile
    Foot
}

fn Length_to_meters(value, unit){
    return match unit {
        LengthUnit.Meter => value
        LengthUnit.Kilometer => value * 1000
        LengthUnit.Centimeter => value / 100
        LengthUnit.Mile => value * 1609
        LengthUnit.Foot => value * 305 / 1000
    }
}

fn Length_from_meters(meters, unit){
    return match unit {
        LengthUnit.Meter => meters
        LengthUnit.Kilometer => meters / 1000
        LengthUnit.Centimeter => meters * 100
        LengthUnit.Mile => meters / 1609
        LengthUnit.Foot => meters * 1000 / 305
    }
}

fn Unit_parse_length(name){
    if strcmp(name, "m") == 0 {
        return LengthUnit.Meter
    }
    if strcmp(name, "km") == 0 {
        return LengthUnit.Kilometer
    }
    if strcmp(name, "cm") == 0 {
        return LengthUnit.Centimeter
    }
    if strcmp(name, "mi") == 0 {
        return LengthUnit.Mile
    }
    return LengthUnit.Foot
}

fn Unit_usage(){
    print("usage: unitconv <value> <from> <to>")
    print("  units: m km cm mi ft")
}

fn Unit_convert(value, from, to){
    let meters = Length_to_meters(value, from)
    return Length_from_meters(meters, to)
}

fn Unit_run(args){
    if args.len() != 3 {
        Unit_usage()
        return 1
    }
    let value = str_to_i32(args.get(0))
    let from = Unit_parse_length(args.get(1))
    let to = Unit_parse_length(args.get(2))
    let result = Unit_convert(value, from, to)
    print(result)
    return 0
}
