extends Node

export (int) var Morning = 4
export (int) var Afternoon = 12
export (int) var Night = 20
var Year
var Season
var weather
var Weather_List: Array

enum WEATHER{
	CLOUD
	SUN
	RAIN
	RAINSTORM
	SNOW
	BLIZZARD
	FOG
}
enum SEASON{
	SPRING
	SUMMER
	AUTUMN
	WINTER
}
func _ready() -> void :

	Weather_List = [
		WEATHER.SUN,
		WEATHER.SUN,
		WEATHER.SUN,
		WEATHER.SUN,
		WEATHER.SUN,
		WEATHER.SUN,
		WEATHER.SUN
	]
