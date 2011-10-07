CommandBlockMorph subclass: #SetterBlockMorph
	instanceVariableNames: 'variable '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!SetterBlockMorph commentStamp: '<historical>' prior: 0!
I am a block for setting a variable.
!


!SetterBlockMorph methodsFor: 'initialization' stamp: 'jens 2/28/2011 02:12'!
initChangerForVar: varName

	| var |
	var _ varName.
	(var isKindOf: Array) ifTrue: [
		var _ receiver blockFromTuple: var receiver: receiver].

	self commandSpec: (ScratchTranslator translationFor: 'change %v by %s').
	argPermutation _ CommandBlockMorph argPermutationForSpec: 'set %v to %s' withTranslation: commandSpec.
	self selector: #changeVar:by:.
	self variable: var.
! !

!SetterBlockMorph methodsFor: 'initialization' stamp: 'jens 2/28/2011 02:06'!
initSetterForVar: varName

	| var |
	var _ varName.
	(var isKindOf: Array) ifTrue: [
		var _ receiver blockFromTuple: var receiver: receiver].
	
	self commandSpec: (ScratchTranslator translationFor: 'set %v to %s').
	argPermutation _ CommandBlockMorph argPermutationForSpec: 'set %v to %s' withTranslation: commandSpec.
	self selector: #setVar:to:.
	self variable: var.
! !

!SetterBlockMorph methodsFor: 'initialization' stamp: 'jm 3/31/2005 19:38'!
initialize

	super initialize.
	isSpecialForm _ false.
	isTimed _ false.
! !


!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 16:09'!
expressionArg

	submorphs do: [:m |
		(m isKindOf: ExpressionArgMorph) ifTrue: [^ m]].

	^ nil! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jm 11/15/2006 11:46'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	#setVar:to: = selector
		ifTrue: [^ 'variableSet']
		ifFalse: [^ 'variableChangeBy']
! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'JM 10/7/2011 12:31'!
receiver: anObject
	"Set my receiver object and, if possible, my block color."

	receiver _ anObject.

"
	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].
"! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jens 2/28/2011 01:25'!
variable

	submorphs do: [:m |
		(m isKindOf: ChoiceArgMorph) ifTrue: [^ m choice]].
	^ argMorphs first

! !

!SetterBlockMorph methodsFor: 'accessing' stamp: 'jens 2/28/2011 01:28'!
variable: aVar

	(aVar isKindOf: CommandBlockMorph) ifTrue: [
		^ self replaceArgMorph: self argMorphs first by: aVar].
	submorphs do: [:m |
		(m isKindOf: ChoiceArgMorph) ifTrue: [^ m choice: aVar]].

! !


!SetterBlockMorph methodsFor: 'object i/o' stamp: 'jm 12/1/2003 10:52'!
fieldsVersion

	^ 1
! !

!SetterBlockMorph methodsFor: 'object i/o' stamp: 'jm 7/13/2008 23:07'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		variable
	) from: anObjStream.
	self variable: variable.
! !

!SetterBlockMorph methodsFor: 'object i/o' stamp: 'jm 7/13/2008 23:07'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	variable _ self variable.
	self storeFieldsNamed: #(
		variable
	) on: anObjStream.
! !


!SetterBlockMorph methodsFor: 'private' stamp: 'jens 2/28/2011 01:49'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments.

	variable accessor blocks in BYOB come in two flavors: Those onces statically accessing sprite or stage variables, and those ones dynamically bound to other environments. The latter ones are marked as special forms.  To stay compatible with Scratch (which doesn't have temporaries or block vars) the isSpecialForm flag is not put into the file format, instead the distinction is made via an explanatory symbol:

	isSpecialForm 	 	=	#changeBlockVariable
	isSpecialForm not	=	#changeVariable

this symbol is *not* the selector!!. Instead the selector goes into slot 5. The information to be gathered from the selector is, whether the block is a *setter* or a *getter*

"

	| arg rcvr blockTuple val eval var |
	isSpecialForm 
		ifTrue: [
			(receiver isKindOf: VariableFrame)
				ifTrue: [ rcvr _ receiver convertStacksToTuples ]
				ifFalse: [ rcvr _ nil ].

			blockTuple _ Array new: 7.
			blockTuple
				at: 1 put: #byob;
				at: 2 put: self rcvr;			"not really needed for this block. late-bound. JM"
				at: 3 put: #changeBlockVariable;
				at: 4 put: self variable;
				at: 5 put: selector;
				at: 6 put: rcvr;
				at: 7 put: nil.

			arg _ (argMorphs first isKindOf: ChoiceArgMorph)
				ifTrue: [argMorphs last]
				ifFalse: [argMorphs first].

			(arg isKindOf: ArgMorph)
				ifTrue: [(arg isKindOf: ExpressionArgMorph)
					ifTrue: [
						val _ arg getExpression.
						arg isNumberExpression
							ifTrue: [val = ' ' asUTF8
								ifTrue: [eval _ val]
								ifFalse: [eval _ val asNumberNoError]]
							ifFalse: [eval _ arg evaluate]]
					ifFalse: [eval _ arg evaluate].
					blockTuple at: 7 put: eval]
				ifFalse: [blockTuple at: 7 put: arg asBlockTuple]]

		ifFalse: [
			var _ self variable.
			(var isKindOf: CommandBlockMorph) ifTrue: [
				var _ var asBlockTuple].
			blockTuple _ Array new: 6.
			blockTuple
				at: 1 put: #byob;
				at: 2 put: self rcvr;			"not really needed for this block. late-bound. JM"
				at: 3 put: #changeVariable;
				at: 4 put: var;
				at: 5 put: selector;
				at: 6 put: nil.

			"determine if the block is a getter or a setter:"

			arg _ ((argMorphs first isKindOf: ChoiceArgMorph) 
					or: [argMorphs first isKindOf: ReporterBlockMorph])
				ifTrue: [argMorphs last]
				ifFalse: [argMorphs first].

			(arg isKindOf: ArgMorph)
				ifTrue: [(arg isKindOf: ExpressionArgMorph)
					ifTrue: [
						val _ arg getExpression.
						arg isNumberExpression
							ifTrue: [val = ' ' asUTF8
								ifTrue: [eval _ val]
								ifFalse: [eval _ val asNumberNoError]]
							ifFalse: [eval _ arg evaluate]]
					ifFalse: [eval _ arg evaluate].
					blockTuple at: 6 put: eval]
				ifFalse: [blockTuple at: 6 put: arg asBlockTuple]].

		^ blockTuple! !

!SetterBlockMorph methodsFor: 'private' stamp: 'jm 7/13/2008 23:06'!
labelMorphFor: aString

	| s |
	s _ aString.
	commandSpec isUnicode ifTrue: [s _ UTF8 withAll: s].
	self variable isUnicode ifTrue: [s _ UTF8 withAll: s].
	^ (StringMorph contents: s font: (ScratchFrameMorph getFont: #Label))
		color: self labelColor
! !


!SetterBlockMorph methodsFor: 'byob' stamp: 'jens 8/3/2010 13:23'!
contrastColor

	| newColor |
	isSpecialForm
		ifTrue: [newColor _ VariableFrame variableBlockColor]
		ifFalse: [newColor _ (ScriptableScratchMorph blockColorFor: 'variables')].
	color = newColor ifFalse: [
		self color: newColor ].

	super contrastColor! !

!SetterBlockMorph methodsFor: 'byob' stamp: 'jens 8/2/2010 22:50'!
determineIfSpecialForm

	"also rebind my receiver to the sprite or stage that has my variable
	if it's not a temporay one"

	isSpecialForm _ (self scriptVars includes: self variable).
	isSpecialForm ifFalse: [
		receiver _ self scratchObject ]. 

	isSpecialForm
		ifTrue: [self color: VariableFrame variableBlockColor]
		ifFalse: [self color: (ScriptableScratchMorph blockColorFor: 'variables')].

! !

!SetterBlockMorph methodsFor: 'byob' stamp: 'jens 2/28/2011 02:37'!
replaceArgMorph: oldMorph by: newMorph
	"Replace oldMorph with newMorph in my argMorphs and submorphs lists. This is done when dropping a reporter block onto one of my arguments."


	super replaceArgMorph: oldMorph by: newMorph.
	oldMorph = argMorphs first ifTrue: [
		self determineIfSpecialForm]! !
