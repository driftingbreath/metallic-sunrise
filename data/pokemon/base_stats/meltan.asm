	db  46,  65,  65,  34,  55,  35 ; 300 BST
	;   hp  atk  def  spe  sat  sdf

	db STEEL, STEEL ; type
	db 15 ; catch rate
	db 135 ; base exp
	db NO_ITEM, NO_ITEM ; held items
	dn GENDER_UNKNOWN, HATCH_SLOWEST ; gender ratio, step cycles to hatch

	abilities_for MELTAN, MAGNET_PULL, LIMBER, GALVANIZE
	db GROWTH_SLOW ; growth rate
	dn EGG_NONE, EGG_NONE ; egg groups

	ev_yield 1 Atk

	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, PROTECT, THUNDERBOLT, RETURN, DOUBLE_TEAM, FLASH_CANNON, SWIFT, SUBSTITUTE, FACADE, REST, FLASH, THUNDER_WAVE, GYRO_BALL, BODY_SLAM, DEFENSE_CURL, HEADBUTT, IRON_HEAD, PAY_DAY
	; end
