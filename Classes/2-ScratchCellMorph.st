Morph subclass: #ScratchCellMorph
	instanceVariableNames: 'gridLocation value changed spread '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScratchCellMorph commentStamp: 'JM 8/31/2011 16:39' prior: 0!
I am a cell that represents an area of the stage environment. Sprites that are at my location can query and update my properties.!


!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 8/31/2011 16:01'!
initialize

	super initialize.
	spread _ 2.
	value _ 0.
	self extent: 10@10.
	self color: (Color fromString: 'white').
! !


!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 15:53'!
changeValue: aNumber

	^ self changeValue: aNumber spread: spread.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:55'!
changeValue: aValue spread: aSpread

	" check for a spread amount and update neighbouring cells "
	| myVal |	
	myVal _ value.

	aSpread > 0 ifTrue: [ 
		"spread the value to adjacent cells, halving each time"
		((self ownerThatIsA: ScratchStageMorph) adjacentCellsTo: self) do: [ :cell | cell changeValue: aValue / 2 spread: aSpread - 1 ].
	].

	^ self value: myVal + aValue.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 15:38'!
clearCell
	
	self changeValue: value negated.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:11'!
gridLocation

	^ gridLocation! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:10'!
gridLocation: aPoint

	gridLocation _ aPoint.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:44'!
setValue: aValue

	self changeValue: aValue - value spread: spread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:44'!
setValue: aValue spread: aSpread

	self changeValue: aValue - value spread: aSpread! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:38'!
value

	^ value.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 16:38'!
value: aNumber

	value _ (aNumber min: 100) max: 0.
	self color: (Color r: 1 g: 0 b: 0 alpha: aNumber / 100).
	self changed.! !
