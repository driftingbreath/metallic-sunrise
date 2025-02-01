	db  46,  65,  65,  34, 55,  35 ; 310 BST
	;   hp  atk  def  spe  sat  sdf

	db STEEL, STEEL ; type
	db 3 ; catch rate
	db 135 ; base exp
	db NO_ITEM, NO_ITEM ; held items
	dn GENDER_UNKNOWN, HATCH_UNKNOWN ; gender ratio, step cycles to hatch

	abilities_for MELTAN, MAGNET_PULL, MAGNET_PULL, MAGNET_PULL
	db GROWTH_SLOW ; growth rate
	dn EGG_NONE, EGG_NONE ; egg groups

	ev_yield 1 Atk

	; tm/hm learnset, temporarily dummied out
	tmhm TOXIC, HIDDEN_POWER
	; end
