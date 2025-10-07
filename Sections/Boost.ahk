; Uses all slots that have the certain action when calling
; Example usage would be 
; UseSlots("GatherStart")
; This Uses all slots that have "GatherStart" selected

global lastActivationBoost := [0, 0, 0, 0, 0, 0, 0]
global slotUsed := false

UseSlots(action) {
    global slotUsed
    currentTime := A_TickCount
    
    for i, slot in [slot1Use, slot2Use, slot3Use, slot4Use, slot5Use, slot6Use, slot7Use] {
        if (slot == action && slot%i%Check) {
            cooldown := slot%i%Time
            if (currentTime - lastActivationBoost[i] >= cooldown * 1000) {
                Send(i)
                lastActivationBoost[i] := currentTime
                slotUsed := true
                Sleep(50)  ; Small delay between key presses
            }
        }
    }
    return slotUsed
}

PressAlwaysSlots() { 
    currentTime := A_TickCount
    
    for i, slot in [slot1Use, slot2Use, slot3Use, slot4Use, slot5Use, slot6Use, slot7Use] {
        if (slot == "Always" && slot%i%Check) {
            cooldown := slot%i%Time
            if (currentTime - lastActivationBoost[i] >= cooldown * 1000) {
                Send(i)
                lastActivationBoost[i] := currentTime
                Sleep(50)  ; Small delay between key presses
            }
        }
    }
}

UseGatherSlots() {
    UseSlots("Gathering")
}
