import UIKit

let months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

func isLeap(year: Int) ->  Bool {
    return year % 4 == 0 ? year % 100 == 0 ? year % 400 == 0 : true : false
}

func julianDate(year: Int, month: Int, day: Int) -> Int {
    let yearDays = (1900..<year).reduce(0) { isLeap($1) ? $0 + 366 : $0 + 365 }
    let monthDays = (1..<month).reduce(0) { $0 + months[$1] }
    return yearDays + monthDays + day + (month > 2 ? isLeap(year) ? 1 : 0 : 0)
}

julianDate(1960, month:  9, day: 28)
julianDate(1900, month:  1, day: 1)
julianDate(1900, month: 12, day: 31)
julianDate(1901, month: 1, day: 1)
julianDate(1901, month: 1, day: 1) - julianDate(1900, month: 1, day: 1)
julianDate(2001, month: 1, day: 1) - julianDate(2000, month: 1, day: 1)

isLeap(1960)
isLeap(1900)
isLeap(2000)
