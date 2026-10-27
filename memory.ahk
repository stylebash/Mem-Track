; usage examples:
; memLogBefore := Memory.Used()

; load data...
; loaded := Memory.Used() - memLogBefore
; do something with "loaded" here like...
; OutputDebug(Memory.ToString(loaded, 'KB'))

; Or you could just output a string directly with the Memory.Loaded() method...
; OutputDebug("Loaded: " . Memory.Loaded(memLogBefore, true))
; OutputDebug("Loaded: " . Memory.Loaded(memLogBefore, true, "GB"))

; if Memory.IsOver(2, "GB") {
;     ; do whatever you want
; }

/**
 * Log memory used,
 * compute if it's over a certain amount of memory,
 * compute the memory already loaded by the script
 */
class Memory {
    /**
     * How much memory is used by the current process since?
     */
    static Used() {
        pmc := Buffer(72, 0)
        NumPut("UInt", 72, pmc)

        if !DllCall(
            "Psapi\GetProcessMemoryInfo",
            "Ptr", DllCall("GetCurrentProcess", "Ptr"),
            "Ptr", pmc,
            "UInt", 72
        )
            return false

        return NumGet(pmc, 56, "UInt64")
    }

    /**
     * Are we over "count unit" of memory?
     * or: Are we over "4 GB" of memory?
     * @param count int decimal number representation of unit we're trying to determine
     * @param unit string "B", "KB", "MB", "GB"
     * @returns bool
     */
    static IsOver(count, unit := "MB") {
        return Memory.Used() >= count * Memory.Unit(unit)
    }

    /**
     * How much memory was loaded since before (Memory.Used())?
     * @param before int
     * @param stringify bool
     * @param unit string
     * @returns int raw memory number
     * @returns string if stringify is true, returns formatted string
     *  example: "4 GB", "2 MB", etc.
     */
    static Loaded(before, stringify := false, unit := "MB", decimals := 2) {
        loaded := Memory.Used() - before

        if stringify == true
            return Memory.ToString(loaded, unit, decimals)

        return loaded
    }

    /**
     * Makes memory numbers more human readable
     * @param memory int
     * @param unit string
     * @returns string formatted string
     *  example: "4 GB", "2 MB", etc.
     */
    static ToString(memory, unit := "MB", decimals := 2) {
        unit := StrUpper(unit)
        ; turns out, variable names are case-insensitive in AHK. wtf.
        ; so when "Memory" is called, it's actually using the "memory" variable. tf.
        divisor := this.Unit(unit)

        if !divisor
            return memory . " B"

        return Round(memory / divisor, decimals) . " " . unit
    }

    static Unit(unit) {
        switch StrUpper(unit) {
            case "KB":
                return 1024
            case "MB":
                return 1024 ** 2
            case "GB":
                return 1024 ** 3
            default:
                return 0
        }
    }
}