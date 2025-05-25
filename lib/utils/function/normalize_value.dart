double normalizeValue({
  required double input,
  double min = 10.0,
  double max = 30.0,
}) {
    if (input < min) {
        // Negative value based on distance below min
        return -(min - input) / (max - min);
    } else if (input > max) {
        // Negative value based on distance above max
        return -(input - max) / (max - min);
    } else {
        // Normalize between 0 and 1
        return (input - min) / (max - min);
    }
}