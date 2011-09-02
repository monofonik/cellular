Morph subclass: #ScratchCellMorph
	instanceVariableNames: 'gridLocation values colors '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScratchCellMorph commentStamp: '<historical>' prior: 0!
I am a cell that represents an area of the stage environment. Sprites that are at my location can query and update my properties.!


!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/1/2011 14:05'!
initialize

	super initialize.
	values _ Dictionary new.
	self extent: 10@10.
	self color: (Color fromString: 'white'). "default cell color with no attributes"
! !


!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:57'!
changeValue: aString by: aNumber

	| spread |
	spread _ (self stage cellAttribute: aString) spread.
	self changeValue: aString by: aNumber spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:48'!
changeValue: aString by: aNumber spread: aSpread

	" check for a spread amount and update neighbouring cells "
	| myVal |	
	myVal _ self value: aString.

	aSpread > 0 ifTrue: [ 
		"spread the value to adjacent cells, halving each time"
		((self ownerThatIsA: ScratchStageMorph) adjacentCellsTo: self) do: [ :cell | cell changeValue: aString by: aNumber / 2 spread: aSpread - 1 ].
	].

	values at: aString put: myVal + aNumber.
	self update.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:57'!
clearValue: aString

	| spread |
	spread _ (self stage cellAttribute: aString) spread.
	
	self clearValue: aString spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:47'!
clearValue: aString spread: aSpread
	
	self changeValue: aString by: (values at: aString) negated spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:55'!
clearValues
	
	"clears all values for this cell with zero spread"
	values keys do: [ :key |
		self setValue: key to: 0 spread: 0.
	].

	self update.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 13:45'!
deleteValue: aString

	values removeKey: aString.
	colors removeKey: aString! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:11'!
gridLocation

	^ gridLocation! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:10'!
gridLocation: aPoint

	gridLocation _ aPoint.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:58'!
setValue: aString to: aNumber

	| spread |
	
	spread _ (self stage cellAttribute: aString) spread.
	self setValue: aString to: aNumber spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 12:17'!
setValue: aString to: aNumber spread: aSpread

	| oldval |
	(values includes: aString) ifFalse: [ oldval _ 0 ] ifTrue: [ oldval _ values at: aString ].

	self changeValue: aString by: aNumber - oldval spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 15:57'!
stage

	^ self ownerThatIsA: ScratchStageMorph! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 14:46'!
update

	"updates the cell colour using a dictionary of attribute specs"

	| attributes keys col |
	attributes _ (self ownerThatIsA: ScratchStageMorph) cellAttributes.
	keys _ attributes keysSortedSafely.

	"If no attributes, just use white"
	keys size = 0 
		ifTrue: [ col _ Color fromString: 'white' ]
		ifFalse: [
			| key attr val |
			key _ keys removeFirst.
			attr _ attributes at: key.
			val _ values at: key.

			"get the initial colour"
			col _ Color h: attr hue s: val / (attr max - attr min) v: 1.

			"mix with any other attribute colors"
			[ keys size > 0 ] whileTrue: [
				key _ keys removeFirst.
				attr _ attributes at: key.
				val _ values at: key.
				col _ col mixed: 0.5 with: (Color h: attr hue s: val / (attr max - attr min) v: 1).
			]
		].

	"update the color for this cell"
	self color: col.
	
	self changed.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 14:47'!
value: aString

	^ values at: aString ifAbsent: 0.! !