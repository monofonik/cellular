Object subclass: #ScratchCellAttribute
	instanceVariableNames: 'name min max spread hue default '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!

!ScratchCellAttribute methodsFor: 'initialization' stamp: 'JM 9/1/2011 14:04'!
initialize

	name _ ''.
	min _ 0.
	max _ 100.
	spread _ 2.
	hue _ (Color fromString: 'white') hue! !


!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 11:52'!
default: aNumber

	default _ aNumber! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 14:04'!
hue: aNumber

	hue _ aNumber! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 10:42'!
max: aNumber

	max _ aNumber! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 10:41'!
min: aNumber

	min _ aNumber.! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 10:41'!
name: aString

	name _ aString.! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 10:42'!
spread: aNumber

	spread _ (aNumber max: 0) min: 3.! !


!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 11:53'!
default

	^ default! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 14:04'!
hue

	^ hue! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 10:43'!
max

	^ max! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 10:43'!
min

	^ min! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 10:43'!
name

	^ name! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 10:43'!
spread

	^ spread! !
