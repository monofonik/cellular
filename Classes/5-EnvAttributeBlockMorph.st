ReporterBlockMorph subclass: #EnvAttributeBlockMorph
	instanceVariableNames: 'labelFragment '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!EnvAttributeBlockMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 12:54'!
evaluateWithArgs: args
	"Overridden to read my env attribute value."

	receiver ifNotNil: [ 
		receiver prototype ifNotNil: [
		^ receiver currentCell value: (self commandSpec) ]].
	^ 0! !

!EnvAttributeBlockMorph methodsFor: 'as yet unclassified' stamp: 'JM 9/2/2011 12:38'!
updateLabel

	self removeAllMorphs.
	self addMorph: (self labelMorphFor: commandSpec).

	! !
