Object subclass: #ScratchCellAttribute
	instanceVariableNames: 'name min max spread hue default '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!

!ScratchCellAttribute methodsFor: 'initialization' stamp: 'JM 9/15/2011 14:26'!
initialize

	name _ ''.
	min _ 0.
	max _ 100.
	spread = 0.
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

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/15/2011 14:45'!
spread: aNumber

	spread _ (aNumber max: 0) min: 4.! !


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


!ScratchCellAttribute methodsFor: 'object i/o' stamp: 'JM 9/15/2011 14:24'!
fieldsVersion

	^ 1! !

!ScratchCellAttribute methodsFor: 'object i/o' stamp: 'JM 9/15/2011 14:26'!
initFieldsFrom: anObjStream version: classVersion

	self initFieldsNamed: #(
		name
		min
		max 
		spread
		hue
		default
	) from: anObjStream.

	self fieldsVersion = 1 ifTrue: [ ^ self ].! !

!ScratchCellAttribute methodsFor: 'object i/o' stamp: 'JM 9/15/2011 14:27'!
storeFieldsOn: anObjStream

	"super storeFieldsOn: anObjStream."
	self storeFieldsNamed: #(
		name
		min
		max 
		spread
		hue
		default
	) on: anObjStream.

	! !
