// Utility functions 

/**
 * @function feet
 * @brief Converts feet to inches.
 * @param f Value in feet.
 * @return Equivalent value in inches.
 */
function feet(f) = f * 12;

/**
 * @function inches
 * @brief Combines whole and fractional inches.
 * @param i Whole inches.
 * @param f Fractional inches.
 * @return Total in inches.
 */
function inches(i = 0, f = 0) = i + f;
