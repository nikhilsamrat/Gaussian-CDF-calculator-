// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


type Fixed256x18 is int256;

library FixedMath {
    int256 constant multiplier = 10**18;

    function add(Fixed256x18 a, Fixed256x18 b) internal pure returns (Fixed256x18) {
        return Fixed256x18.wrap(Fixed256x18.unwrap(a) + Fixed256x18.unwrap(b));
    }

    function sub(Fixed256x18 a, Fixed256x18 b) internal pure returns (Fixed256x18) {
        return Fixed256x18.wrap(Fixed256x18.unwrap(a) - Fixed256x18.unwrap(b));
    }

    function neg(Fixed256x18 a) internal pure returns (Fixed256x18) {
        return Fixed256x18.wrap(-Fixed256x18.unwrap(a));
    }
    
    function round_mul(Fixed256x18 a, Fixed256x18 b) internal pure returns (Fixed256x18) {
        int256 a_int = Fixed256x18.unwrap(a) / multiplier;
        int256 a_frac = Fixed256x18.unwrap(a) % multiplier;
        int256 b_int = Fixed256x18.unwrap(b) / multiplier;
        int256 b_frac = Fixed256x18.unwrap(b) % multiplier;

        int256 result_int_int;
        int256 result_int_frac;
        int256 result_frac_int;
        unchecked{
            result_int_int = a_int * b_int * multiplier;
            result_int_frac = a_int * b_frac;
            result_frac_int = a_frac * b_int;
        }
        if ((a_int != 0) && ((result_int_int / a_int != (b_int * multiplier)) || ((result_int_frac / a_int) != b_frac))) {
            return Fixed256x18.wrap(type(int256).max);
        }
        if ((b_int != 0) && ((result_frac_int / b_int) != a_frac)) {
            return Fixed256x18.wrap(type(int256).max);
        }
        int256 result_frac_frac = (a_frac * b_frac) / multiplier;
        
        return Fixed256x18.wrap(result_int_int + result_int_frac + result_frac_int + result_frac_frac);
    }

    function round_div(Fixed256x18 a, Fixed256x18 b) internal pure returns (Fixed256x18) {

        int256 result_int = (Fixed256x18.unwrap(a) / Fixed256x18.unwrap(b)) * multiplier;
        int256 result_frac = (Fixed256x18.unwrap(a) % Fixed256x18.unwrap(b)) * multiplier / Fixed256x18.unwrap(b);
        return Fixed256x18.wrap(result_int + result_frac);
    }

    function inv(Fixed256x18 a) internal pure returns (Fixed256x18) {
        return round_div(toFixed256x18(1), a); 
    }

    function incr(Fixed256x18 a) internal pure returns (Fixed256x18) {
        return add(toFixed256x18(1), a); 
    }

    function toFixed256x18(int256 a) internal pure returns (Fixed256x18) {
        return Fixed256x18.wrap(a * multiplier);
    }

    function pow(Fixed256x18 a, uint8 e) internal pure returns (Fixed256x18) {
        Fixed256x18 res = toFixed256x18(1); 
        for (uint8 i = 0; i < e; i++) {
            res = round_mul(a, res);
        }
        return res;
    }

    function expneg2(Fixed256x18 x) internal pure returns (Fixed256x18) {
        int256 precision = 10 ** 10;
        int256 term_max = multiplier * multiplier;
        
        Fixed256x18 term = toFixed256x18(1);
        Fixed256x18 sum = toFixed256x18(1);


        x = FixedMath.pow(x, 2);

        for (int256 i = 1; i <= 15; i++) {
            term = round_div(round_mul(term, x), toFixed256x18(i));
            if (Fixed256x18.unwrap(term) > term_max) {
                return toFixed256x18(0);
            }
            sum = add(sum, term);
            if (Fixed256x18.unwrap(term) < precision) {
                break;
            }
        }

        return FixedMath.inv(sum);
    
    }
}



contract CDF {


    function errf(Fixed256x18 x) public pure returns (Fixed256x18) { 

        if (Fixed256x18.unwrap(x) < 0) {
            return FixedMath.neg(errf(FixedMath.neg(x)));
        }


        Fixed256x18[5] memory a1_5 = [Fixed256x18.wrap(254829592000000000),
                                        Fixed256x18.wrap(-284496736000000000),
                                        Fixed256x18.wrap(1421413741000000000),
                                        Fixed256x18.wrap(-1453152027000000000),
                                        Fixed256x18.wrap(1061405429000000000)];
        Fixed256x18 p = Fixed256x18.wrap(327591100000000000);

        Fixed256x18 t = FixedMath.inv(FixedMath.incr(FixedMath.round_mul(p, x)));


        Fixed256x18 at = a1_5[4];
        for (int256 i = 3; i >= 0; i-- ) {
            at = FixedMath.add(a1_5[uint256(i)], FixedMath.round_mul(at, t));
            
        }

        at = FixedMath.round_mul(at, t);

        return FixedMath.sub(FixedMath.toFixed256x18(1), FixedMath.round_mul(at, FixedMath.expneg2(x)));
        
    }

    function gaussianCDF(Fixed256x18 x, Fixed256x18 mu, Fixed256x18 sigma) public pure returns (Fixed256x18) { 
        Fixed256x18 sqrt2 = Fixed256x18.wrap(1414213562373095048);
        Fixed256x18 newx = FixedMath.round_div(FixedMath.sub(x, mu), FixedMath.round_mul(sqrt2, sigma));
        return FixedMath.round_div(FixedMath.incr(errf(newx)), FixedMath.toFixed256x18(2));
    }
}   