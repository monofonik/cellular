Morph subclass: #ScratchCellMorph
	instanceVariableNames: 'value changed '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!

!ScratchCellMorph methodsFor: 'initialization' stamp: 'JM 8/31/2011 14:17'!
initialize

	super initialize.
	self clearCell.
	self extent: 10@10.
	self color: (Color fromString: 'white').
! !


!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 11:44'!
clearCell
	
	self setValue: 0.! !

!ScratchCellMorph methodsFor: 'as yet unclassified' stamp: 'JM 8/31/2011 11:44'!
setValue: aNumber

	value _ aNumber.
	self changed.! !
