; Global variables to track planter cycles
global CurrentCycle := 1
global CurrentPlanterInCycle := 1
global CycleActivated := [true, true, true]
global planterRetrys := 0

; Add these for backward compatibility
global PlanterCountCycle1 := 1
global PlanterCountCycle2 := 1
global PlanterCountCycle3 := 1

/*
MANUALL PLANTERS
*/

MPPlacePlanter(planter) {
	global planterRetrys

	if (planter = "None") {
		return false
	}

	check := FindItem(planter)
	if check = false {
		SetStatus("Missing", "Planter " planter)
		return true
	}

	MouseClick("Left")
	Sleep 500

	x := GetRelativeX(860, 865)
	y := GetRelativeY(590, 595)

	MouseMove(x.min, y.min)
	MouseClick("left")
	MouseClick("left")
	MouseMove(x.max, y.max)
	Sleep 100
	MouseClick("left")
	MouseClick("left")

	if (checkForPlanterErrorFunc()) {
		SetStatus("Error", "Planter " planter)
		Sleep 100
		ClickOnInventory()
		return true
	}

	Sleep 100
	ClickOnInventory()
	SetStatus("Planted", planter)
	return false
}

Harvest(planter) {
	SetStatus("Harvesting", "Planter " planter)
	PressE()
	Sleep 500
	x := GetRelativeX(860, 863)
	y := GetRelativeY(585, 590)
	MouseMove(x.min, y.min, 3)
	MouseClick("Left", x.max, y.max, 3)
	Sleep 2500

	Move(5.5, w, d)
	loop 4 {
		Move(5.5, s)
		Move(1.3, a)
		Move(5.5, w)
		Move(1.3, a)
	}
}

ConvertPlanterTimeToMinutes(timeStr) {
	switch timeStr {
		case "30 mins": return 30
		case "1 hour": return 60
		case "1h 30 mins": return 90
		case "2 hour": return 120
		case "2h 30 min": return 150
		case "3 hour": return 180
		case "3h 30 min": return 210
		case "4 hour": return 240
		case "4h 30 min": return 270
		case "5 hour": return 300
		case "5h 30 min": return 330
		case "6 hour": return 360
		default: return 60
	}
}

Collectplanters() {
	global CurrentCycle, CurrentPlanterInCycle, CycleActivated
	global PlanterCountCycle1, PlanterCountCycle2, PlanterCountCycle3

	ValidateCycles()

	; First check if any planters need harvesting
	needsHarvesting := false
	cycleToHarvest := 0
	planterToHarvest := 0

	Loop 3 {
		cycle := A_Index
		if (!CycleActivated[cycle])
			continue

		Loop 3 {
			planter := A_Index
			planterType := cycle%cycle%Planter%planter%
			if (planterType = "None")
				continue

			plantTime := readSettings("MPlanters", "cycle" cycle "planter" planter, , "Settings\timers.ini")
			if (plantTime = 0)
				continue

			planterTimeValue := cycle%cycle%Time%planter%
			planterTimeMinutes := ConvertPlanterTimeToMinutes(planterTimeValue)

			if (nowUnix() - plantTime > planterTimeMinutes * 60) {
				needsHarvesting := true
				cycleToHarvest := cycle
				planterToHarvest := planter
				break 2
			}
		}
	}

	if (needsHarvesting) {
		DisconnectCheck()
		HarvestAndPlantNext(cycleToHarvest, planterToHarvest)
		return true
	}

	; If no planters need harvesting, check if we need to plant any in the current cycle
	; First determine which cycle we're currently on
	currentActiveCycle := 0

	; Check if any cycle has planters already placed
	Loop 3 {
		cycle := A_Index
		if (!CycleActivated[cycle])
			continue

		hasPlanters := false
		Loop 3 {
			planter := A_Index
			plantTime := readSettings("MPlanters", "cycle" cycle "planter" planter, , "Settings\timers.ini")
			if (plantTime > 0) {
				hasPlanters := true
				currentActiveCycle := cycle
				break 2
			}
		}
	}

	if (currentActiveCycle = 0) {
		currentActiveCycle := 1
		Loop 3 {
			if (CycleActivated[A_Index]) {
				currentActiveCycle := A_Index
				break
			}
		}
	}

	; Now check if any planters in the current cycle need planting
	needsPlanting := false

	; Plant all unplanted planters in the current cycle
	didPlantSomething := false

	; First, set the current cycle
	CurrentCycle := currentActiveCycle

	; Then plant all planters in this cycle
	Loop 3 {
		CurrentPlanterInCycle := A_Index
		planterType := cycle%CurrentCycle%Planter%CurrentPlanterInCycle%

		; Skip if this planter is set to None
		if (planterType = "None")
			continue

		plantTime := readSettings("MPlanters", "cycle" cycle "planter" planter, , "Settings\timers.ini")

		if (plantTime = 0) {
			needsPlanting := true
			break
		}
	}

	if (!needsPlanting) {
		return false
	}

	Loop 3 {
		CurrentPlanterInCycle := A_Index
		planterType := cycle%CurrentCycle%Planter%CurrentPlanterInCycle%

		if (planterType = "None")
			continue

		plantTime := readSettings("MPlanters", "cycle" cycle "planter" planter, , "Settings\timers.ini")

		if (plantTime = 0) {
			DisconnectCheck()
			PlantCurrentPlanter()
			didPlantSomething := true
		}
	}

	if (didPlantSomething) {
		SetStatus("Finished", "Planter Cycle " CurrentCycle)
		return true
	}
	return false
}

HarvestAndPlantNext(cycle, planter) {
	global CurrentCycle, CurrentPlanterInCycle

	fieldName := cycle%cycle%Field%planter%

	SetStatus("Harvesting", "Planter " planter)
	ResetToHive()

	; Go to field
	switch fieldName {
		case "Pine Tree": gt_pinetree()
		case "Blue Flower": gt_blueflower()
		case "Mountain Top": gt_mountaintop()
		default: gt_%fieldName%()
	}

	Harvest(planter)

	; Clear the plant time for this planter
	writeSettings("MPlanters", "cycle" cycle "planter" planter, 0, "Settings\timers.ini")

	; Update current cycle and planter for next planting
	CurrentCycle := cycle
	CurrentPlanterInCycle := planter

	; Move to next planter in sequence
	AdvanceToNextPlanter()

	; Plant the next planter
	PlantCurrentPlanter()
}

PlantCurrentPlanter() {
	global CurrentCycle, CurrentPlanterInCycle, planterRetrys

	; Make sure we're on a valid cycle and planter
	ValidateCurrentPosition()

	planterType := cycle%CurrentCycle%Planter%CurrentPlanterInCycle%

	; Skip if this planter is set to None
	if (planterType = "None") {
		SetStatus("Skipping planter", CurrentPlanterInCycle " in cycle " CurrentCycle " (set to None)")
		return
	}

	fieldName := cycle%CurrentCycle%Field%CurrentPlanterInCycle%

	SetStatus("Planting", planterType " in " fieldName)
	ResetToHive()

	; Go to field
	switch fieldName {
		case "Pine Tree": gt_pinetree()
		case "Blue Flower": gt_blueflower()
		case "Mountain Top": gt_mountaintop()
		default: gt_%fieldName%()
	}

	; Try to place the planter
	plantError := MPPlacePlanter(planterType)

	if (plantError) {
		planterRetrys++
		if (planterRetrys >= 2) {
			SetStatus("Failed", "Placing " planterType " after multiple attempts.")
			planterRetrys := 0
		} else {
			SetStatus("Retrying", "Placing " planterType)
			return PlantCurrentPlanter()
		}
	} else {
		; Successfully planted, record the time
		writeSettings("MPlanters", "cycle" CurrentCycle "planter" CurrentPlanterInCycle, nowUnix(), "settings\timers.ini")
		SetStatus("Planted", planterType " in " fieldName)
		planterRetrys := 0
	}

	ResetToHive()
}

AdvanceToNextPlanter() {
	global CurrentCycle, CurrentPlanterInCycle
	global PlanterCountCycle1, PlanterCountCycle2, PlanterCountCycle3

	CurrentPlanterInCycle++

	; If we've gone through all planters in this cycle, move to next cycle
	if (CurrentPlanterInCycle > 3) {
		CurrentPlanterInCycle := 1
		CurrentCycle++

		; If we've gone through all cycles, go back to cycle 1
		if (CurrentCycle > 3) {
			CurrentCycle := 1
		}
	}

	; Update the old variables for compatibility
	PlanterCountCycle1 := (CurrentCycle = 1) ? CurrentPlanterInCycle : PlanterCountCycle1
	PlanterCountCycle2 := (CurrentCycle = 2) ? CurrentPlanterInCycle : PlanterCountCycle2
	PlanterCountCycle3 := (CurrentCycle = 3) ? CurrentPlanterInCycle : PlanterCountCycle3

	; Make sure we're on a valid cycle
	ValidateCurrentPosition()
}

ValidateCurrentPosition() {
	global CurrentCycle, CurrentPlanterInCycle, CycleActivated

	; Find the next valid cycle if current one is inactive
	startCycle := CurrentCycle
	startPlanter := CurrentPlanterInCycle

	Loop 3 {
		if (CycleActivated[CurrentCycle])
			return

		CurrentCycle++
		if (CurrentCycle > 3)
			CurrentCycle := 1

		; If we've checked all cycles and none are active, activate cycle 1
		if (CurrentCycle = startCycle) {
			CurrentCycle := 1
			CycleActivated[1] := true
			return
		}
	}
}

ValidateCycles() {
	global CycleActivated

	Loop 3 {
		cycle := A_Index
		CycleActivated[cycle] := false

		; Check if this cycle has any valid planters
		hasValidPlanters := false
		Loop 3 {
			planter := A_Index
			planterType := cycle%cycle%Planter%planter%
			if (planterType != "" && planterType != "None") {
				hasValidPlanters := true
				break
			}
		}

		CycleActivated[cycle] := hasValidPlanters
	}

	; Make sure at least one cycle is active
	if (!CycleActivated[1] && !CycleActivated[2] && !CycleActivated[3]) {
		SetStatus("Failed", "No active cycles found")
	}
}

checkForPlanterErrorFunc() {
	CoordMode("Pixel", "Screen")

	if (searchForImage("planterplaced.png", 17, 0, 0, A_ScreenWidth, A_ScreenHeight, 50)) {
		return false
	}

	if (searchForImage("e.png", 10, 0, 0, A_ScreenWidth, A_ScreenHeight / 2, 50)) {
		return false
	}

	return true
}

searchForImage(imageName, variation, x1, y1, x2, y2, attempts) {
	loop attempts {
		if ImageSearch(&foundX, &foundY, x1, y1, x2, y2, "*" variation " " A_ScriptDir "\Assets\images\" imageName) {
			return true
		}
		Sleep(100)
	}
	return false
}

/*
Planters +
*/

BambooPlanters := [["hydroponic", 1.4, 1.375, 8.73] ; 1.925
	, ["petal", 1.5, 1.125, 12.45] ; 1.6875
	, ["pesticide", 1, 1.6, 6.25] ; 1.6
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["blueClay", 1.2, 1.1875, 5.06] ; 1.425
	, ["tacky", 1.25, 1, 8] ; 1.25
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["redClay", 1, 1, 6] ; 1
	, ["heattreated", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

BlueFlowerPlanters := [["hydroponic", 1.4, 1.345, 8.93] ; 1.883
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["tacky", 1, 1.5, 5.34] ; 1.5
	, ["blueClay", 1.2, 1.1725, 5.12] ; 1.407
	, ["petal", 1, 1.155, 12.13] ; 1.155
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["redClay", 1, 1, 6] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["heattreated", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 1

CactusPlanters := [["heattreated", 1.4, 1.215, 9.88] ; 1.701
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["redClay", 1.2, 1.1075, 5.42] ; 1.29
	, ["hydroponic", 1, 1.25, 9.6] ; 1.25
	, ["blueClay", 1, 1.125, 5.34] ; 1.125
	, ["petal", 1, 1.035, 13.53] ; 1.035
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

CloverPlanters := [["heattreated", 1.4, 1.17, 10.26] ; 1.638
	, ["tacky", 1, 1.5, 5.34] ; 1.5
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["redClay", 1.2, 1.085, 5.53] ; 1.302
	, ["hydroponic", 1, 1.17, 10.57] ; 1.17
	, ["petal", 1, 1.16, 12.07] ; 1.16
	, ["blueClay", 1, 1.085, 5.53] ; 1.085
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

CoconutPlanters := [["pop", 1.5, 1.5, 10.67] ; 2.25
	, ["candy", 1, 1.5, 2.67] ; 1.5
	, ["petal", 1, 1.447, 9.68] ; 1.447
	, ["hydroponic", 1.4, 1.023, 11.74] ; 1.4322
	, ["blueClay", 1.2, 1.0115, 5.94] ; 1.2138
	, ["heattreated", 1, 1.03, 11.66] ; 1.03
	, ["redClay", 1, 1.015, 5.92] ; 1.015
	, ["plastic", 1, 1, 2] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

DandelionPlanters := [["petal", 1.5, 1.4235, 9.84] ; 2.13525
	, ["tacky", 1.25, 1.5, 5.33] ; 1.875
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["hydroponic", 1.4, 1.0485, 11.45] ; 1.4679
	, ["blueClay", 1.2, 1.02425, 5.86] ; 1.2291
	, ["heattreated", 1, 1.028, 11.68] ; 1.028
	, ["redClay", 1, 1.014, 5.92] ; 1.014
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

MountainTopPlanters := [["pop", 1.5, 1.5, 10.67] ; 2.25
	, ["heattreated", 1.4, 1.25, 9.6] ; 1.75
	, ["redClay", 1.2, 1.125, 5.34] ; 1.35
	, ["hydroponic", 1, 1.25, 9.6] ; 1.25
	, ["blueClay", 1, 1.125, 5.34] ; 1.125
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["petal", 1, 1, 14] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

MushroomPlanters := [["heattreated", 1.4, 1.3425, 8.94] ; 1.8795
	, ["tacky", 1, 1.5, 5.34] ; 1.5
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["pesticide", 1.3, 1, 10] ; 1.3
	, ["candy", 1.2, 1, 4] ; 1.2
	, ["redClay", 1, 1.17125, 5.12] ; 1.17125
	, ["petal", 1, 1.1575, 12.1] ; 1.1575
	, ["plastic", 1, 1, 2] ; 1
	, ["blueClay", 1, 1, 6] ; 1
	, ["hydroponic", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 1

PepperPlanters := [["pop", 1.5, 1.5, 10.67] ; 2.25
	, ["heattreated", 1.4, 1.46, 8.22] ; 2.044
	, ["redClay", 1.2, 1.23, 4.88] ; 1.476
	, ["petal", 1, 1.04, 13.47] ; 1.04
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["blueClay", 1, 1, 6] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["hydroponic", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

PineTreePlanters := [["hydroponic", 1.4, 1.42, 8.46] ; 1.988
	, ["petal", 1.5, 1.08, 12.97] ; 1.62
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["blueClay", 1.2, 1.21, 4.96] ; 1.452
	, ["tacky", 1.25, 1, 8] ; 1.25
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["redClay", 1, 1, 6] ; 1
	, ["pesticide", 1, 1, 10] ; 1
	, ["heattreated", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

PineapplePlanters := [["petal", 1.5, 1.445, 9.69] ; 2.1675
	, ["candy", 1, 1.5, 2.67] ; 1.5
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["pesticide", 1.3, 1, 10] ; 1.3
	, ["tacky", 1.25, 1, 8] ; 1.25
	, ["redClay", 1.2, 1.015, 5.92] ; 1.218
	, ["heattreated", 1, 1.03, 11.66] ; 1.03
	, ["hydroponic", 1, 1.025, 11.71] ; 1.025
	, ["blueClay", 1, 1.0125, 5.93] ; 1.0125
	, ["plastic", 1, 1, 2] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

PumpkinPlanters := [["petal", 1.5, 1.285, 10.9] ; 1.9275
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["pesticide", 1.3, 1, 10] ; 1.3
	, ["redClay", 1.2, 1.055, 5.69] ; 1.266
	, ["tacky", 1.25, 1, 8] ; 1.25
	, ["heattreated", 1, 1.11, 10.82] ; 1.11
	, ["hydroponic", 1, 1.105, 10.86] ; 1.105
	, ["blueClay", 1, 1.0525, 5.71] ; 1.0525
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

RosePlanters := [["heattreated", 1.4, 1.41, 8.52] ; 1.974
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["pesticide", 1.3, 1, 10] ; 1.3
	, ["redClay", 1, 1.205, 4.98] ; 1.205
	, ["candy", 1.2, 1, 4] ; 1.2
	, ["petal", 1, 1.09, 12.85] ; 1.09
	, ["plastic", 1, 1, 2] ; 1
	, ["blueClay", 1, 1, 6] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["hydroponic", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

SpiderPlanters := [["pesticide", 1.3, 1.6, 6.25] ; 2.08
	, ["petal", 1, 1.5, 9.33] ; 1.5
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["heattreated", 1.4, 1, 12] ; 1.4
	, ["candy", 1.2, 1, 4] ; 1.2
	, ["plastic", 1, 1, 2] ; 1
	, ["blueClay", 1, 1, 6] ; 1
	, ["redClay", 1, 1, 6] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["hydroponic", 1, 1, 12] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

StrawberryPlanters := [["pesticide", 1, 1.6, 6.25] ; 1.6
	, ["candy", 1, 1.5, 2.67] ; 1.5
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["hydroponic", 1.4, 1, 12] ; 1.3
	, ["heattreated", 1, 1.345, 8.93] ; 1.345
	, ["blueClay", 1.2, 1, 6] ; 1.2
	, ["redClay", 1, 1.1725, 5.12] ; 1.1725
	, ["petal", 1, 1.155, 12.13] ; 1.155
	, ["plastic", 1, 1, 2] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

StumpPlanters := [["pop", 1.5, 1.5, 10.67] ; 2.25
	, ["heattreated", 1.4, 1.03, 11.65] ; 1.442
	, ["hydroponic", 1, 1.375, 8.73] ; 1.375
	, ["pesticide", 1.3, 1, 10] ; 1.3
	, ["candy", 1.2, 1, 4] ; 1.2
	, ["blueClay", 1, 1.1875, 5.06] ; 1.1875
	, ["petal", 1, 1.095, 12.79] ; 1.095
	, ["redClay", 1, 1.015, 5.92] ; 1.015
	, ["plastic", 1, 1, 2] ; 1
	, ["tacky", 1, 1, 8] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

SunflowerPlanters := [["petal", 1.5, 1.3415, 10.44] ; 2.01225
	, ["tacky", 1.25, 1.5, 5.34] ; 1.875
	, ["pop", 1.5, 1, 16] ; 1.5
	, ["pesticide", 1.3, 1, 10] ; 1.3
	, ["redClay", 1.2, 1.04175, 5.76] ; 1.2501
	, ["heattreated", 1, 1.0835, 11.08] ; 1.0835
	, ["hydroponic", 1, 1.075, 11.17] ; 1.075
	, ["blueClay", 1, 1.0375, 5.79] ; 1.0375
	, ["plastic", 1, 1, 2] ; 1
	, ["candy", 1, 1, 4] ; 1
	, ["paper", 0.75, 1, 1] ; 0.75
	, ["ticket", 2, 1, 2]] ; 2

ComfortingFields := ["dandelion", "bamboo", "pinetree"]
RefreshingFields := ["coconut", "strawberry", "blueflower"]
SatisfyingFields := ["pineapple", "sunflower", "pumpkin"]
MotivatingFields := ["stump", "spider", "mushroom", "rose"]
InvigoratingFields := ["pepper", "mountaintop", "clover", "cactus"]
global planternames := ["plastic", "candy", "blueClay", "redClay", "tacky", "pesticide", "heattreated", "hydroponic", "petal", "pop", "paper", "ticket"]
global nectarnames := ["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
global LastComfortingField, LastRefreshingField, LastSatisfyingField, LastMotivatingField, LastInvigoratingField
global LostPlanters := ""

planter() {
	global maxAllowedPlanters
	nectars := ["1", "2", "3", "4", "5"]
	currentFieldNectar := "None"
	for i, val in nectarnames {
		for j, k in %val%Fields {
			if (CurrentField = k) {
				currentFieldNectar := val
				break
			}
		}
	}

	needsWork := false

	Loop 3 {
		if ((PlanterHarvestTime%A_Index% < nowUnix()) && (PlanterName%A_Index% != "None") && (PlanterField%A_Index% != "None")) {
			needsWork := true
			break
		}
	}

	if (!needsWork) {
		maxplanters := 0
		for key, value in planternames {
			maxplanters := maxplanters + (%value%Allowed ? 1 : 0)
		}
		maxplanters := min(maxAllowedPlanters, maxplanters)

		planterSlots := []
		Loop 3 {
			if (PlanterName%A_Index% = "None")
				planterSlots.push(A_Index)
		}

		maxnectars := 0
		for key, value in nectars {
			if (nectarPriority%value% != "None")
				maxnectars := maxnectars + 1
		}

		if (planterSlots.Length > 0 && maxplanters > 0 && maxnectars > 0) {
			needsWork := true
		}
	}

	if (!needsWork) {
		return
	}

	Loop 2 {
		;re-optimize planters
		for key, value in nectars {
			;--- get nectar priority --
			currentNectar := nectarPriority%value%
			if (currentNectar != "None") {
				estimatedNectarPercent := 0
				Loop 3 { ;3 max positions
					planterNectar := PlanterNectar%A_Index%
					if (PlanterNectar = currentNectar) {
						estimatedNectarPercent := estimatedNectarPercent + PlanterEstPercent%A_Index%
					}
				}
				nectarPercent := GetNectarPercent(currentNectar)
				;recover planters that are collecting same nectar as currentField AND are not placed in currentField
				if (currentNectar = currentFieldNectar && not harvestFullGrown && gatherFieldNectarSipping) {
					Loop 3 { ;3 max positions
						if (currentField != PlanterField%A_Index% && currentFieldNectar = PlanterNectar%A_Index%) {
							temp1 := PlanterField%A_Index%
							PlanterHarvestTime%A_Index% := nowUnix() - 1
							writeSettings("Planters", "PlanterHarvestTime" . A_Index, PlanterHarvestTime%A_Index%, "Settings\timers.ini")
						}
					}
				}
				;recover planters that will overfill nectars
				if (harvestAuto && ((nectarPercent > 99) || (nectarPercent > 90 && (nectarPercent + estimatedNectarPercent) > 110) || (nectarPercent + estimatedNectarPercent) > 120)) {
					Loop 3 { ;3 max positions
						planterNectar := PlanterNectar%A_Index%
						if (PlanterNectar = currentNectar) {
							PlanterHarvestTime%A_Index% := nowUnix() - 1
							writeSettings("Planters", "PlanterHarvestTime" . A_Index, PlanterHarvestTime%A_Index%, "Settings\timers.ini")
						}
					}
				}
			} else {
				break
			}
		}
		;recover placed planters here
		Loop 3 {
			if ((PlanterHarvestTime%A_Index% < nowUnix()) && (PlanterName%A_Index% != "None") && (PlanterField%A_Index% != "None")) {
				i := A_Index
				Loop 5 {
					if (HarvestPlanter(i) = 1)
						break
					if (A_Index = 5) {
						SetStatus("Error", "Failed to harvest " PlanterName%i% " in " PlanterField%i% "!")
						;clear planter
						PlanterName%i% := "None"
						PlanterField%i% := "None"
						PlanterNectar%i% := "None"
						PlanterHarvestTime%i% := 2147483647
						PlanterEstPercent%i% := 0
						;write values to ini
						writeSettings("Planters", "PlanterName" . i, "None", "Settings\timers.ini", false)
						writeSettings("Planters", "PlanterField" . i, "None", "Settings\timers.ini", false)
						writeSettings("Planters", "PlanterNectar" . i, "None", "Settings\timers.ini", false)
						writeSettings("Planters", "PlanterHarvestTime" . i, 2147483647, "Settings\timers.ini", false)
						writeSettings("Planters", "PlanterEstPercent" . i, 0, "Settings\timers.ini")
						break
					}
				}
			}
		}
	}
	;re-place planters here
	;--- determine max number of planters ---
	maxplanters := 0
	for key, value in planternames {
		maxplanters := maxplanters + (%value%Allowed ? 1 : 0)
	}
	maxplanters := min(maxAllowedPlanters, maxplanters)
	if (maxplanters = 0)
		return
	;determine number of placed planters
	plantersplaced := 0
	planterSlots := []
	Loop 3 {
		if (PlanterName%A_Index% = "None")
			planterSlots.push(A_Index)
	}
	plantersplaced := 3 - planterSlots.Length
	;temp1:=planterSlots[1]
	;temp2:=planterSlots[2]
	;temp3:=planterSlots[3]
	;temp4:=planterSlots.Length
	if ( not planterSlots.Length)
		return
	;--- determine max number of nectars ---
	maxnectars := 0

	for key, value in nectars {
		if (nectarPriority%value% != "None")
			maxnectars := maxnectars + 1
	}
	if (maxnectars = 0)
		return

	;//////// STAGE 1: Fill nectars to thresholds ///////////////
	;---- fill in priority order until all thresholds have been met
	SetStatus("Starting", "Planters")
	for key, value in nectars {
		;--- get nectar priority --
		currentNectar := nectarPriority%value%
		if (currentNectar = "None")
			continue
		nextPlanter := []
		;get maxNectarPlanters
		maxNectarPlanters := 0
		for ind, field in %currentNectar%Fields
		{
			if (%field%Allowed)
				maxNectarPlanters := maxNectarPlanters + 1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced := 0
		Loop 3 {
			if (PlanterNectar%A_Index% = currentNectar)
				nectarPlantersPlaced := nectarPlantersPlaced + 1
		}
		if (currentNectar != "None") {
			planterSlots := []
			Loop 3 {
				if (PlanterName%A_Index% = "None")
					planterSlots.push(A_Index)
			}
			for i, planterNum in planterSlots {
				;Loop 3 { ;3 max planters
				;temp1:=planterSlots[1]
				;temp2:=planterSlots[2]
				;temp3:=planterSlots[3]
				;temp4:=planterSlots.Length
				;--- determine max number of planters ---
				maxplanters := 0
				for x, y in planternames {
					maxplanters := maxplanters + (%y%Allowed ? 1 : 0)
				}

				maxplanters := min(maxAllowedPlanters, maxplanters)
				;determine last and next fields
				if (currentNectar = currentFieldNectar && not gatherPlanterField && gatherFieldNectarSipping) { ;always place planter in field you are collecting from
					lastNextField := getlastfield(currentNectar)
					lastField := lastNextField[1]
					nextField := CurrentField
					maxNectarPlanters := 1
				} else {
					lastNextField := getlastfield(currentNectar)
					lastField := lastNextField[1]
					nextField := lastNextField[2]
				}
				LostPlanters := ""
				nextPlanter := GetNextPlanter(nextField)
				;there is an allowed field for this nectar and an available planter
				;temp1:=nextPlanter[1]
				if (nextField != "none" && nextPlanter[1] != "none" && plantersplaced < maxplanters && plantersplaced < maxAllowedPlanters && nectarPlantersPlaced < maxNectarPlanters) {
					;determine current nectar percent
					nectarPercent := GetNectarPercent(currentNectar)
					nectarMinPercent := nectarMin%value%
					estimatedNectarPercent := 0
					Loop 3 { ;3 max positions
						planterNectar := PlanterNectar%A_Index%
						if (PlanterNectar = currentNectar) {
							estimatedNectarPercent := estimatedNectarPercent + PlanterEstPercent%A_Index%
						}
					}
					;temp1:=nectarPercent + estimatedNectarPercent
					if (currentNectar = currentFieldNectar && estimatedNectarPercent > 0) {
						break
					}
					if (((nectarPercent + estimatedNectarPercent) < nectarMinPercent)) {
						success := -1, atField := 0
						while (success != 1 && nextField != "none" && nextPlanter[1] != "none") {
							success := PlacePlanter(nextField, nextPlanter, planterNum, atField)
							switch success {
								case 1: ;planter placed successfully, break loop
									plantersplaced++
									nectarPlantersPlaced++
									SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
									break

								case 2: ;already a planter in this field, change field and try
									lastnextfield := getlastfield(currentNectar)
									lastField := lastNextField[1]
									nextField := lastNextField[2]
									nextPlanter := GetNextPlanter(nextField)
									atField := 0
									LostPlanters := ""
									Last%currentNectar%Field := nextField
									writeSettings("Planters", "Last" currentNectar "Field", Last%currentNectar%Field, "Settings\timers.ini", false)
								case 3: ;3 planters have been placed already, return
									OpenMenu()
									return

								case 4: ;not in a field, try again
									atField := 0

								default: ;cannot find planter, try alternative planter in this field
									nextPlanter := GetNextPlanter(nextField)
									if (nextPlanter[1] = "none")
									{
										break
									}
									else
										atField := 1
							}
							if (A_Index = 10) {
								SetStatus("Error", "Failed to place planter in 10 tries!`nMax Allowed Planters has been set to " . maxAllowedPlanters . ".")
								maxAllowedPlanters := max(0, maxAllowedPlanters - 1)
								writeSettings("Planters", "maxplanters", maxAllowedPlanters)
								break
							}
						}
					} else {
						break
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if (plantersplaced = maxplanters || plantersplaced >= maxAllowedPlanters) {
					OpenMenu()
					return
				}
			}
		} else {
			break
		}
	}
	;//////// STAGE 2: All Nectars are at or will be above thresholds after harvested ///////////////
	;---- fill from lowest to highest nectar percent
	tempArray := []
	lowToHigh := [] ;nectarname list
	sortstring := ""
	;create sort list
	for key, value in nectars {
		currentNectar := nectarPriority%value%
		estimatedNectarPercent := 0
		Loop 3 {
			planterNectar := PlanterNectar%A_Index%
			if (PlanterNectar = currentNectar) {
				estimatedNectarPercent := estimatedNectarPercent + PlanterEstPercent%A_Index%
			}
		}
		if (currentNectar != "none") {
			nectarPercent := GetNectarPercent(currentNectar) + estimatedNectarPercent
			if (key > 1)
				sortstring := (sortstring . ";")
			sortstring := (sortstring . nectarPercent . "," . value . "," . currentNectar)
		} else {
			break
		}
	}
	;sort list and re-extract nectars in low to high percent order
	sortstring := Sort(sortstring, "D;")
	tempArray := StrSplit(sortstring, ";")
	for i, val in tempArray {
		tempstring := tempArray[A_Index]
		lowToHigh.InsertAt(A_Index, StrSplit(tempArray[A_Index], ","))
	}
	;temp1:=lowToHigh[1][3]
	;temp2:=lowToHigh[2][3]
	;temp3:=lowToHigh[3][3]
	;temp4:=lowToHigh[4][3]
	;temp5:=lowToHigh[5][3]
	for key, value in lowToHigh {
		currentNectar := lowToHigh[key][3]
		if (currentNectar = "None")
			continue
		nextPlanter := []
		planterSlots := []
		;get maxNectarPlanters
		maxNectarPlanters := 0
		for ind, field in %currentNectar%Fields
		{
			if (%field%Allowed)
				maxNectarPlanters := maxNectarPlanters + 1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced := 0
		Loop 3 {
			if (PlanterNectar%A_Index% = currentNectar)
				nectarPlantersPlaced := nectarPlantersPlaced + 1
		}
		Loop 3 {
			if (PlanterName%A_Index% = "none")
				planterSlots.push(A_Index)
		}
		for i, planterNum in planterSlots {
			;Loop 3 {
			;--- determine max number of planters ---
			maxplanters := 0
			for x, y in planternames {
				maxplanters := maxplanters + (%y%Allowed ? 1 : 0)
			}
			maxplanters := min(maxAllowedPlanters, maxplanters)
			;determine last and next fields
			if (currentNectar = currentFieldNectar && not gatherPlanterField && gatherFieldNectarSipping) {
				lastnextfield := getlastfield(currentNectar)
				lastField := lastNextField[1]
				nextField := CurrentField
				maxNectarPlanters := 1
			} else {
				lastnextfield := getlastfield(currentNectar)
				lastField := lastNextField[1]
				nextField := lastNextField[2]
			}
			LostPlanters := ""
			nextPlanter := GetNextPlanter(nextField)
			;there is an allowed field for this nectar and an available planter
			if (nextField != "none" && nextPlanter[1] != "none" && plantersplaced < maxplanters && plantersplaced < maxAllowedPlanters && nectarPlantersPlaced < maxNectarPlanters) {
				;determine current nectar percent
				nectarPercent := GetNectarPercent(currentNectar)
				estimatedNectarPercent := 0
				Loop 3 {
					planterNectar := PlanterNectar%A_Index%
					if (PlanterNectar = currentNectar) {
						estimatedNectarPercent := estimatedNectarPercent + PlanterEstPercent%A_Index%
					}
				}
				;is the last element in the array
				if (key = lowToHigh.Length) {
					success := -1, atField := 0
					while (success != 1 && nextField != "none" && nextPlanter[1] != "none") {
						success := PlacePlanter(nextField, nextPlanter, planterNum, atField)
						switch success {
							case 1: ;planter placed successfully, break loop
								plantersplaced++
								nectarPlantersPlaced++
								SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break

							case 2: ;already a planter in this field, change field and try
								lastnextfield := getlastfield(currentNectar)
								lastField := lastNextField[1]
								nextField := lastNextField[2]
								nextPlanter := GetNextPlanter(nextField)
								atField := 0
								LostPlanters := ""
								Last%currentNectar%Field := nextField
								writeSettings("Planters", "Last" currentNectar "Field", Last%currentNectar%Field, "Settings\timers.ini")

							case 3: ;3 planters have been placed already, return
								OpenMenu()
								return

							case 4: ;not in a field, try again
								atField := 0

							default: ;cannot find planter, try alternative planter in this field
								nextPlanter := GetNextPlanter(nextField)
								if (nextPlanter[1] = "none")
								{
									break
								}
								else
									atField := 1
						}
						if (A_Index = 10) {
							SetStatus("Error", "Failed to place planter in 10 tries!`nMax Allowed Planters has been set to " . maxAllowedPlanters . ".")
							maxAllowedPlanters := max(0, maxAllowedPlanters - 1)
							writeSettings("Planters", "maxplanters", maxAllowedPlanters)
							break
						}
					}
				} else { ;is not the last element in the array
					temp := lowToHigh[key + 1][1]
					if ((nectarPercent + estimatedNectarPercent) <= lowToHigh[key + 1][1]) {
						success := -1, atField := 0
						while (success != 1 && nextField != "none" && nextPlanter[1] != "none") {
							success := PlacePlanter(nextField, nextPlanter, planterNum, atField)
							switch success {
								case 1: ;planter placed successfully, break loop
									plantersplaced++
									nectarPlantersPlaced++
									SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
									break

								case 2: ;already a planter in this field, change field and try
									lastnextfield := getlastfield(currentNectar)
									lastField := lastNextField[1]
									nextField := lastNextField[2]
									nextPlanter := GetNextPlanter(nextField)
									atField := 0
									LostPlanters := ""
									Last%currentNectar%Field := nextField
									writeSettings("Planters", "Last" currentNectar "Field", Last%currentNectar%Field, "Settings\timers.ini")

								case 4: ;not in a field, try again
									atField := 0

								default: ;cannot find planter, try alternative planter in this field
									nextPlanter := GetNextPlanter(nextField)
									if (nextPlanter[1] = "none")
									{
										break
									}
									else
										atField := 1
							}
							if (A_Index = 10) {
								SetStatus("Error", "Failed to place planter in 10 tries!`nMax Allowed Planters has been set to " . maxAllowedPlanters . ".")
								maxAllowedPlanters := max(0, maxAllowedPlanters - 1)
								writeSettings("Planters", "maxplanters", maxAllowedPlanters)
								break
							}
						}
					} else {
						break
					}
				}
			} else {
				break
			}
			;maximum planters have been placed. leave function
			if (plantersplaced = maxplanters || plantersplaced >= maxAllowedPlanters) {
				OpenMenu()
				return
			}
		}
	}
	;//////// STAGE 3: All Nectars are full? ///////////////
	;just place planters in priority order (this is a failsafe stage)
	for key, value in nectars {
		;--- get nectar priority --
		currentNectar := nectarPriority%value%
		if (currentNectar = "None")
			continue
		nextPlanter := []
		;get maxNectarPlanters
		maxNectarPlanters := 0
		for ind, field in %currentNectar%Fields
		{
			if (%field%Allowed)
				maxNectarPlanters := maxNectarPlanters + 1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced := 0
		Loop 3 {
			if (PlanterNectar%A_Index% = currentNectar)
				nectarPlantersPlaced := nectarPlantersPlaced + 1
		}
		if (currentNectar != "none") {
			planterSlots := []
			Loop 3 {
				if (PlanterName%A_Index% = "none")
					planterSlots.push(A_Index)
			}
			for i, planterNum in planterSlots {
				;Loop 3 {
				;--- determine max number of planters ---
				maxplanters := 0
				for x, y in planternames {
					maxplanters := maxplanters + (%y%Allowed ? 1 : 0)
				}
				maxplanters := min(maxAllowedPlanters, maxplanters)
				;determine last and next fields
				if (currentNectar = currentFieldNectar && not gatherPlanterField && gatherFieldNectarSipping) {
					lastnextfield := getlastfield(currentNectar)
					lastField := lastNextField[1]
					nextField := CurrentField
					maxNectarPlanters := 1
				} else {
					lastnextfield := getlastfield(currentNectar)
					lastField := lastNextField[1]
					nextField := lastNextField[2]
				}
				LostPlanters := ""
				nextPlanter := GetNextPlanter(nextField)
				;there is an allowed field for this nectar and an available planter
				if (nextField != "none" && nextPlanter[1] != "none" && plantersplaced < maxplanters && plantersplaced < maxAllowedPlanters && nectarPlantersPlaced < maxNectarPlanters) {
					;determine current nectar percent
					nectarPercent := GetNectarPercent(currentNectar)
					estimatedNectarPercent := 0
					Loop 3 {
						planterNectar := PlanterNectar%A_Index%
						if (PlanterNectar = currentNectar) {
							estimatedNectarPercent := estimatedNectarPercent + PlanterEstPercent%A_Index%

						}
					}
					success := -1, atField := 0
					while (success != 1 && nextField != "none" && nextPlanter[1] != "none") {
						success := PlacePlanter(nextField, nextPlanter, planterNum, atField)
						switch success {
							case 1: ;planter placed successfully, break loop
								plantersplaced++
								nectarPlantersPlaced++
								SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break

							case 2: ;already a planter in this field, change field and try
								lastnextfield := getlastfield(currentNectar)
								lastField := lastNextField[1]
								nextField := lastNextField[2]
								nextPlanter := getNextPlanter(nextField)
								atField := 0
								LostPlanters := ""
								Last%currentNectar%Field := nextField
								writeSettings("Planters", "Last" currentNectar "Field", Last%currentNectar%Field, "Settings\timers.ini")
							case 3: ;3 planters have been placed already, return
								OpenMenu()
								return

							case 4: ;not in a field, try again
								atField := 0

							default: ;cannot find planter, try alternative planter in this field
								nextPlanter := GetNextPlanter(nextField)
								if (nextPlanter[1] = "none")
								{
									break
								}
								else
									atField := 1
						}
						if (A_Index = 10) {
							SetStatus("Error", "Failed to place planter in 10 tries!`nMax Allowed Planters has been set to " . maxAllowedPlanters . ".")
							maxAllowedPlanters := max(0, maxAllowedPlanters - 1)
							writeSettings("Planters", "maxplanters", maxAllowedPlanters)
							break
						}
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if (plantersplaced = maxplanters || plantersplaced >= maxAllowedPlanters) {
					OpenMenu()
					return
				}
			}
		} else {
			break
		}
	}
	OpenMenu()
}

GetNectarPercent(var) {
	global nectarnames, totalCom, totalMot, totalRef, totalSat, totalInv
	static nectarcolors := Map("comforting", 0x7E9EB3, "motivating", 0x937DB3, "satisfying", 0xB398A7, "refreshing", 0x78B375, "invigorating", 0xB35951)
	for key, value in nectarnames {
		if (var = value) {
			nectarColor := nectarcolors[StrLower(var)]
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			try
				result := PixelSearch(&bx2, &by2, windowX, windowY + offsetY + 30, windowX + 860, windowY + offsetY + 150, nectarColor)
			catch
				result := 0
			If (result = 1) {
				nexty := by2 + 1
				pixels := 1
				loop 38 {
					OutputVar := PixelGetColor(bx2, nexty)
					If (OutputVar = nectarColor) {
						nexty := nexty + 1
						pixels := pixels + 1
					} else {
						nectarpercent := round(pixels / 38 * 100, 0)
						break
					}
				}
			} else {
				nectarpercent := 0
			}
		}
	}
	if (nectarpercent = 100)
		nectarpercent := 99.99
	total%SubStr(var, 1, 3)% := nectarpercent
	return nectarpercent
}

HarvestPlanter(planterNum) {
	global PlanterName1, PlanterName2, PlanterName3
		, PlanterField1, PlanterField2, PlanterField3
		, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, PlanterNectar1, PlanterNectar2, PlanterNectar3
		, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3
		, LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField, HarvestInterval
	planterName := PlanterName%planterNum%
	fieldName := PlanterField%planterNum%
	planterNameStatus := (planterName = "blueclay" ? "Blue Clay" : (planterName = "redclay") ? "Red Clay" : (planterName = "heattreated") ? "Heat-Treated" : StrTitle(planterName)) . " Planter"
	fieldNameStatus := (fieldName = "pinetree") ? "Pine Tree"
		: (fieldName = "mountaintop") ? "Mountain Top"
		: (fieldName = "blueflower") ? "Blue Flower"
		: StrTitle(fieldName)
	SetShiftLock(0)
	ResetToHive(1, ((gatherLoot = 1) && ((fieldName = "rose") || (fieldName = "pinetree") || (fieldName = "pumpkin") || (fieldName = "cactus") || (fieldName = "spider"))) ? min(20000, (60 - hiveBees) * 1000) : 0)
	SetStatus("Traveling", planterNameStatus . " (" . fieldNameStatus . ")")
	gotoPlanter(fieldName)
	SetStatus("Collecting", (planterNameStatus . " (" . fieldNameStatus . ")"))
	findPlanter := 0
	if (CollectItem()) {
		findPlanter := 1
	}
	if (findPlanter = 0) {
		SetStatus("Searching", (planterNameStatus . " (" . fieldNameStatus . ")"))
		findPlanter := SearchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		SetStatus("Checking", "Phantom Planter: " . planterNameStatus)
		ActivateRoblox()
		GetRobloxClientPos()

		OpenMenu("itemmenu")
		planterPos := InventorySearch(planterName, "up", 4)

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			SetStatus("Found", planterNameStatus . ". Clearing Data.")
			;reset values
			PlanterName%planterNum% := "None"
			PlanterField%planterNum% := "None"
			PlanterNectar%planterNum% := "None"
			PlanterHarvestTime%planterNum% := 2147483647
			PlanterEstPercent%planterNum% := 0
			;write values to ini
			writeSettings("Planters", "PlanterName" . planterNum, "None", "Settings\timers.ini", false)
			writeSettings("Planters", "PlanterField" . planterNum, "None", "Settings\timers.ini", false)
			writeSettings("Planters", "PlanterNectar" . planterNum, "None", "Settings\timers.ini", false)
			writeSettings("Planters", "PlanterHarvestTime" . planterNum, 2147483647, "Settings\timers.ini", false)
			writeSettings("Planters", "PlanterEstPercent" . planterNum, 0, "Settings\timers.ini")
			return 1
		}
		else
			return 0
	}
	else {
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		Loop 50
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep 100

			if (A_Index = 50)
				return 0
		}

		Sleep 50 ; wait for game to update frame
		GetRobloxClientPos(hwnd)
		if ((HarvestFullGrown = 1) && !PlanterHarvestNow%planterNum%) {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
					MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX + 350, windowY + offsetY + 100
					Gdip_DisposeImage(pBMScreen)
					PlanterTimeUpdate(FieldName)
					return 1
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
					Sleep 800
					Click
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
						MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
						Sleep 200
						Click
					}
					sleep 100
					MouseMove windowX + 350, windowY + offsetY + 100
					Gdip_DisposeImage(pBMScreen)
					If PlanterHarvestNow%planterNum%
						writeSettings("Planters", "PlanterHarvestNow" . planterNum, 0, "Settings\timers.ini")
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}


		;reset values
		PlanterName%planterNum% := "None"
		PlanterField%planterNum% := "None"
		PlanterNectar%planterNum% := "None"
		PlanterHarvestTime%planterNum% := 2147483647
		PlanterEstPercent%planterNum% := 0
		;write values to ini
		writeSettings("Planters", "PlanterName" . planterNum, "None", "Settings\timers.ini", false)
		writeSettings("Planters", "PlanterField" . planterNum, "None", "Settings\timers.ini", false)
		writeSettings("Planters", "PlanterNectar" . planterNum, "None", "Settings\timers.ini", false)
		writeSettings("Planters", "PlanterHarvestTime" . planterNum, 2147483647, "Settings\timers.ini", false)
		writeSettings("Planters", "PlanterEstPercent" . planterNum, 0, "Settings\timers.ini")
		;PostSubmacroMessage("StatMonitor", 0x5555, 4, 1)
		;gather loot
		planterNameStatus := (planterName = "blueclay" ? "Blue Clay" : (planterName = "redclay") ? "Red Clay" : (planterName = "heattreated") ? "Heat-Treated" : StrTitle(planterName)) . " Planter"
		fieldNameStatus := (fieldName = "pinetree") ? "Pine Tree"
			: (fieldName = "mountaintop") ? "Mountain Top"
			: (fieldName = "blueflower") ? "Blue Flower"
			: StrTitle(fieldName)
		if (gatherLoot = 1)
		{
			SetStatus("Looting", planterNameStatus . " Loot")
			Sleep 1000
			Move(7, BackKey, RightKey)
			Loot(9, 5, "left")
		}
		if ((convertBagFull = 1) && (BackpackPercent(1) >= 95))
		{
			; loot path end location for some fields prevents successful return to hive
			If (gatherLoot = 1) {
				If (fieldname = "Cactus") || (fieldname = "Sunflower") {
					sleep 200
					Move(1500 * round(18 / moveSpeed, 8), RightKey)
					sleep 200
				}
			}
			walkFrom(fieldName)
			DisconnectCheck()
			findHiveSlot()
		}
		return 1
	}
}
SavePlacedPlanter(fieldName, planter, planterNum, nectar) {
	global PlanterName1, PlanterName2, PlanterName3
		, PlanterField1, PlanterField2, PlanterField3
		, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, PlanterNectar1, PlanterNectar2, PlanterNectar3
		, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3
		, LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField
	;temp1:=planter[1]
	;temp2:=planter[2]
	;temp3:=planter[3]
	;temp4:=planter[4]
	;save placed planter to ini
	PlanterName%planterNum% := planter[1]
	PlanterField%planterNum% := fieldName
	PlanterNectar%planterNum% := nectar
	PlanterNameN := PlanterName%planterNum%
	PlanterFieldN := PlanterField%planterNum%
	PlanterNectarN := PlanterNectar%planterNum%
	Last%nectar%Field := fieldName
	;calculate harvest time
	estimatedNectarPercent := 0
	Loop 3 { ;3 max positions
		planterNectar := PlanterNectar%A_Index%
		if (PlanterNectar = nectar) {
			estimatedNectarPercent := estimatedNectarPercent + PlanterEstPercent%A_Index%
		}
	}
	estimatedNectarPercent := estimatedNectarPercent + GetNectarPercent(nectar) ;projected nectar percent
	minPercent := estimatedNectarPercent
	Loop 5 { ;5 nectar priorities
		if (nectarMin%A_Index% = nectar && minPercent <= nectarMin%A_Index%)
			minPercent := nectarMin%A_Index% ; minPercent > estimatedNectarPercent
	}
	temp1 := minPercent - estimatedNectarPercent
	;timeToCap:=(max(0,(100-estimatedNectarPercent))*.24)/planter[2] ;hours
	timeToCap := max(0.25, ((max(0, (100 - estimatedNectarPercent) / planter[2])) * 0.24) / planter[3]) ;hours
	if (planter[2] * planter[3] < 1.2) { ;less than 20% overall bonus
		autoInterval := min(timeToCap, 0.5)
	}
	;if((minPercent > estimatedNectarPercent) && ((minPercent-estimatedNectarPercent)>=5) && ((estimatedNectarPercent)<=100)){
	else if ((minPercent > estimatedNectarPercent) && ((estimatedNectarPercent) <= 90)) {
		;autoInterval:=((minPercent-estimatedNectarPercent)*.24)/planter[2] ;hours
		if (estimatedNectarPercent > 0) {
			bonusTime := (100 / estimatedNectarPercent) * planter[2] * planter[3]
			autoInterval := (((minPercent - estimatedNectarPercent + bonusTime) / planter[2]) * 0.24) / planter[3] ;hours
		} else {
			autoInterval := planter[4] ;hours
		}

	} else { ;minPercent <= estimatedNectarPercent
		autoInterval := timeToCap
	}
	;nec=planter[2]
	;gro=planter[3]
	if (harvestAuto) {
		planterHarvestInterval := floor(min(planter[4], (autoInterval + autoInterval / (planter[2] * planter[3])), (timeToCap + timeToCap / (planter[2] * planter[3]))) * 60 * 60)
		PlanterHarvestTime%planterNum% := nowUnix() + planterHarvestInterval
	} else if (HarvestFullGrown) {
		planterHarvestInterval := floor(planter[4] * 60 * 60)
		PlanterHarvestTime%planterNum% := nowUnix() + planterHarvestInterval
	} else {
		;planterHarvestInterval:=floor(min(planter[4], HarvestInterval, (timeToCap+timeToCap/(planter[2]*planter[3])))*60*60)
		;planterHarvestInterval:=floor(min(planter[4], HarvestInterval)*60*60)
		;temp1:=planter[4]
		planterHarvestInterval := floor(min(planter[4], harvestEvery) * 60 * 60)
		smallestHarvestInterval := nowUnix() + planterHarvestInterval
		Loop 3 {
			if (PlanterHarvestTime%A_Index% > nowUnix() && PlanterHarvestTime%A_Index% < smallestHarvestInterval)
				smallestHarvestInterval := PlanterHarvestTime%A_Index%
		}
		PlanterHarvestTime%planterNum% := min(smallestHarvestInterval, nowUnix() + planterHarvestInterval)
		temp := PlanterHarvestTime%planterNum%
	}
	;PlanterHarvestTime%planterNum%:=toUnix_()+planterHarvestInterval
	PlanterHarvestTimeN := PlanterHarvestTime%planterNum%
	;PlanterEstPercent%planterNum%:=round((floor(min(planter[3], HarvestInterval)*60*60)*planter[2]-floor(min(planter[3], HarvestInterval)*60*60))/864, 1)
	PlanterEstPercent%planterNum% := round((floor(planterHarvestInterval) * planter[2]) / 864, 1)
	PlanterEstPercentN := PlanterEstPercent%planterNum%
	;save changes
	writeSettings("Planters", "PlanterName" . planterNum, PlanterNameN, "Settings\timers.ini", false)
	writeSettings("Planters", "PlanterField" . planterNum, PlanterFieldN, "Settings\timers.ini", false)
	writeSettings("Planters", "PlanterNectar" . planterNum, PlanterNectarN, "Settings\timers.ini")

	;make all harvest times equal
	Loop 3 {
		if ( not HarvestFullGrown && PlanterHarvestTime%A_Index% > PlanterHarvestTimeN && PlanterHarvestTime%A_Index% < PlanterHarvestTimeN + 600)
			writeSettings("Planters", "PlanterHarvestTime" . A_Index, PlanterHarvestTimeN, "Settings\timers.ini")
		else if (A_Index = planterNum)
			writeSettings("Planters", "PlanterHarvestTime" . A_Index, PlanterHarvestTimeN, "Settings\timers.ini")
	}

	writeSettings("Planters", "PlanterHarvestTime" . planterNum, PlanterHarvestTimeN, "Settings\timers.ini", false)
	writeSettings("Planters", "PlanterEstPercent" . planterNum, PlanterEstPercentN, "Settings\timers.ini")
}

getlastfield(currentNectar) {
	(arr := []).Length := 2, arr.Default := ""
	if (currentNectar = "None")
		return arr
	availablefields := []
	arr[1] := Last%currentNectar%Field
	;determine allowed fields
	for key, value in %currentNectar%Fields {
		tempfieldname := StrReplace(value, " ", "")
		if (%tempfieldname%Allowed && value != PlanterField1 && value != PlanterField2 && value != PlanterField3)
			availablefields.Push(value)
	}
	arraylen := availablefields.Length
	;no allowed fields exist for this nectar
	if (arraylen = 0)
		arr[2] := "None"
	;find index of last nectar field
	for k, v in availablefields {
		;found index of last nectar field in availablefields
		if (v = Last%currentNectar%Field)
		{
			arr[2] := availablefields[Mod(k, arrayLen) + 1]
			break
		}
	}
	if !arr[2]
		arr[1] := availablefields[1], arr[2] := availablefields.Has(2) ? availablefields[2] : availablefields[1]
	return arr
}

GetNextPlanter(nextfield) {
	;determine available planters
	tempFieldName := StrReplace(nextfield, " ", "")
	tempArrayName := (tempFieldName . "Planters")
	arrayLen := IsSet(%tempFieldName%Planters) ? %tempFieldName%Planters.Length : 0
	nextPlanterName := "none"
	nextPlanterNectarBonus := 0
	nextPlanterGrowBonus := 0
	nextPlanterGrowTime := 0
	Loop arrayLen {
		tempPlanter := Trim(%tempFieldName%Planters[A_Index][1])
		tempPlanterCheck := %tempPlanter%Allowed
		if (tempPlanterCheck && tempPlanter != PlanterName1 && tempPlanter != PlanterName2 && tempPlanter != PlanterName3)
		{
			if !InStr(LostPlanters, tempPlanter)
			{
				nextPlanterName := %tempFieldName%Planters[A_Index][1]
				nextPlanterNectarBonus := %tempFieldName%Planters[A_Index][2]
				nextPlanterGrowBonus := %tempFieldName%Planters[A_Index][3]
				nextPlanterGrowTime := %tempFieldName%Planters[A_Index][4]
				break
			}
		}
	}
	return [nextPlanterName, nextPlanterNectarBonus, nextPlanterGrowBonus, nextPlanterGrowTime]
}

PlacePlanter(fieldName, planter, planterNum, atField := 0) {
	global maxAllowedPlanters
	SetShiftLock(0)

	planterName := planter[1]
	planterNameStatus := (planterName = "blueclay" ? "Blue Clay" : (planterName = "redclay") ? "Red Clay" : (planterName = "heattreated") ? "Heat-Treated" : StrTitle(planterName)) . " Planter"
	fieldNameStatus := (fieldName = "pinetree") ? "Pine Tree"
		: (fieldName = "mountaintop") ? "Mountain Top"
		: (fieldName = "blueflower") ? "Blue Flower"
		: StrTitle(fieldName)
	if (atField = 0)
	{
		ResetToHive()
		OpenMenu("itemmenu")
		SetStatus("Traveling", (planterNameStatus . " (" . fieldNameStatus . ")"))
		gotoPlanter(fieldName, 0)
	}

	planterPos := InventorySearch(planterName, "up", 4)

	if (planterPos = 0) ; planter not in inventory
	{
		SetStatus("Missing", planterNameStatus)
		LostPlanters .= planterName
		return 0
	}
	else
	{
		GetRobloxClientPos()
		MouseMove windowX + planterPos[1], windowY + planterPos[2]
	}

	SetStatus("Placing", planterNameStatus)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|" windowWidth // 2 "|" Max(480, windowHeight - offsetY - 150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						SetStatus("Missing", planterName)
						LostPlanters .= planterName
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|" windowWidth // 2 "|" Max(480, windowHeight - offsetY - 150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[planterName], &planterPos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth // 2 - 250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX + 30, windowY + SubStr(planterPos, InStr(planterPos, ",") + 1) + 190, windowX + windowWidth // 2, windowY + windowHeight // 2, 5
		Sleep 200
	}
	Loop 50
	{
		GetRobloxClientPos(hwnd)
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
				MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
				Sleep 800
				Click
				Sleep 300
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
					Sleep 200
					Click
					MouseClick("Left")
				}
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX + 350, windowY + offsetY + 100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50 ; delay in case of lag
		}

		if (A_Index = 50) {
			SetStatus("Missing", planterName)
			LostPlanters .= planterName
			return 0
		}

		Sleep 100
	}

	Loop 10
	{
		Sleep 100
		imgPos := ImgSearch("3Planters.png", 30, "lowright")
		If (imgPos[1] = 0) {
			maxAllowedPlanters := max(0, maxAllowedPlanters - 1)
			SetStatus("Error", "3 Planters already placed!`nMax Planters has been set to " . maxAllowedPlanters . ".")
			Sleep 500
			return 3
		}
		imgPos := ImgSearch("planteralready.png", 30, "lowright")
		If (imgPos[1] = 0) {
			return 2
		}
		imgPos := ImgSearch("standing.png", 30, "lowright")
		If (imgPos[1] = 0) {
			return 4
		}
	}
	return 1
}

gotoPlanter(location, waitEnd := 1) {
	SetShiftLock(0)
	gtp_%StrReplace(location, " ")%()
}

PlanterTimeUpdate(FieldName, SetStatuss := 1)
{
	global
	local i, field, k, v, r := 0, PlanterGrowTime, PlanterBarProgress, CurrentPlanterBarProgress, NewPlanterBarProgress, VerifiedPlanterBarProgress

	Loop 3
	{
		i := A_Index
		if (harvestFullGrown && PlanterField%i% = FieldName)
		{
			field := StrReplace(FieldName, " ")
			for k, v in %field%Planters
			{
				if (v[1] = PlanterName%i%)
				{
					PlanterGrowTime := v[4]
					break
				}
			}

			sendinput "{" RotUp " 4}"
			Sleep 200

			; get prior PlanterBarProgress bounds for comparison
			CurrentPlanterBarProgress := 1 - ((PlanterHarvestTime%i% -nowUnix()) / 3600 / PlanterGrowTime)  ; PlanterBarProgress0

			Loop 20
			{
				if (((PlanterBarProgress := PlanterDetection()) > 0) && PlanterBarProgress <= 1)
				{
					; if new estimate within +/-10%, update
					if (Abs(PlanterBarProgress - CurrentPlanterBarProgress) <= 0.10)
					{
						PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
						writeSettings("Planters", "PlanterHarvestTime" %i%, PlanterHarvestTime%i%, "settings\timers.ini")
						(SetStatuss) && SetStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress * 100) "%")
						;NewPlanterBarProgress := PlanterBarProgress  ; variable only needed here for testing status update
						break
					}
					else ; if new estimate not within +/-10%, screenshot again
					{
						NewPlanterBarProgress := PlanterBarProgress  ; PlanterBarProgress1

						sleep 2000

						sendinput "{" RotRight " 2}"
						sleep 100
						PlanterBarProgress := PlanterDetection()
						sendinput "{" RotLeft " 2}"
						sleep 100

						; if second screenshot within +/-10% of first, update
						if ((PlanterBarProgress > 0) && (PlanterBarProgress <= 1) && (Abs(PlanterBarProgress - NewPlanterBarProgress) <= 0.10))
						{
							VerifiedPlanterBarProgress := PlanterBarProgress  ; PlanterBarProgress2, variable only needed for testing status update
							PlanterBarProgress := (NewPlanterBarProgress + PlanterBarProgress) / 2

							PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
							writeSettings("Planters", "PlanterHarvestTime" %i%, PlanterHarvestTime%i%, "settings\timers.ini")
							(SetStatuss) && SetStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress * 100) "%")
							break
						}
					}
				}

				Sleep 100
				sendinput "{" ZoomOut "}"
				if (A_Index = 10)
				{
					sendinput "{" RotLeft " 2}"
					r := 1
				}
			}
			sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
			Sleep 500
		}
	}
}

PlanterDetection()
{
	static pBMProgressStart, pBMProgressEnd, pBMRemain

	;defines the bitmaps via hex color
	if !(IsSet(pBMProgressStart) && IsSet(pBMProgressEnd) && IsSet(pBMRemain))
	{
		pBMProgressStart := Gdip_CreateBitmap(1, 8)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressStart), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMProgressEnd := Gdip_CreateBitmap(1, 2)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressEnd), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMRemain := Gdip_CreateBitmap(1, 8)
		pGraphics := Gdip_GraphicsFromImage(pBMRemain), Gdip_GraphicsClear(pGraphics, 0xff567848), Gdip_DeleteGraphics(pGraphics)
	}

	ActivateRoblox()
	GetRobloxClientPos()
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)

	if ((sPlanterStart := Gdip_ImageSearch(pBMScreen, pBMProgressStart, &PStart, , , , , , , 5)) = 1) {
		x := SubStr(PStart, 1, InStr(PStart, ",") - 1), y := SubStr(PStart, InStr(PStart, ",") + 1)
		sPlanterEnd := Gdip_ImageSearch(pBMScreen, pBMProgressEnd, &PEnd, x, y, , y + 2, , , 8)
		sPBarEnd := Gdip_ImageSearch(pBMScreen, pBMRemain, &PBarEnd, x, y, , y + 8, , , 8)
	}

	Gdip_DisposeImage(pBMScreen)

	if !((sPlanterStart = 0) || (sPlanterEnd = 0) || (sPBarEnd = 0))
	{
		cx2 := SubStr(PEnd, 1, InStr(PEnd, ",") - 1) + 1, dx2 := SubStr(PBarEnd, 1, InStr(PBarEnd, ",") - 1) + 1
		PlanterBarRemain := Round((dx2 - cx2) / (dx2 - x) * 100, 2)
		PlanterBarProgress := (cx2 - x) / (dx2 - x)
		return PlanterBarProgress
	}
	else
		return 0
}