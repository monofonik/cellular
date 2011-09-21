Object subclass: #ScratchCellAttribute
	instanceVariableNames: 'name min max spread colour hue default hidden '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!

!ScratchCellAttribute methodsFor: 'initialization' stamp: 'JM 9/20/2011 16:21'!
initialize

	name _ ''.
	min _ 0.
	max _ 100.
	spread = 0.
	colour _ Color fromString: 'red'.
	hue _ (Color fromString: 'white') hue.
	hidden _ false.! !


!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/20/2011 16:30'!
colour: aColour
	
	colour _ aColour.
	hue _ aColour hue "hangover from v2 of this class"! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/1/2011 11:52'!
default: aNumber

	default _ aNumber! !

!ScratchCellAttribute methodsFor: 'setters' stamp: 'JM 9/20/2011 12:36'!
hidden: aBoolean

	hidden _ aBoolean! !

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


!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/21/2011 14:25'!
colour

	^ colour! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/1/2011 11:53'!
default

	^ default! !

!ScratchCellAttribute methodsFor: 'getters' stamp: 'JM 9/20/2011 12:36'!
hidden

	^ hidden! !

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


!ScratchCellAttribute methodsFor: 'object i/o' stamp: 'JM 9/20/2011 16:21'!
fieldsVersion

	^ 3! !

!ScratchCellAttribute methodsFor: 'object i/o' stamp: 'JM 9/21/2011 14:02'!
initFieldsFrom: anObjStream version: classVersion

	self initFieldsNamed: #(
		name
		min
		max 
		spread
		hue
		default
	) from: anObjStream.

	colour _ Color h: hue s: 1 v: 1.
	colour _ colour alpha: 0.5.

	classVersion = 1 ifTrue: [ ^ self ].

	self initFieldsNamed: #(
		hidden
	) from: anObjStream.

	classVersion = 2 ifTrue: [ ^ self ].

	self initFieldsNamed: #(
		colour
	) from: anObjStream.! !

!ScratchCellAttribute methodsFor: 'object i/o' stamp: 'JM 9/20/2011 16:29'!
storeFieldsOn: anObjStream

	"super storeFieldsOn: anObjStream."
	self storeFieldsNamed: #(
		name
		min
		max 
		spread
		hue
		default
		hidden
		colour
	) on: anObjStream.

	! !
