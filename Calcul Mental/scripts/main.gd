extends Node2D

var LOIS = {
	"+": {'level':1, 'nums':5, 'xp+':1, 'xp-':1},
	"-": {'level':2, 'nums':5, 'xp+':2, 'xp-':1},
	"x": {'level':3, 'nums':4, 'xp+':5, 'xp-':2},
	"/": {'level':4, 'nums':3, 'xp+':10, 'xp-':2},
	"^": {'level':5, 'nums':0, 'xp+':20, 'xp-':2},
	"≡": {'level':6, 'nums':5, 'xp+':10, 'xp-':2},
	"√": {'level':7, 'nums':3, 'xp+':25, 'xp-':4},
}

var PLAY
var SOL
var XP

var xp_file = "user://xp.save"

func hide_numpad():
	%Suivant.hide()
	%"0".hide()
	%"1".hide()
	%"2".hide()
	%"3".hide()
	%"4".hide()
	%"5".hide()
	%"6".hide()
	%"7".hide()
	%"8".hide()
	%"9".hide()
	%"-".hide()

func show_numpad():
	%Suivant.show()
	%"0".show()
	%"1".show()
	%"2".show()
	%"3".show()
	%"4".show()
	%"5".show()
	%"6".show()
	%"7".show()
	%"8".show()
	%"9".show()
	%"-".show()

func _ready():
	%Name.text = "Calcul - Menu"
	%Home.show()
	
	%Play.show()
	
	%Eq.hide()
	%Sol.hide()
	hide_numpad()
	%Res.hide()
	
	load_xp()
	update_xp()
	
	PLAY = false

func load_xp():
	XP = 2
	if FileAccess.file_exists(xp_file):
		var f = FileAccess.open(xp_file, FileAccess.READ)
		XP = int(f.get_var())
	return XP

func save_xp():
	var f = FileAccess.open(xp_file, FileAccess.WRITE)
	f.store_var(XP)

func update_xp():
	if XP < 2:
		XP = 2
	var xp = "LVL {LVL} - {REM}/{TOT}"
	var lvl = floor(log(XP)/log(2))
	var tot = 2**lvl
	var rem = XP - tot
	xp = xp.format({ "LVL":str(lvl), "REM":str(rem), "TOT": str(tot)})
	%LVL.text = xp
	save_xp()

func _on_home_pressed():
	%Play.show()
	%Eq.hide()
	%Sol.hide()
	hide_numpad()
	%Res.hide()
	%Name.text = "Calcul - Menu"
	PLAY = false

func _on_play_pressed():
	%Play.hide()
	%Eq.show()
	%Sol.show()
	show_numpad()
	%Res.show()
	%Sol.text = ""
	%Res.text = ""
	%Name.text = "Calcul - Jeu"
	PLAY = true
	var calc = create_calc()
	%Eq.text = calc[0]
	SOL = calc[1]

func get_qualified_ns(loi, max_num,):
	var n1 = (  randi() % int(10**max_num)  ) +1
	var n2 = (  randi() % int(10**max_num)  ) +1
	if loi == "/":
		n1 = n1*n2
	if loi == "√":
		n1 = (floor(sqrt(n2)))**2
	return [ n1, n2 ]

func create_calc():
	var level = floor(log(XP)/log(2))
	var lois = []
	for loi in LOIS.keys():
		if 	LOIS[loi]['level'] <= level:
			lois.append(loi)
	var loi = lois[randi() % lois.size()]
	
	var max_num = min( level - LOIS[loi]['level'], LOIS[loi]['nums'] ) +1
	var ns = get_qualified_ns(loi, max_num)
	
	var eq = get_eq(ns,loi)
	var sol = get_sol(eq)
	
	return [eq, sol]

func get_eq(ns,loi):
	var eq
	match loi:
		"√":
			eq = "{loi} {n1} ="
			eq = eq.format({"n1":ns[0], "loi":loi})
		"≡":
			eq = "{n1} {loi} ? [{n2}]"
			eq = eq.format({"n1":ns[0], "n2":ns[1], "loi":loi})
		_:
			eq = "{n1} {loi} {n2} ="
			eq = eq.format({"n1":ns[0], "n2":ns[1], "loi":loi})
	return eq

func get_sol(eq):
	var elts = eq.split(" ", true, 3)
	match elts[1]:
		"+":
			return int(elts[0]) + int(elts[2])
		"-":
			return int(elts[0]) - int(elts[2])
		"x":
			return int(elts[0]) * int(elts[2])
		"/":
			return int(elts[0]) / int(elts[2])
		"^":
			return int(elts[0]) ** int(elts[2])
		"≡":
			return int(elts[0]) % int(elts[2])
		"√":
			return sqrt(elts[2])

func _on_suivant_pressed():
	if %Sol.text == "":
		var sol_text = "{res} c'est {sol}"
		sol_text = sol_text.format( { "res":["FAUX", "VRAI"][int(int(%Res.text) == SOL)], "sol": SOL } )
		%Sol.text = sol_text
		
		var loi = (%Eq.text).get_slice(" ", 1)
		var nb = len( (%Eq.text).get_slice(" ", 0) )
		
		if int(%Res.text) == SOL:
			XP += LOIS[loi]['xp+'] * nb
		else:
			XP -=  floor(  log(XP)/log(2) / LOIS[loi]['xp-']  )
		update_xp()
	else:
		var calc = create_calc()
		%Eq.text = calc[0]
		SOL = calc[1]
		%Sol.text = ""
		%Res.text = ""

func _on_numpad_pressed(extra_arg_0):
	%Res.text += extra_arg_0
