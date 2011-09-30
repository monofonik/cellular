Object subclass: #ScratchCell
	instanceVariableNames: 'stage gridLocation color values colors changing damaged '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!

!ScratchCell methodsFor: 'initialization' stamp: 'JM 9/29/2011 14:45'!
initialize

	super initialize.
	values _ Dictionary new.
	colors _ Dictionary new.
	color _ (Color fromString: 'transparent'). "default cell color with no attributes"
	changing _ false.
	damaged _ true.
! !

!ScratchCell methodsFor: 'initialization' stamp: 'JM 9/28/2011 10:23'!
mouseDown: evt

	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		self handleTool: evt hand toolType hand: evt hand.
	].
! !

!ScratchCell methodsFor: 'initialization' stamp: 'JM 9/28/2011 10:23'!
mouseEnterDragging: evt

	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		self handleTool: evt hand toolType hand: evt hand.
	].
! !


!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
attribute: aString

	^ self stage attribute: aString! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:51'!
cellAttribute: aString

	^ stage cellAttribute: aString! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:51'!
changeValue: aString by: aNumber

	| spread |
	spread _ (stage cellAttribute: aString) spread.
	self changeValue: aString by: aNumber spread: spread.! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:51'!
changeValue: aString by: aNumber spread: aSpread

	" check for a spread amount and update neighbouring cells "
	| cellAttr min max oldValue newValue |	

	changing ifTrue: [ ^ self ].
	changing _ true.

	cellAttr _ stage cellAttribute: aString.
	cellAttr ifNil: [ ^ self ].

	min _ cellAttr min.
	max _ cellAttr max.
	
	oldValue _ self value: aString.

	aSpread > 0 ifTrue: [ 
		"spread the value to adjacent cells, halving each time"
		(stage adjacentCellsTo: self) do: [ :cell | cell changeValue: aString by: aNumber * (1 - (1 / aSpread)) spread: aSpread - 1 ].
	].

	newValue _ (((oldValue + aNumber) min: max) max: min).
	
	oldValue = newValue ifFalse: [
		values at: aString put: newValue.
		self update.
	].

	changing _ false.
	! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:51'!
clearValue: aString

	| spread |
	spread _ (stage cellAttribute: aString) spread.
	
	self clearValue: aString spread: spread.! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
clearValue: aString spread: aSpread
	
	self changeValue: aString by: (values at: aString ifAbsent: [ ^ 0 ]) negated spread: aSpread! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
clearValues

	"clears all values for this cell with zero spread"
	values keys do: [ :key |
		self setValue: key to: ((self cellAttribute: key) default) spread: 0.
	].

	self update.! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 11:18'!
damaged

	^ damaged! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
deleteValue: aString

	values removeKey: aString ifAbsent: [ ].
	colors removeKey: aString ifAbsent: [ ]! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
gridLocation

	^ gridLocation! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
gridLocation: aPoint

	gridLocation _ aPoint.! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
handleTool: toolName hand: hand

	| frame attrName attr tenPC toolSpread  |

	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [ ^ self ].
	
	attrName _ frame selectedAttribute.

	attr _ self cellAttribute: attrName.
	attr ifNil: [ ^ self ].

	tenPC _ attr max - attr min / 10.

	toolSpread _ frame brushSize.


	toolName = 'PaintTool' ifTrue: [ ^ self changeValue: attrName by: tenPC spread: toolSpread ].
	toolName = 'EraseTool' ifTrue: [ ^ self changeValue: attrName by: tenPC negated spread: toolSpread ].

	


! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
handlesMouseDown: evt

	^ true! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
handlesMouseOverDragging: evt

	^ true! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 11:19'!
redrawn

	damaged _ false! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
referencePosition

	| p |
	p _ (bounds origin + 5) - owner class scratchOrigin.
	^ p x @ p y negated! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:52'!
setValue: aString to: aNumber

	| spread |
	
	spread _ (stage cellAttribute: aString) spread.
	self setValue: aString to: aNumber spread: spread.! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
setValue: aString to: aNumber spread: aSpread

	| oldval |
	oldval _ self value: aString.
	self changeValue: aString by: aNumber - oldval spread: aSpread! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:46'!
showBorder: aBoolean

	"aBoolean ifTrue: [ self borderWidth: 1 ] ifFalse: [ self borderWidth: 0 ]"! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:49'!
stage: aStage

	stage _ aStage! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 11:18'!
update

	"updates the cell colour using a dictionary of attribute specs"

	| attributes col |
	attributes _ stage cellAttributes reject: [ :att | att hidden ].

	col _ Color fromString: 'transparent'.

	attributes do: [ :attr || val alpha r g b a  |
		val _ self value: attr name.
		alpha _ (val - attr min) / (attr max - attr min).

		a _ col alpha + (alpha * ( 1 - col alpha )).
		(a = 0)
			ifTrue: [ 
				r _ 0. g _ 0. b _ 0 
			]
			ifFalse: [
				r _ ((col red * col alpha) + (attr colour red * alpha * ( 1 - col alpha))) / a. 
				g _ ((col green * col alpha) + (attr colour green * alpha * ( 1 - col alpha))) / a.
				b _ ((col blue * col alpha) + (attr colour blue * alpha * ( 1 - col alpha))) / a. 
			].
		col _ Color r: r g: g b: b alpha: a.
	].

	color _ col.
	damaged _ true.
	"self changed."! !

!ScratchCell methodsFor: 'as yet unclassified' stamp: 'JM 9/28/2011 10:23'!
value: aString

	^ values at: aString ifAbsent: [ ^ 0 ].! !


!ScratchCell methodsFor: 'nil' stamp: 'JM 9/28/2011 13:35'!
color

	^ color! !


!ScratchCell methodsFor: 'object i/o' stamp: 'JM 9/29/2011 14:43'!
fieldsVersion

	^ 1! !

!ScratchCell methodsFor: 'object i/o' stamp: 'JM 9/29/2011 14:46'!
initFieldsFrom: anObjStream version: classVersion

	self initFieldsNamed: #(
		gridLocation 
		color 
		values 
		colors
	) from: anObjStream.




	! !

!ScratchCell methodsFor: 'object i/o' stamp: 'JM 9/29/2011 14:45'!
storeFieldsOn: anObjStream

	self storeFieldsNamed: #(
		gridLocation 
		color 
		values 
		colors
	) on: anObjStream

	! !
