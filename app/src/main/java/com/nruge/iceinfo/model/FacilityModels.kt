package com.nruge.iceinfo.model

enum class FacilityType {
    ELEVATOR, ESCALATOR, TOILET, WIFI, INFO_DESK, DEPARTURE_MONITOR,
    RAMP, PARKING, BIKE_PARKING, WAITING_ROOM
}

enum class FacilityStatus { ACTIVE, INACTIVE, UNKNOWN }

data class StationFacility(
    val id: String,
    val type: FacilityType,
    val label: String,
    val status: FacilityStatus,
    val description: String = ""
)

data class StationInfo(
    val evaNr: String,
    val name: String,
    val liveFacilities: List<StationFacility> = emptyList(),
    val staticFacilities: List<FacilityType> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

data class StationSearchResult(
    val evaNr: String,
    val name: String
)
