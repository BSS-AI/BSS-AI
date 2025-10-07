; ============================================================================
; cng cryptography library for autohotkey v2
; windows cryptography api: next generation implementation
; 
; author: slymi
; version: 2.0.0
; compatible: autohotkey v2.0+
; description: production cryptography using native windows cng
; 
; usage:
;   signature := CNG.HMAC_SHA256("message", "secret_key")
;   hash := CNG.SHA256("data")
; ============================================================================

class CNG {
    ; bcrypt constants
    static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008
    static BCRYPT_HASH_REUSABLE_FLAG := 0x00000020
    
    ; library info
    static VERSION := "2.0.0"
    static AUTHOR := "slymi"
    static DESCRIPTION := "windows cng cryptography for ahk v2"
    
    /**
     * generate hmac-sha256 signature
     * @param {string} data - data to sign
     * @param {string} key - secret key
     * @return {string} hexadecimal hmac signature
     */
    static HMAC_SHA256(data, key) {
        return this.BCryptHash("SHA256", data, key, "UTF-8", "HEX", this.BCRYPT_ALG_HANDLE_HMAC_FLAG)
    }
    
    /**
     * generate sha256 hash
     * @param {string} data - data to hash
     * @return {string} hexadecimal sha256 hash
     */
    static SHA256(data) {
        return this.BCryptHash("SHA256", data, "", "UTF-8", "HEX", 0)
    }
    
    /**
     * core bcrypt implementation
     * direct interface to windows cng api
     */
    static BCryptHash(algorithm, data, hmacKey := "", encoding := "UTF-8", output := "HEX", flags := 0) {
        try {
            ; open algorithm provider
            if (DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", &hAlgorithm := 0, "wstr", algorithm, "ptr", 0, "uint", flags) != 0) {
                throw Error("bcrypt algorithm provider failed")
            }
            
            ; get hash object size
            if (DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgorithm, "wstr", "ObjectLength", "uint*", &cbHashObject := 0, "uint", 4, "uint*", &cbResult := 0, "uint", 0) != 0) {
                DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
                throw Error("bcrypt object length query failed")
            }
            
            ; get hash digest length
            if (DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgorithm, "wstr", "HashDigestLength", "uint*", &cbHash := 0, "uint", 4, "uint*", &cbResult := 0, "uint", 0) != 0) {
                DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
                throw Error("bcrypt digest length query failed")
            }
            
            ; allocate hash object
            hashObject := Buffer(cbHashObject, 0)
            
            ; create hash handle
            if (hmacKey != "") {
                ; hmac mode with key
                keyBuffer := Buffer(StrPut(hmacKey, encoding) - 1, 0)
                StrPut(hmacKey, keyBuffer, encoding)
                
                if (DllCall("bcrypt\BCryptCreateHash", "ptr", hAlgorithm, "ptr*", &hHash := 0, "ptr", hashObject, "uint", cbHashObject, "ptr", keyBuffer, "uint", keyBuffer.Size, "uint", this.BCRYPT_HASH_REUSABLE_FLAG) != 0) {
                    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
                    throw Error("bcrypt hmac hash creation failed")
                }
            } else {
                ; standard hash mode
                if (DllCall("bcrypt\BCryptCreateHash", "ptr", hAlgorithm, "ptr*", &hHash := 0, "ptr", hashObject, "uint", cbHashObject, "ptr", 0, "uint", 0, "uint", this.BCRYPT_HASH_REUSABLE_FLAG) != 0) {
                    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
                    throw Error("bcrypt hash creation failed")
                }
            }
            
            ; process data
            dataBuffer := Buffer(StrPut(data, encoding) - 1, 0)
            StrPut(data, dataBuffer, encoding)
            
            if (DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", dataBuffer, "uint", dataBuffer.Size, "uint", 0) != 0) {
                DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
                DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
                throw Error("bcrypt data processing failed")
            }
            
            ; finalize hash
            hashBuffer := Buffer(cbHash, 0)
            if (DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", hashBuffer, "uint", cbHash, "uint", 0) != 0) {
                DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
                DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
                throw Error("bcrypt hash finalization failed")
            }
            
            ; cleanup handles
            DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
            DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
            
            ; format output as hexadecimal
            if (output = "HEX") {
                hexString := ""
                loop cbHash {
                    hexString .= Format("{:02x}", NumGet(hashBuffer, A_Index - 1, "UChar"))
                }
                return hexString
            }
            
            return hashBuffer
            
        } catch Error as e {
            ; ensure cleanup on error
            if (IsSet(hHash) && hHash) {
                DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
            }
            if (IsSet(hAlgorithm) && hAlgorithm) {
                DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgorithm, "uint", 0)
            }
            throw Error("cng cryptographic operation failed: " e.message)
        }
    }
}
