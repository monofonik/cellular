WatcherMorph subclass: #ScratchCellInfoMorph
	instanceVariableNames: 'target message initialCursorPoint getSelector columns '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/27/2011 10:06'!
getRow: row col: col

	^ (columns at: col) submorphs at: row.! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:21'!
getSelector: aSelector

	getSelector _ aSelector! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:20'!
initialCursorPoint: aPoint

	initialCursorPoint _ aPoint.! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/27/2011 09:47'!
initialize

	super initialize.
	orientation _ #horizontal.	
	hResizing _ #shrinkWrap.
	vResizing _ #shrinkWrap.
	columns _ OrderedCollection new.

	2 timesRepeat: [ | col |
		col _ AlignmentMorph new.
		col orientation: #vertical.
		col hResizing: #shrinkWrap.
		col color: (Color colorFrom: #transparent).
		columns add: col.
	].

	self addAllMorphs: columns
	
! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:20'!
message: aString

	| str |
	(aString isKindOf: Form)
		ifTrue: [message _ ImageMorph new form: aString ]
		ifFalse: [
			str _ aString.
			(aString isKindOf: String) ifFalse: [
				str _ aString printString].
			message _ StringMorph
				contents: str
				font: self messageFont ].
	self addMorph: message.
	self extent: message extent + (12@3).
	message position: 6@1.
! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:20'!
messageColor: aColor

	message color: aColor.

! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:20'!
messageFont

	^ ScratchFrameMorph getFont: #ToolTip
! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/27/2011 10:14'!
step	

	| offset data n |
	
	offset _ 28@0.

	super step.

	self position: Sensor cursorPoint + offset.

	"update the string morph"
	getSelector ifNotNil: [ 
		data _ (target perform: getSelector).
	].

	columns do: [ :col |
		col submorphs size ~= data size ifTrue: [
			col submorphsDo: [ :sub | sub delete ].
			data size timesRepeat: [ col addMorph: (StringMorph new)].
		]
	].

	"add the x / y location"
	(self getRow: 1 col: 1) font: (ScratchFrameMorph getFont: #Watcher).
	(self getRow: 1 col: 2) contents: ' '.
	(self getRow: 1 col: 1) contents: ((data at: 1) at: 1) , ':' , ((data at: 1) at: 2).
	

	"add the data to the rows"
	n _ 2.
	[n <= (data size)] whileTrue: [
		(self getRow: n col: 1) contents: ((data at: n) at: 1); color: ((data at: n) at: 3).
		(self getRow: n col: 2) contents: ((data at: n) at: 2); color: ((data at: n) at: 3).
		n _ n + 1.
	].

	"Check if we're too far to the right"
	(self bounds corner x) > (owner bounds corner x)
		ifTrue: [ self position: (self position x - (offset x + 5) - self bounds width) @ self position y].

	(self bounds corner y) > (owner bounds corner y)
		ifTrue: [ self position: self position x @ (self position y - (self bounds height)) ].

	! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:21'!
stepTime

	^ 100
! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:21'!
target: aMorph

	target _ aMorph.
! !

!ScratchCellInfoMorph methodsFor: 'as yet unclassified' stamp: 'JM 10/26/2011 14:52'!
updateTargetName

	"do nothing"! !
