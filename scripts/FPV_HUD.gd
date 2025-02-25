extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# FOV of camera the HMD is attached to 
var cam_fov : float = 60.0

# Distance of imaginary display
var display_distance : float

# Scaling factors for spacing between elements
var hud_scale_factor : Vector2 = Vector2.ONE

# Viewport centre 
var viewport_centre : Vector2 = Vector2(960, 540)

var tape_spd_ref = 0
var tape_spd_step = 10
var tape_spd_spacing = 100

var tape_alt_ref = 0
var tape_alt_step = 100
var tape_alt_spacing = 100

var tape_hdg_ref = 0
var tape_hdg_abv1 = 0
var tape_hdg_abv2 = 0
var tape_hdg_blw1 = 0
var tape_hdg_blw2 = 0

var tape_hdg_step = 10
var tape_hdg_spacing = 200

@export var hmd_power : bool = true
var hmd_blanked : bool = false

var fpv_angles : Vector3 = Vector3.ZERO

func _format_hdg(heading):
	if (heading  <= 0):
		heading += 360
	if (heading > 360):
		heading -= 360
	
	return heading


# Called when the node enters the scene tree for the first time.
func _ready():
	# Position and space elements that don't change size du8ring runtime
	$HUD_Centre/Tape_SPD/ABV1.position.y = \
		$HUD_Centre/Tape_SPD/REF0.position.y - 1 * tape_spd_spacing
	$HUD_Centre/Tape_SPD/ABV2.position.y = \
		$HUD_Centre/Tape_SPD/REF0.position.y - 2 * tape_spd_spacing
	$HUD_Centre/Tape_SPD/BLW1.position.y = \
		$HUD_Centre/Tape_SPD/REF0.position.y + 1 * tape_spd_spacing
	$HUD_Centre/Tape_SPD/BLW2.position.y = \
		$HUD_Centre/Tape_SPD/REF0.position.y + 2 * tape_spd_spacing

	
	$HUD_Centre/Tape_ALT/ABV1.position.y = \
		$HUD_Centre/Tape_ALT/REF0.position.y - 1 * tape_alt_spacing
	$HUD_Centre/Tape_ALT/ABV2.position.y = \
		$HUD_Centre/Tape_ALT/REF0.position.y - 2 * tape_alt_spacing
	$HUD_Centre/Tape_ALT/BLW1.position.y = \
		$HUD_Centre/Tape_ALT/REF0.position.y + 1 * tape_alt_spacing
	$HUD_Centre/Tape_ALT/BLW2.position.y = \
		$HUD_Centre/Tape_ALT/REF0.position.y + 2 * tape_alt_spacing
	
#	DebugOverlay.stats.add_property(self, "fpv_angles", "round")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Find viewport centre
	viewport_centre = get_viewport_rect().size/2

	$EADI.position = viewport_centre
	
	$EADI.position.x = viewport_centre.x
	$EADI.position.y = viewport_centre.y
	
	$HUD_Centre.position = viewport_centre
	
	# Position boresight indicator
	$Boresight.position = \
		viewport_centre - 5 * hud_scale_factor * Vector2(-fpv_angles.y, -fpv_angles.x)
	
	# Keep aircraft symbol pointing at boresight
	$EADI/Aircraft.position.x = \
		display_distance * tan(deg_to_rad(fpv_angles.y))
	$EADI/Aircraft.position.y = \
		display_distance * tan(deg_to_rad(fpv_angles.x))
	
	# HUD scaling
	hud_scale_factor = get_viewport_rect().size / Vector2(1920, 1080)
	
	$HUD_Centre.scale = hud_scale_factor
	$EADI.texture_scale = hud_scale_factor.y
	$Compass.scale = Vector2(hud_scale_factor.y, hud_scale_factor.y)
	
	# Calculate the virtual distance the HUD is positioned for
	display_distance = viewport_centre.y / tan(deg_to_rad(cam_fov / 2))
#	
	if (AeroDataBus.aircraft_cam_rotation_deg.length() <= 5):
		$Boresight.visible = false
	else:
		$Boresight.visible = true
	
	fpv_angles = AeroDataBus.aircraft_cam_rotation_deg
	
	$EADI/XForm_Roll.rotation_degrees = AeroDataBus.aircraft_cam_global_rotation_deg.z
	$EADI/XForm_Roll/XForm_Pitch.position.y = \
		AeroDataBus.aircraft_cam_global_rotation_deg.x * get_viewport_rect().size.y/cam_fov
#		display_distance * tan(deg2rad(AeroDataBus.aircraft_pitch))

	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P02.position.y = \
		-2.5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N02.position.y = \
		2.5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P05.position.y = \
		-5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N05.position.y = \
		5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P10.position.y = \
		-10 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N10.position.y = \
		10 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P20.position.y = \
		-20 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N20.position.y = \
		20 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Waterline.position.y = \
		3 * get_viewport_rect().size.y/cam_fov
	
	if (AeroDataBus.aircraft_gear == 0):
		$EADI/XForm_Roll/XForm_Pitch/Horizon/Waterline.visible = false
	else:
		$EADI/XForm_Roll/XForm_Pitch/Horizon/Waterline.visible = true
	
	$EADI/FPM.position.x = \
		display_distance * tan(deg_to_rad(-AeroDataBus.aircraft_nu))
	$EADI/FPM.position.y = \
		display_distance * tan(deg_to_rad(AeroDataBus.aircraft_mu))
	
	# Waypoint indications
	if (\
	(AeroDataBus.aircraft_nav_active == true) && \
	(abs(AeroDataBus.aircraft_nav_waypoint_data.x) <= 90) && \
	(abs(AeroDataBus.aircraft_nav_waypoint_data.y) <= 90) \
		):
		$EADI/Aircraft/Marker_WPT.visible = true
		$EADI/Aircraft/Marker_WPT.position.x = \
			display_distance * tan(deg_to_rad(AeroDataBus.aircraft_nav_waypoint_data.x))
		$EADI/Aircraft/Marker_WPT.position.y = \
			display_distance * tan(deg_to_rad(-AeroDataBus.aircraft_nav_waypoint_data.y))
		$EADI/Aircraft/Marker_WPT.rotation_degrees = -AeroDataBus.aircraft_roll
	else:
		$EADI/Aircraft/Marker_WPT.visible = false
		$EADI/Aircraft/Marker_WPT.position = Vector2.ZERO
		$EADI/Aircraft/Marker_WPT.rotation = 0
	
	$Compass.position.x = viewport_centre.x
	$Compass.position.y = viewport_centre.y + 400 * (get_viewport_rect().size.y / 1080)
	$Compass/Rose.rotation_degrees = -AeroDataBus.aircraft_hdg
	$Compass/Needle.rotation_degrees = AeroDataBus.aircraft_nav_waypoint_data.x
	
#	get_node("Speed_Data").text = ("SPD\n%03d" % [AeroDataBus.aircraft_spd_indicated])
#	get_node("Alt_Data").text = ("ALT\n%05d" % [AeroDataBus.aircraft_alt_barometric])
#	get_node("Heading_Data").text = ("HDG\n%03d" % [AeroDataBus.aircraft_hdg])

	tape_spd_ref = snapped(AeroDataBus.aircraft_spd_indicated, tape_spd_step)
	$HUD_Centre/Tape_SPD/REF0.text = ("%03d -" % [tape_spd_ref])
	$HUD_Centre/Tape_SPD/ABV1.text = ("%03d -" % [tape_spd_ref + 1 * tape_spd_step])
	$HUD_Centre/Tape_SPD/ABV2.text = ("%03d -" % [tape_spd_ref + 2 * tape_spd_step])
	$HUD_Centre/Tape_SPD/BLW1.text = ("%03d -" % [tape_spd_ref - 1 * tape_spd_step])
	$HUD_Centre/Tape_SPD/BLW2.text = ("%03d -" % [tape_spd_ref - 2 * tape_spd_step])
	
	if(tape_spd_ref <= 5): 
		$HUD_Centre/Tape_SPD/BLW1.visible = false
		$HUD_Centre/Tape_SPD/BLW2.visible = false
	else:
		$HUD_Centre/Tape_SPD/BLW1.visible = true
		$HUD_Centre/Tape_SPD/BLW2.visible = true
	
	$HUD_Centre/Tape_SPD.position.y = \
		(AeroDataBus.aircraft_spd_indicated - tape_spd_ref) * (tape_spd_spacing / tape_spd_step)
	
	tape_alt_ref = snapped(AeroDataBus.aircraft_alt_barometric, tape_alt_step)
	$HUD_Centre/Tape_ALT/REF0.text = ("- %05d" % [tape_alt_ref])
	$HUD_Centre/Tape_ALT/ABV1.text = ("- %05d" % [tape_alt_ref + 1 * tape_alt_step])
	$HUD_Centre/Tape_ALT/ABV2.text = ("- %05d" % [tape_alt_ref + 2 * tape_alt_step])
	$HUD_Centre/Tape_ALT/BLW1.text = ("- %05d" % [tape_alt_ref - 1 * tape_alt_step])
	$HUD_Centre/Tape_ALT/BLW2.text = ("- %05d" % [tape_alt_ref - 2 * tape_alt_step])
	
	if(tape_alt_ref <= 0): 
		$HUD_Centre/Tape_ALT/BLW1.visible = false
		$HUD_Centre/Tape_ALT/BLW2.visible = false
	else:
		$HUD_Centre/Tape_ALT/BLW1.visible = true
		$HUD_Centre/Tape_ALT/BLW2.visible = true
	
	$HUD_Centre/Tape_ALT.position.y = \
		(AeroDataBus.aircraft_alt_barometric - tape_alt_ref) * (tape_alt_spacing / tape_alt_step)
	

	tape_hdg_ref = snapped(AeroDataBus.aircraft_hdg, tape_hdg_step)
	tape_hdg_abv1 = _format_hdg(tape_hdg_ref + 1 * tape_hdg_step)
	tape_hdg_abv2 = _format_hdg(tape_hdg_ref + 2 * tape_hdg_step)
	tape_hdg_blw1 = _format_hdg(tape_hdg_ref - 1 * tape_hdg_step)
	tape_hdg_blw2 = _format_hdg(tape_hdg_ref - 2 * tape_hdg_step)
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.text = ("%03d\n|" % [_format_hdg(tape_hdg_ref)])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV1.text = ("%03d\n|" % [_format_hdg(tape_hdg_abv1)])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV2.text = ("%03d\n|" % [_format_hdg(tape_hdg_abv2)])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW1.text = ("%03d\n|" % [_format_hdg(tape_hdg_blw1)])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW2.text = ("%03d\n|" % [_format_hdg(tape_hdg_blw2)])
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG.position.x = \
		-(AeroDataBus.aircraft_hdg - tape_hdg_ref) * (tape_hdg_spacing / tape_hdg_step)
	
	tape_hdg_spacing = 10 * get_viewport_rect().size.y/cam_fov
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV1.position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.position.x + 1 * tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV2.position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.position.x + 2 * tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW1.position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.position.x - 1 * tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW2.position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.position.x - 2 * tape_hdg_spacing
	
	$HUD_Centre/Indicator_THR.value = AeroDataBus.aircraft_throttle * 100
	$HUD_Centre/Indicator_FLAPS.value = AeroDataBus.aircraft_flaps
	
	$HUD_Centre/Indicator_TRIM/Caret.position.y = AeroDataBus.aircraft_trim * 50
	$HUD_Centre/Indicator_TRIM/Label.text = ("TRIM %+0.1f" % [AeroDataBus.aircraft_trim])
	
	if (AeroDataBus.aircraft_cws == 0):
		$HUD_Centre/Status_CWS.visible = false
	if (AeroDataBus.aircraft_cws == 1):
		$HUD_Centre/Status_CWS.visible = true
	
	if (AeroDataBus.aircraft_alt_radio < 2500):
		$HUD_Centre/RadioAlt.visible = true
	else:
		$HUD_Centre/RadioAlt.visible = false
	
	$HUD_Centre/RadioAlt/Label.text = ("RA\n%d" % [AeroDataBus.aircraft_alt_radio])
	
	# Scale symbols
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P05.scale = Vector2.ONE * hud_scale_factor
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N05.scale = Vector2.ONE * hud_scale_factor
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P10.scale = Vector2.ONE * hud_scale_factor
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N10.scale = Vector2.ONE * hud_scale_factor
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P20.scale = Vector2.ONE * hud_scale_factor
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N20.scale = Vector2.ONE * hud_scale_factor
	$EADI/FPM.scale = Vector2.ONE * hud_scale_factor
	$EADI/Mark_Angles.scale = Vector2.ONE * hud_scale_factor
	$EADI/XForm_Roll/Indicator_Roll.scale = Vector2.ONE * hud_scale_factor
	$HUD_Centre/RadioAlt.scale = Vector2.ONE * hud_scale_factor
	
	#$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.rect_scale = Vector2.ONE * hud_scale_factor
