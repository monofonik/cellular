BorderedMorph subclass: #ScratchCellMorph
	instanceVariableNames: 'gridLocation values colors changing '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScratchCellMorph commentStamp: '<historical>' prior: 0!
I am a cell that represents an area of the stage environment. Sprites that are at my location can query and update my properties.!


!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/14/2011 14:25'!
fieldsVersion

	^ 1! !

!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/14/2011 14:25'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.

	self initFieldsNamed: #(
		gridLocation
		values
		colors
	) from: anObjStream.

	classVersion = 1 ifTrue: [ ^ self ].
		! !

!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/20/2011 16:09'!
initialize

	super initialize.
	super borderWidth: 0.
	super borderColor: (Color fromString: 'veryVeryLightGray').
	values _ Dictionary new.
	colors _ Dictionary new.
	self extent: 10@10.
	self color: (Color fromString: 'transparent'). "default cell color with no attributes"
	changing _ false.
! !

!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/9/2011 14:12'!
mouseDown: evt

	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		self handleTool: evt hand toolType hand: evt hand.
	].
! !

!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/16/2011 14:54'!
mouseEnterDragging: evt

	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		self handleTool: evt hand toolType hand: evt hand.
	].
! !


!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 11:19'!
attribute: aString

	^ self stage attribute: aString! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 11:21'!
cellAttribute: aString

	^ self stage cellAttribute: aString! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 10:27'!
changeValue: aString by: aNumber

	| spread |
	spread _ (self stage cellAttribute: aString) spread.
	self changeValue: aString by: aNumber spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/16/2011 16:01'!
changeValue: aString by: aNumber spread: aSpread

	" check for a spread amount and update neighbouring cells "
	| cellAttr min max oldValue newValue |	

	changing ifTrue: [ ^ self ].
	changing _ true.

	cellAttr _ self stage cellAttribute: aString.
	cellAttr ifNil: [ ^ self ].

	min _ cellAttr min.
	max _ cellAttr max.
	
	oldValue _ self value: aString.

	aSpread > 0 ifTrue: [ 
		"spread the value to adjacent cells, halving each time"
		((self ownerThatIsA: ScratchStageMorph) adjacentCellsTo: self) do: [ :cell | cell changeValue: aString by: aNumber * (1 - (1 / aSpread)) spread: aSpread - 1 ].
	].

	newValue _ (((oldValue + aNumber) min: max) max: min).
	
	oldValue = newValue ifFalse: [
		values at: aString put: newValue.
		self update.
	].

	changing _ false.
	! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:57'!
clearValue: aString

	| spread |
	spread _ (self stage cellAttribute: aString) spread.
	
	self clearValue: aString spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/20/2011 13:35'!
clearValue: aString spread: aSpread
	
	self changeValue: aString by: (values at: aString ifAbsent: [ ^ 0 ]) negated spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 11:21'!
clearValues

	"clears all values for this cell with zero spread"
	values keys do: [ :key |
		self setValue: key to: ((self cellAttribute: key) default) spread: 0.
	].

	self update.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 12:19'!
deleteValue: aString

	values removeKey: aString ifAbsent: [ ].
	colors removeKey: aString ifAbsent: [ ]! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:11'!
gridLocation

	^ gridLocation! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:10'!
gridLocation: aPoint

	gridLocation _ aPoint.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/16/2011 14:41'!
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

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/9/2011 12:44'!
handlesMouseDown: evt

	^ true! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/16/2011 14:53'!
handlesMouseOverDragging: evt

	^ true! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/14/2011 15:41'!
referencePosition

	| p |
	p _ (bounds origin + 5) - owner class scratchOrigin.
	^ p x @ p y negated! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:58'!
setValue: aString to: aNumber

	| spread |
	
	spread _ (self stage cellAttribute: aString) spread.
	self setValue: aString to: aNumber spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 10:36'!
setValue: aString to: aNumber spread: aSpread

	| oldval |
	oldval _ self value: aString.
	self changeValue: aString by: aNumber - oldval spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/14/2011 16:40'!
showBorder: aBoolean

	aBoolean ifTrue: [ self borderWidth: 1 ] ifFalse: [ self borderWidth: 0 ]! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:57'!
stage

	^ self ownerThatIsA: ScratchStageMorph! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/9/2011 13:05'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		gridLocation
		values
		colors
	) on: anObjStream.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/20/2011 16:36'!
update

	"updates the cell colour using a dictionary of attribute specs"

	| attributes keys col |
	attributes _ self stage cellAttributes reject: [ :att | att hidden ].
	keys _ attributes keysSortedSafely.

	"If no attributes, just use white"
	keys size = 0 
		ifTrue: [ col _ Color fromString: 'transparent' ]
		ifFalse: [
			| key attr val |
			key _ keys removeFirst.
			attr _ attributes at: key.
			val _ self value: key.

			"get the initial colour"
			val ~= attr min 
				ifTrue: [ col _ attr colour alpha: (val - attr min) / (attr max - attr min) ]
				ifFalse: [ col _ Color fromString: 'transparent' ].
				

			"mix with any other attribute colors"
			[ keys size > 0 ] whileTrue: [
				key _ keys removeFirst.
				attr _ attributes at: key.
				val _ self value: key.
				val ~= attr min ifTrue: [
					col _ col mixed: 0.5 with: (attr colour alpha: (val - attr min) / (attr max - attr min) )].
			]
		].

	"update the color for this cell"
	self color: col.
	self changed.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/5/2011 10:24'!
value: aString

	^ values at: aString ifAbsent: [ ^ 0 ].! !
