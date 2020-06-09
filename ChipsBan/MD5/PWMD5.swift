//
//  PWMD5.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/6/3.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import Foundation

typealias RInt = Int32

extension String {
    func binery() -> [RInt] {
        let charSize = UInt8.bitWidth
        let bases = utf8CString
        let length = bases.count > 0 ? (bases.count - 1):0
        guard length > 0 else { return [] }
        let finalIndex = length - 1
        let totalCount = (finalIndex * charSize) >> 5
        var bins = [RInt](repeating: 0, count: totalCount + 1)
        guard bins.count > 0 else { return [] }
        let range = 0..<length
        for index in range {
            let i = index * charSize
            let base = RInt(bases[index]) & 0xff
            let ov = i % 32
            let value = base << ov
            let offset = i >> 5
            bins[offset] |= value
        }
        return bins
    }
    
    var md5Hex: String {
        let charSize = UInt8.bitWidth
        var bins = binery()
        return [coreMD5(x: &bins, len: count * charSize)].hexString
    }
}

//function safe_add(x, y) {
//    var lsw = (x & 0xFFFF) + (y & 0xFFFF);
//    var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
//    return (msw << 16) | (lsw & 0xFFFF);
//}

func safeAdd(x: RInt, y: RInt) -> RInt {
    let lsw = (x & 0xFFFF) + (y & 0xFFFF)
    let msw = (x >> 16) + (y >> 16) + (lsw >> 16)
    return (msw << 16) | (lsw & 0xFFFF)
}

func bitRotate(number: RInt, bits: Int) -> RInt {
    guard bits < RInt.bitWidth, bits > 0 else {
        return number
    }
    
//    number.
    // return (num << cnt) | (num >>> (32 - cnt));
    return number << bits | number >> (RInt.bitWidth - bits)
}

//function md5_cmn(q, a, b, x, s, t) {
//    return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s),b);
//}

func md5CMN(q: RInt, a: RInt, b: RInt, x: RInt, s: Int, t: RInt) -> RInt {
    safeAdd(x: bitRotate(number: safeAdd(x: safeAdd(x: a, y: q), y: safeAdd(x: x, y: t)), bits: s), y: b)
}

func md5FF(a: RInt, b: RInt, c: RInt, d: RInt, x: RInt, s: Int, t: RInt) -> RInt {
    md5CMN(q: (b & c) | ((~b) & d), a: a, b: b, x: x, s: s, t: t)
}

func md5GG(a: RInt, b: RInt, c: RInt, d: RInt, x: RInt, s: Int, t: RInt) -> RInt {
    md5CMN(q: (b & d) | (c & (~d)), a: a, b: b, x: x, s: s, t: t)
}

func md5HH(a: RInt, b: RInt, c: RInt, d: RInt, x: RInt, s: Int, t: RInt) -> RInt {
    md5CMN(q: b ^ c ^ d, a: a, b: b, x: x, s: s, t: t)
}

func md5II(a: RInt, b: RInt, c: RInt, d: RInt, x: RInt, s: Int, t: RInt) -> RInt {
    md5CMN(q: c ^ (b | (~d)), a: a, b: b, x: x, s: s, t: t)
}

extension Array where Element == RInt {
    var hexString: String {
        let hexcase = 0
        let tabs = hexcase > 0 ? "0123456789ABCDEF":"0123456789abcdef"
        let length = self.count * 4
        let range = 0..<length
        var text = ""
        for i in range {
            let offset = i >> 2
            let ov = (i % 4) * 8 + 4
            let ovLow = (i % 4) * 8
            let indexHight: Int = Int((self[offset] >> ov) & 0xF)
            let indexLow: Int = Int((self[offset] >> ovLow) & 0xF)
            text += "\(String(tabs[tabs.index(tabs.startIndex, offsetBy: indexHight)]))\(String(tabs[tabs.index(tabs.startIndex, offsetBy: indexLow)]))"
        }
        return text
    }
}

//func coreMD5(x: inout [RInt], len: Int) -> [RInt] {
//    x[len >> 5] |= 0x80 << ((len) % 32)
//    let remiands = (((len + 64) >> 9) << 4) + 16 - x.count
//    if remiands > 0 {
//        x += [RInt].init(repeating: 0, count: remiands)
//    }
//    x[(((len + 64) >> 9) << 4) + 14] = RInt(len)
//
//    var a: RInt = 1732584193
//    var b: RInt = -271733879
//    var c: RInt = -1732584194
//    var d: RInt = 271733878
//
//    let count = x.count / 16
//    for index in 0..<count {
//        let olda = a
//        let oldb = b
//        let oldc = c
//        let oldd = d
//
//        let i = index * 16
//        a = md5FF(a: a, b: b, c: c, d: d, x: x[i + 0], s: 7, t: -680876936)
//        d = md5FF(a: d, b: a, c: b, d: c, x: x[i + 1], s: 12, t: -389564586)
//        c = md5FF(a: c, b: d, c: a, d: b, x: x[i + 2], s: 17, t: 606105819)
//        b = md5FF(a: b, b: c, c: d, d: a, x: x[i + 3], s: 22, t: -1044525330)
//        a = md5FF(a: a, b: b, c: c, d: d, x: x[i + 4], s: 7 , t: -176418897)
//        d = md5FF(a: d, b: a, c: b, d: c, x: x[i + 5], s: 12, t: 1200080426)
//        c = md5FF(a: c, b: d, c: a, d: b, x: x[i + 6], s: 17, t: -1473231341)
//        b = md5FF(a: b, b: c, c: d, d: a, x: x[i + 7], s: 22, t: -45705983)
//        a = md5FF(a: a, b: b, c: c, d: d, x: x[i + 8], s: 7 , t: 1770035416)
//        d = md5FF(a: d, b: a, c: b, d: c, x: x[i + 9], s: 12, t: -1958414417)
//        c = md5FF(a: c, b: d, c: a, d: b, x: x[i + 10], s: 17, t: -42063)
//        b = md5FF(a: b, b: c, c: d, d: a, x: x[i + 11], s: 22, t: -1990404162)
//        a = md5FF(a: a, b: b, c: c, d: d, x: x[i + 12], s: 7 , t: 1804603682)
//        d = md5FF(a: d, b: a, c: b, d: c, x: x[i + 13], s: 12, t: -40341101)
//        c = md5FF(a: c, b: d, c: a, d: b, x: x[i + 14], s: 17, t: -1502002290)
//        b = md5FF(a: b, b: c, c: d, d: a, x: x[i + 15], s: 22, t: 1236535329)
//
//        a = md5GG(a: a, b: b, c: c, d: d, x: x[i + 1], s: 5, t: -165796510)
//        d = md5GG(a: d, b: a, c: b, d: c, x: x[i + 6], s: 9, t: -1069501632)
//        c = md5GG(a: c, b: d, c: a, d: b, x: x[i + 11], s: 14, t: 643717713)
//        b = md5GG(a: b, b: c, c: d, d: a, x: x[i + 0], s: 20, t: -373897302)
//        a = md5GG(a: a, b: b, c: c, d: d, x: x[i + 5], s: 5, t: -701558691)
//        d = md5GG(a: d, b: a, c: b, d: c, x: x[i + 10], s: 9, t: 38016083)
//        c = md5GG(a: c, b: d, c: a, d: b, x: x[i + 15], s: 14, t: -660478335)
//        b = md5GG(a: b, b: c, c: d, d: a, x: x[i + 4], s: 20, t: -405537848)
//        a = md5GG(a: a, b: b, c: c, d: d, x: x[i + 9], s: 5, t: 568446438)
//        d = md5GG(a: d, b: a, c: b, d: c, x: x[i + 14], s: 9, t: -1019803690)
//        c = md5GG(a: c, b: d, c: a, d: b, x: x[i + 3], s: 14, t: -187363961)
//        b = md5GG(a: b, b: c, c: d, d: a, x: x[i + 8], s: 20, t: 1163531501)
//        a = md5GG(a: a, b: b, c: c, d: d, x: x[i + 13], s: 5, t: -1444681467)
//        d = md5GG(a: d, b: a, c: b, d: c, x: x[i + 2], s: 9, t: -51403784)
//        c = md5GG(a: c, b: d, c: a, d: b, x: x[i + 7], s: 14, t: 1735328473)
//        b = md5GG(a: b, b: c, c: d, d: a, x: x[i + 12], s: 20, t: -1926607734)
//
//        a = md5HH(a: a, b: b, c: c, d: d, x: x[i + 5], s: 4, t: -378558)
//        d = md5HH(a: d, b: a, c: b, d: c, x: x[i + 8], s: 11, t: -2022574463)
//        c = md5HH(a: c, b: d, c: a, d: b, x: x[i + 11], s: 16, t: 1839030562)
//        b = md5HH(a: b, b: c, c: d, d: a, x: x[i + 14], s: 23, t: -35309556)
//        a = md5HH(a: a, b: b, c: c, d: d, x: x[i + 1], s: 4, t: -1530992060)
//        d = md5HH(a: d, b: a, c: b, d: c, x: x[i + 4], s: 11, t: 1272893353)
//        c = md5HH(a: c, b: d, c: a, d: b, x: x[i + 7], s: 16, t: -155497632)
//        b = md5HH(a: b, b: c, c: d, d: a, x: x[i + 10], s: 23, t: -1094730640)
//        a = md5HH(a: a, b: b, c: c, d: d, x: x[i + 13], s: 4, t: 681279174)
//        d = md5HH(a: d, b: a, c: b, d: c, x: x[i + 0], s: 11, t: -358537222)
//        c = md5HH(a: c, b: d, c: a, d: b, x: x[i + 3], s: 16, t: -722521979)
//        b = md5HH(a: b, b: c, c: d, d: a, x: x[i + 6], s: 23, t: 76029189)
//        a = md5HH(a: a, b: b, c: c, d: d, x: x[i + 9], s: 4, t: -640364487)
//        d = md5HH(a: d, b: a, c: b, d: c, x: x[i + 12], s: 11, t: -421815835)
//        c = md5HH(a: c, b: d, c: a, d: b, x: x[i + 15], s: 16, t: 530742520)
//        b = md5HH(a: b, b: c, c: d, d: a, x: x[i + 2], s: 23, t: -995338651)
//
//        a = md5II(a: a, b: b, c: c, d: d, x: x[i + 0], s: 6, t: -198630844)
//        d = md5II(a: d, b: a, c: b, d: c, x: x[i + 7], s: 10, t: 1126891415)
//        c = md5II(a: c, b: d, c: a, d: b, x: x[i + 14], s: 15, t: -1416354905)
//        b = md5II(a: b, b: c, c: d, d: a, x: x[i + 5], s: 21, t: -57434055)
//        a = md5II(a: a, b: b, c: c, d: d, x: x[i + 12], s: 6, t: 1700485571)
//        d = md5II(a: d, b: a, c: b, d: c, x: x[i + 3], s: 10, t: -1894986606)
//        c = md5II(a: c, b: d, c: a, d: b, x: x[i + 10], s: 15, t: -1051523)
//        b = md5II(a: b, b: c, c: d, d: a, x: x[i + 1], s: 21, t: -2054922799)
//        a = md5II(a: a, b: b, c: c, d: d, x: x[i + 8], s: 6, t: 1873313359)
//        d = md5II(a: d, b: a, c: b, d: c, x: x[i + 15], s: 10, t: -30611744)
//        c = md5II(a: c, b: d, c: a, d: b, x: x[i + 6], s: 15, t: -1560198380)
//        b = md5II(a: b, b: c, c: d, d: a, x: x[i + 13], s: 21, t: 1309151649)
//        a = md5II(a: a, b: b, c: c, d: d, x: x[i + 4], s: 6, t: -145523070)
//        d = md5II(a: d, b: a, c: b, d: c, x: x[i + 11], s: 10, t: -1120210379)
//        c = md5II(a: c, b: d, c: a, d: b, x: x[i + 2], s: 15, t: 718787259)
//        b = md5II(a: b, b: c, c: d, d: a, x: x[i + 9], s: 21, t: -343485551)
//
//        a = safeAdd(x: a, y: olda)
//        b = safeAdd(x: b, y: oldb)
//        c = safeAdd(x: c, y: oldc)
//        d = safeAdd(x: d, y: oldd)
//    }
//
//    return [a, b, c, d]
//}

func coreMD5(x: inout [RInt], len: Int) -> RInt {
    let firstIndex = len >> 5
    let lastIndex = (((len + 64) >> 9) << 4) + 14
    
    let remiands = lastIndex + 2 - x.count
    if remiands > 0 {
        x += [RInt](repeating: 0, count: remiands)
    }
    x[firstIndex] |= 0x80 << ((len) % 32)
    x[lastIndex] = RInt(len)
    
//    console.log(">>> x[" + firstIndex + "]: " + x[firstIndex])
//    console.log(">>> x[" + lastIndex + "]: " + x[lastIndex])
//    console.log(">>> length: " + x.length + ", x15: " + x[15]);
    print(">>> x[\(firstIndex)]: \(x[firstIndex])")
    print(">>> x[\(lastIndex)]: \(x[lastIndex])")
    print(">>> length: \(x.count), x15: \(x[15])")
    
    var a: RInt = 1732584193
    var b: RInt = -271733879
    var c: RInt = -1732584194
    var d: RInt = 271733878
    
    let count = x.count / 16
    for index in 0..<count {
        let olda = a
        print(">>> olda: \(olda)")
        let oldb = b
        let oldc = c
        let oldd = d
        
        let i = index * 16
        print(">>> i: \(i)")
        a = md5FF(a: a, b: b, c: c, d: d, x: x[i + 0], s: 7, t: -680876936)
        print(">>> ffa: \(a)")
        a = md5GG(a: a, b: b, c: c, d: d, x: x[i + 1], s: 5, t: -165796510)
        print(">>> gga: \(a)")
        a = md5HH(a: a, b: b, c: c, d: d, x: x[i + 5], s: 4, t: -378558)
        print(">>> hha: \(a)")
        a = md5II(a: a, b: b, c: c, d: d, x: x[i + 0], s: 6, t: -198630844)
        print(">>> iia: \(a)")
        a = safeAdd(x: a, y: olda)
        print(">>> safea: \(a)")
    }
    
    return a
}

//function core_md5(x, len) {
//    x[len >> 5] |= 0x80 << ((len) % 32);
//    x[(((len + 64) >>> 9) << 4) + 14] = len;
//
//    var a =  1732584193;
//    var b = -271733879;
//    var c = -1732584194;
//    var d =  271733878;
//
//    for(var i = 0; i < x.length; i += 16) {
//        var olda = a;
//        var oldb = b;
//        var oldc = c;
//        var oldd = d;
//
//        a = md5_ff(a, b, c, d, x[i+ 0], 7 , -680876936);
//        d = md5_ff(d, a, b, c, x[i+ 1], 12, -389564586);
//        c = md5_ff(c, d, a, b, x[i+ 2], 17,  606105819);
//        b = md5_ff(b, c, d, a, x[i+ 3], 22, -1044525330);
//        a = md5_ff(a, b, c, d, x[i+ 4], 7 , -176418897);
//        d = md5_ff(d, a, b, c, x[i+ 5], 12,  1200080426);
//        c = md5_ff(c, d, a, b, x[i+ 6], 17, -1473231341);
//        b = md5_ff(b, c, d, a, x[i+ 7], 22, -45705983);
//        a = md5_ff(a, b, c, d, x[i+ 8], 7 ,  1770035416);
//        d = md5_ff(d, a, b, c, x[i+ 9], 12, -1958414417);
//        c = md5_ff(c, d, a, b, x[i+10], 17, -42063);
//        b = md5_ff(b, c, d, a, x[i+11], 22, -1990404162);
//        a = md5_ff(a, b, c, d, x[i+12], 7 ,  1804603682);
//        d = md5_ff(d, a, b, c, x[i+13], 12, -40341101);
//        c = md5_ff(c, d, a, b, x[i+14], 17, -1502002290);
//        b = md5_ff(b, c, d, a, x[i+15], 22,  1236535329);
//
//        a = md5_gg(a, b, c, d, x[i+ 1], 5 , -165796510);
//        d = md5_gg(d, a, b, c, x[i+ 6], 9 , -1069501632);
//        c = md5_gg(c, d, a, b, x[i+11], 14,  643717713);
//        b = md5_gg(b, c, d, a, x[i+ 0], 20, -373897302);
//        a = md5_gg(a, b, c, d, x[i+ 5], 5 , -701558691);
//        d = md5_gg(d, a, b, c, x[i+10], 9 ,  38016083);
//        c = md5_gg(c, d, a, b, x[i+15], 14, -660478335);
//        b = md5_gg(b, c, d, a, x[i+ 4], 20, -405537848);
//        a = md5_gg(a, b, c, d, x[i+ 9], 5 ,  568446438);
//        d = md5_gg(d, a, b, c, x[i+14], 9 , -1019803690);
//        c = md5_gg(c, d, a, b, x[i+ 3], 14, -187363961);
//        b = md5_gg(b, c, d, a, x[i+ 8], 20,  1163531501);
//        a = md5_gg(a, b, c, d, x[i+13], 5 , -1444681467);
//        d = md5_gg(d, a, b, c, x[i+ 2], 9 , -51403784);
//        c = md5_gg(c, d, a, b, x[i+ 7], 14,  1735328473);
//        b = md5_gg(b, c, d, a, x[i+12], 20, -1926607734);
//
//        a = md5_hh(a, b, c, d, x[i+ 5], 4 , -378558);
//        d = md5_hh(d, a, b, c, x[i+ 8], 11, -2022574463);
//        c = md5_hh(c, d, a, b, x[i+11], 16,  1839030562);
//        b = md5_hh(b, c, d, a, x[i+14], 23, -35309556);
//        a = md5_hh(a, b, c, d, x[i+ 1], 4 , -1530992060);
//        d = md5_hh(d, a, b, c, x[i+ 4], 11,  1272893353);
//        c = md5_hh(c, d, a, b, x[i+ 7], 16, -155497632);
//        b = md5_hh(b, c, d, a, x[i+10], 23, -1094730640);
//        a = md5_hh(a, b, c, d, x[i+13], 4 ,  681279174);
//        d = md5_hh(d, a, b, c, x[i+ 0], 11, -358537222);
//        c = md5_hh(c, d, a, b, x[i+ 3], 16, -722521979);
//        b = md5_hh(b, c, d, a, x[i+ 6], 23,  76029189);
//        a = md5_hh(a, b, c, d, x[i+ 9], 4 , -640364487);
//        d = md5_hh(d, a, b, c, x[i+12], 11, -421815835);
//        c = md5_hh(c, d, a, b, x[i+15], 16,  530742520);
//        b = md5_hh(b, c, d, a, x[i+ 2], 23, -995338651);
//
//        a = md5_ii(a, b, c, d, x[i+ 0], 6 , -198630844);
//        d = md5_ii(d, a, b, c, x[i+ 7], 10,  1126891415);
//        c = md5_ii(c, d, a, b, x[i+14], 15, -1416354905);
//        b = md5_ii(b, c, d, a, x[i+ 5], 21, -57434055);
//        a = md5_ii(a, b, c, d, x[i+12], 6 ,  1700485571);
//        d = md5_ii(d, a, b, c, x[i+ 3], 10, -1894986606);
//        c = md5_ii(c, d, a, b, x[i+10], 15, -1051523);
//        b = md5_ii(b, c, d, a, x[i+ 1], 21, -2054922799);
//        a = md5_ii(a, b, c, d, x[i+ 8], 6 ,  1873313359);
//        d = md5_ii(d, a, b, c, x[i+15], 10, -30611744);
//        c = md5_ii(c, d, a, b, x[i+ 6], 15, -1560198380);
//        b = md5_ii(b, c, d, a, x[i+13], 21,  1309151649);
//        a = md5_ii(a, b, c, d, x[i+ 4], 6 , -145523070);
//        d = md5_ii(d, a, b, c, x[i+11], 10, -1120210379);
//        c = md5_ii(c, d, a, b, x[i+ 2], 15,  718787259);
//        b = md5_ii(b, c, d, a, x[i+ 9], 21, -343485551);
//
//        a = safe_add(a, olda);
//        b = safe_add(b, oldb);
//        c = safe_add(c, oldc);
//        d = safe_add(d, oldd);
//    }
//    return Array(a, b, c, d);
//}


//function hex_md5(s){
//    return binl2hex(core_md5(str2binl(s), s.length * chrsz));
//}
