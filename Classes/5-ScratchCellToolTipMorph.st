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

!ScratchCellToolTipMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/5/2011 15:58'!
step	

	super step.
	self position: Sensor cursorPoint.

	"update the string morph"
	getSelector ifNotNil: [ 
		message contents: (target perform: getSelector).
	].

	self extent: message extent + (12@3).

	! !
