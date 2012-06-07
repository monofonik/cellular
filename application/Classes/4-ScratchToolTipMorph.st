RectangleMorph subclass: #ScratchToolTipMorph
	instanceVariableNames: 'target message initialCursorPoint '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'jm 3/14/2009 10:11'!
initialCursorPoint: aPoint

	initialCursorPoint _ aPoint.
! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'JM 10/5/2011 12:26'!
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

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'jm 3/15/2009 14:14'!
messageColor: aColor

	message color: aColor.

! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'jm 5/7/2009 11:39'!
messageFont

	^ ScratchFrameMorph getFont: #ToolTip
! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'jm 12/15/2005 14:31'!
target: aMorph

	target _ aMorph.
! !


!ScratchToolTipMorph methodsFor: 'stepping' stamp: 'JM 10/5/2011 10:24'!
step

	initialCursorPoint ifNotNil: [
		(Sensor cursorPoint - initialCursorPoint) r > 80 ifTrue: [
			target ifNotNil: [target setProperty: #toolTip toValue: nil].
			self delete]].
! !

!ScratchToolTipMorph methodsFor: 'stepping' stamp: 'jm 3/14/2009 10:16'!
stepTime

	^ 200
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchToolTipMorph class
	instanceVariableNames: ''!

!ScratchToolTipMorph class methodsFor: 'instance creation' stamp: 'jm 12/15/2005 14:31'!
string: str for: morph

	^ self new
		message: str;
		target: morph;
		color: Color paleYellow;
		borderWidth: 1;
		borderColor: Color black
! !


!ScratchToolTipMorph class methodsFor: 'utilities' stamp: 'jm 8/22/2006 08:04'!
clearToolTips
	"Delete all tooltip morphs from the world."

	World ifNil: [^ self].
	World submorphsDo: [:m |
		(m isKindOf: ScratchToolTipMorph) ifTrue: [m delete]].
! !
