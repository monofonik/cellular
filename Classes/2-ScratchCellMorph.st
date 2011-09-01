Morph subclass: #ScratchCellMorph
	instanceVariableNames: 'gridLocation values colors '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScratchCellMorph commentStamp: 'JM 8/31/2011 16:39' prior: 0!
I am a cell that represents an area of the stage environment. Sprites that are at my location can query and update my properties.!


!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 9/1/2011 14:05'!
initialize

	super initialize.
	values _ Dictionary new.
	self extent: 10@10.
	self color: (Color fromString: 'white'). "default cell color with no attributes"
! !


!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 14:43'!
changeValue: aString by: aNumber spread: aSpread

	" check for a spread amount and update neighbouring cells "
	| myVal |	
	(values includes: aString) 
		ifTrue: [myVal _ values at: aString ]
		ifFalse: [ myVal _ 0 ].

	aSpread > 0 ifTrue: [ 
		"spread the value to adjacent cells, halving each time"
		((self ownerThatIsA: ScratchStageMorph) adjacentCellsTo: self) do: [ :cell | cell changeValue: aString by: aNumber / 2 spread: aSpread - 1 ].
	].

	values at: aString put: myVal + aNumber.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 11:36'!
clearValue: aString spread: aSpread
	
	self changeValue: aString to: (values at: aString) value negated spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 11:36'!
clearValues
	
	values keys do: [ :key |
		self changeValue: key to: (values at: key) negated.
	]! !

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

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 12:17'!
setValue: aString to: aNumber spread: aSpread

	| oldval |
	(values includes: aString) ifFalse: [ oldval _ 0 ] ifTrue: [ oldval _ values at: aString ].

	self changeValue: aString by: aNumber - oldval spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 14:45'!
update: aDictionary

	"updates the cell colour using a dictionary of attribute specs"

	| keys col |
	keys _ aDictionary keysSortedSafely.

	"If no attributes, just use white"
	keys size = 0 
		ifTrue: [ col _ Color fromString: 'white' ]
		ifFalse: [
			| key attr val |
			key _ keys removeFirst.
			attr _ aDictionary at: key.
			val _ values at: key.

			"get the initial colour"
			col _ Color h: attr hue s: val / (attr max - attr min) v: 1.

			"mix with any other attribute colors"
			[ keys size > 0 ] whileTrue: [
				key _ keys removeFirst.
				attr _ aDictionary at: key.
				val _ values at: key.
				col _ col mixed: 0.5 with: (Color h: attr hue s: val / (attr max - attr min) v: 1).
			]
		].

	"update the color for this cell"
	self color: col.
	
	self changed.! !
