ScratchToolTipMorph subclass: #ScratchCellToolTipMorph
	instanceVariableNames: 'getSelector '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchCellToolTipMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/5/2011 15:53'!
getSelector: aSelector

	getSelector _ aSelector! !

!ScratchCellToolTipMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/5/2011 15:53'!
initialize

	super initialize.

	self color: Color paleYellow;
		borderWidth: 1;
		borderColor: Color black.

	message _ TextMorph new.

	self addMorphFront: message.
	message position: 6@1.
! !

!ScratchCellToolTipMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/6/2011 14:15'!
step	

	| offset |
	
	offset _ 28@0.

	super step.

	self position: Sensor cursorPoint + offset.

	"update the string morph"
	getSelector ifNotNil: [ 
		message contents: (target perform: getSelector).
	].

	self extent: message extent + (12@3).

	"Check if we're too far to the right"
	(self bounds corner x) > (owner bounds corner x)
		ifTrue: [ self position: (self position x - (offset x + 5) - self bounds width) @ self position y].

	(self bounds corner y) > (owner bounds corner y)
		ifTrue: [ self position: self position x @ (self position y - (self bounds height)) ].

	! !
