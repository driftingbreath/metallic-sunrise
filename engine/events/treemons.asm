TreeItemEncounter:
	call Random
	cp 15 percent
	jr c, .silver_leaf
	cp 30 percent
	jr c, .gold_leaf
	ld a, NO_ITEM
	jr .item
.silver_leaf
	ld a, SILVER_LEAF
	jr .item
.gold_leaf
	ld a, GOLD_LEAF
.item
	ldh [hScriptVar], a
	ret

RockItemEncounter:
	ld hl, .RockItems
	call Random
.loop
	sub [hl]
	jr c, .ok
	inc hl
	inc hl
	jr .loop
.ok
	ld a, [hli]
	cp -1
	ld a, NO_ITEM
	jr z, .done
	ld a, [hl]
.done
	ldh [hScriptVar], a
	ret

.RockItems:
	db 1, HELIX_FOSSIL
	db 1, DOME_FOSSIL
	db 1, OLD_AMBER
	db 1, BIG_NUGGET
	db 2, RARE_BONE
	db 4, NUGGET
	db 6, STAR_PIECE
	db 12, BIG_PEARL
	db 18, STARDUST
	db 24, HARD_STONE
	db 24, SOFT_SAND
	db 48, PEARL
	db 64, BRICK_PIECE
	db 48, NO_ITEM
	db -1

TreeMonEncounter:
	xor a
	ld [wTempWildMonSpecies], a
	ld [wCurPartyLevel], a

	ld hl, TreeMonMaps
	call GetTreeMonSet
	jr nc, .no_battle

	call GetTreeMons
	jr nc, .no_battle

	call GetTreeMon
	jr nc, .no_battle

	ld a, BATTLETYPE_TREE
	ld [wBattleType], a
	ld a, 1
	ldh [hScriptVar], a
	ret

.no_battle
	xor a
	ldh [hScriptVar], a
	ret

RockMonEncounter:

	xor a
	ld [wTempWildMonSpecies], a
	ld [wCurPartyLevel], a

	ld hl, RockMonMaps
	call GetTreeMonSet
	jr nc, .no_battle

	call GetTreeMons
	jr nc, .no_battle

	ld a, 10
	call RandomRange
	cp 4
	jr nc, .no_battle

	call SelectTreeMon
	ret c

.no_battle
	xor a
	ret

GetTreeMonSet:
; Return carry and treemon set in a
; if the current map is in table hl.
	ld a, [wMapNumber]
	ld e, a
	ld a, [wMapGroup]
	ld d, a
.loop
	ld a, [hli]
	cp -1
	jr z, .not_in_table

	cp d
	jr nz, .skip2

	ld a, [hli]
	cp e
	jr nz, .skip1

	jr .in_table

.skip2
	inc hl
.skip1
	inc hl
	jr .loop

.not_in_table
	xor a
	ret

.in_table
	ld a, [hl]
	scf
	ret

INCLUDE "data/wild/treemon_maps.asm"

GetHeadbuttLocations:
; Writes to wDexAreaMons. Assumes we're in the correct WRAM bank for this.
; Parameters: e = type, d = region, c = species, b = form.
	push de

	; Clear area locator data.
	ld hl, wDexAreaValidTreeGroups
	push bc
	ld bc, NUM_TREEMON_SETS
	xor a
	rst ByteFill
	pop bc

	; Figure out which treemon sets have this mon.
	ld d, a

	; If this loop finishes with carry flag still set, return afterwards since
	; we didn't find anything.
	scf
	push af
.moncheck_loop
	push de
	call GetTreeMons

	; For whatever reason, headbutt encounters use 2 tables per set, each using
	; a seperator. Thus, we perform the mon check twice...
	call .CheckTable
	call c, .CheckTable
	pop de
	call nc, .AppendTreeSet ; This function screws with previously pushed af.
	inc d
	ld a, d
	cp TREEMON_SET_ROCK
	jr nz, .moncheck_loop

	; Check if the mon occupies any slot
	pop af
	pop de
	ret c

	; The mon occupies at least one slot.
	scf
	ret

.CheckTable:
; Checks if the headbutt table in hl has the given mon in bc. Return nc if yes.
	ld a, [hli]
	add 1 ; sets carry if we found the terminator
	ret c

	ld a, [hli]
	cp c
	ld a, [hli]
	inc hl ; skip level
	jr nz, .CheckTable
	call DexCompareWildForm
	jr nz, .CheckTable
	ret

.AppendTreeSet:
	ld a, LOW(wDexAreaValidTreeGroups)
	add d
	ld h, HIGH(wDexAreaValidTreeGroups)
	ld l, a
	ld [hl], 1

	; Resets carry on previously pushed af.
	pop hl ; return addr
	pop af
	and a
	push af
	jp hl

GetTreeMons:
; Return the address of TreeMon table a in hl.
; Return nc if table a doesn't exist.

	cp NUM_TREEMON_SETS
	jr nc, .quit

	ld e, a
	ld d, 0
	ld hl, TreeMons
	add hl, de
	add hl, de

	ld a, [hli]
	ld h, [hl]
	ld l, a

	scf
	ret

.quit
	xor a
	ret

INCLUDE "data/wild/treemons.asm"

GetTreeMon:
	push hl
	call GetTreeScore
	pop hl
	and a
	jr z, .bad
	cp 1
	jr z, .good
	cp 2
	jr z, .rare
	ret

.bad
	ld a, 10
	call RandomRange
	and a
	jr nz, NoTreeMon
	jr SelectTreeMon

.good
	ld a, 10
	call RandomRange
	cp 5
	jr nc, NoTreeMon
	jr SelectTreeMon

.rare
	ld a, 10
	call RandomRange
	cp 8
	jr nc, NoTreeMon
.skip
	ld a, [hli]
	cp -1
	jr nz, .skip
	; fallthrough

SelectTreeMon:
; Read a TreeMons table and pick one monster at random.
	ld a, 100
	call RandomRange
.loop
	sub [hl]
	jr c, .ok
	inc hl
	inc hl
	inc hl
	inc hl
	jr .loop

.ok
	ld a, [hli]
	cp -1
	jr z, NoTreeMon

	ld a, [hli]
	ld [wTempWildMonSpecies], a
	ld a, [hli]
	ld [wCurForm], a
	ld a, [hl]
	ld [wCurPartyLevel], a
	scf
	ret

NoTreeMon:
	xor a
	ld [wTempWildMonSpecies], a
	ld [wCurPartyLevel], a
	ret

GetTreeScore:
	call .CoordScore
	ld [wBuffer1], a
	call .OTIDScore
	ld [wBuffer2], a
	ld c, a
	ld a, [wBuffer1]
	sub c
	jr z, .rare
	jr nc, .ok
	add 10
.ok
	cp 5
	jr c, .good

.bad
	xor a
	ret

.good
	ld a, 1
	ret

.rare
	ld a, 2
	ret

.CoordScore:
	call GetFacingTileCoord
	ld hl, 0
	ld c, e
	ld b, 0
	ld a, d

	and a
	jr z, .next
.loop
	add hl, bc
	dec a
	jr nz, .loop
.next

	add hl, bc
	ld c, d
	add hl, bc

	ld a, h
	ldh [hDividend], a
	ld a, l
	ldh [hDividend + 1], a
	ld a, 5
	ldh [hDivisor], a
	ld b, 2
	call Divide

	ldh a, [hQuotient + 1]
	ldh [hDividend], a
	ldh a, [hQuotient + 2]
	ldh [hDividend + 1], a
	ld a, 10
	ldh [hDivisor], a
	ld b, 2
	call Divide

	ldh a, [hQuotient + 3]
	ret

.OTIDScore:
	ld a, [wPlayerID]
	ldh [hDividend], a
	ld a, [wPlayerID + 1]
	ldh [hDividend + 1], a
	ld a, 10
	ldh [hDivisor], a
	ld b, 2
	call Divide
	ldh a, [hQuotient + 3]
	ret
