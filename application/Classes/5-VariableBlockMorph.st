ReporterBlockMorph subclass: #VariableBlockMorph
	instanceVariableNames: 'labelFragment alias '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!VariableBlockMorph commentStamp: '<historical>' prior: 0!
I am a block that reports the value of either a built-in or a user variable. When dropped into the workspace, I turn into a WatcherMorph for that variable with an optional slider.
!


!VariableBlockMorph methodsFor: 'initialization' stamp: 'jens 1/12/2010 03:44'!
initialize

	super initialize.
	commandSpec _ ''.
	self color: (Color r: 0.4 g: 1.0 b: 0.4).
	labelFragment _ BlockLabelFragment new
! !

!VariableBlockMorph methodsFor: 'initialization' stamp: 'jens 8/2/2010 21:31'!
isSpecialForm: bool

	super isSpecialForm: bool.
	isSpecialForm
		ifTrue: [self color: VariableFrame new variableBlockColor]
		ifFalse: [self color: (ScriptableScratchMorph blockColorFor: 'variables')].
! !


!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 1/9/2006 12:34'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^ 'variable'
! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 2/23/2004 11:07'!
isReporter

	^ true
! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'JM 10/26/2011 11:41'!
receiver: anObject
	"Set my receiver object and, if possible, my block color."

	alias ifNotNil: [^ self].
	receiver _ anObject.
	alias _ nil.

	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'jens 9/22/2010 02:19'!
rename

	| blockVars objVars obj list choice | 

	obj _ self scratchObject.
	obj ifNil: [^#()].
	blockVars _ self scriptVars asSortedCollection asArray.
	objVars _ obj varNamesMenu asOrderedCollection.
	objVars removeAll: blockVars.

	list _ OrderedCollection new.
	objVars do: [:vname |
		vname = #-
			ifTrue: [list add: vname]
			ifFalse: [list add: {vname. {vname. false}}]].

	list add: #-.

	blockVars do: [:vname |
		list add: {vname. {vname. true}}].

	list size > 1 
		ifFalse: [^ self]. "the menu is empty"

	choice _ (SelectionMenu fromArray: list asArray) startUpWithCaption: nil at: self topRight.
	choice ifNil: [^ self].

	self isSpecialForm: choice second.
	isSpecialForm
		ifTrue: [self receiver: nil]
		ifFalse: [self receiver: obj].
	self commandSpec: choice first! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'JM 5/4/2012 15:38'!
rightButtonMenu

	| menu choice |

	((owner isKindOf: BlockMorph) and: [owner isCustomBlock and: [owner isTemplate]])
		ifTrue: [^ self click: nil].

	(((owner isKindOf: MultiArgReporterBlockMorph) and: [owner isLambdaForm])
		or: [owner isKindOf: VariableDeclarationBlockMorph])
		ifFalse: [
			^ super rightButtonMenu.
		].

	menu _ CustomMenu new.
	menu add: 'help' action: #presentHelpScreen.
	menu addLine.
	menu add: 'edit...' action: #editName.
	menu addLine.
	menu add: 'delete' action: #deleteTemplate.
	menu add: 'duplicate' action: #duplicate.
	(choice _ menu localize; startUp) ifNil: [^ self].
	self perform: choice.
! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 12/13/2006 20:12'!
variable

	^ commandSpec
! !


!VariableBlockMorph methodsFor: 'evaluation' stamp: 'jens 3/27/2011 23:41'!
evaluateWithArgs: args
	"Overridden to read my variable value."

	alias ifNotNil: [ ^ receiver getVar: alias]. "special case for externalized local variables in BYOB"
	receiver ifNotNil: [ ^ receiver getVar: commandSpec block: self ].
	^ 0
! !


!VariableBlockMorph methodsFor: 'watcher' stamp: 'TIS 6/19/2006 13:52'!
canBecomeWatcher
	"All variable blocks can become watchers when dragged onto the stage."

	^ true! !

!VariableBlockMorph methodsFor: 'watcher' stamp: 'jm 11/30/2007 19:23'!
createWatcher
	"Return a new watcher for me."

	| newWatcher |
	newWatcher _ WatcherMorph new setCategoryColor: self color.
	newWatcher target: receiver selector: #getVar: parameter: commandSpec.

	^ newWatcher
! !

!VariableBlockMorph methodsFor: 'watcher' stamp: 'jm 11/30/2007 12:26'!
selectorAndArg
	"Answer an array containing my selector and argument (if any)."

	^ Array with: #getVar: with: self variable
! !


!VariableBlockMorph methodsFor: 'object i/o' stamp: 'jm 2/24/2004 18:24'!
fieldsVersion

	^ 1
! !


!VariableBlockMorph methodsFor: 'private' stamp: 'jens 3/28/2011 00:20'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments.

	variable accessor blocks in BYOB come in two flavors: Those onces statically accessing sprite or stage variables, and those ones dynamically bound to other environments. The latter ones are marked as special forms.  To stay compatible with Scratch (which doesn't have temporaries or block vars) the isSpecialForm flag is not put into the file format, instead the distinction is made via an explanatory symbol:

	isSpecialForm 	 	=	#readBlockVariable
	isSpecialForm not	=	#readVariable
"

	| blockTuple rcvr |

	isSpecialForm 
		ifTrue: [ 
			(receiver isKindOf: VariableFrame)
				ifTrue: [ rcvr _ receiver convertStacksToTuples ]
				ifFalse: [ receiver ifNotNil: [rcvr _ receiver userSpec ]].
			blockTuple _ Array new: 5.
			blockTuple
				at: 1 put: #byob;
				at: 2 put: self rcvr;			"not really needed for this block. JM"
				at: 3 put: #readBlockVariable;
				at: 4 put: commandSpec;
				at: 5 put: rcvr ]
		ifFalse: [

			self evaluate. "ensure desparate re-binding of orphaned and rescoped variable getters"

			blockTuple _ Array new: 4.
			blockTuple
				at: 1 put: #byob;
				at: 2 put: self rcvr;			"not really needed for this block. JM"
				at: 3 put: #readVariable;
				at: 4 put: commandSpec ].
	^ blockTuple! !

!VariableBlockMorph methodsFor: 'private' stamp: 'jens 6/23/2010 01:22'!
click: evt

	| old frag |

	self isBlockTemplate
		ifFalse: [^ super click: evt]. 

	(owner isKindOf: ScratchBlockPaletteMorph)
		ifTrue: [^ super click: evt].

	((owner isKindOf: BlockMorph) and: [owner isCustomBlock and: [owner isTemplate]])
		ifFalse: [^self editName].
	owner hideArgumentPlaceHolders.

	owner isFrozen 
		ifTrue: [ ^ self]
		ifFalse: [ 
			owner isFrozen: true.
			submorphs first color: Color white slightlyDarker].

	old _ labelFragment deepCopy.
	frag _ BlockLabelFragmentDialog on: labelFragment category: owner category.

	owner isFrozen: false.
	submorphs first color: Color white.

	frag = #cancelled ifTrue: [
		labelFragment _ old.
		^ self].
	owner updateSpecWithDnDSpec! !


!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 2/25/2010 02:12'!
aboutToBeGrabbedBy: aHandMorph

	super aboutToBeGrabbedBy: aHandMorph.
	self addLabel! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 10/5/2010 11:50'!
addLabel
	"Add a label for my command and arguments. 
	This is the method that really creates the whole block."
	"Details: This overrides the superclass method to allow 
	using percent character in variable/list names"

	| dflt |

	commandSpec ifNil: [^ self].
	self removeAllMorphs.

	self isPrototypeTemplate
		ifFalse: [
			self addMorphBack: (self labelMorphFor: commandSpec).
			^ self].

	self addMorphBack: (self labelMorphFor: commandSpec).

	dflt _ labelFragment default asString.

	labelFragment isMultipleInput ifTrue: [
		self addMorphBack: (self labelMorphFor: '...') ].

	labelFragment isTemplate ifTrue: [
		self addMorphBack: ((StringMorph contents: '^') color: self labelColor) ].

	labelFragment isLoop ifTrue: [
		self addMorphBack: ((StringMorph contents: '[') color: self labelColor) ].

	labelFragment isUnevaluated ifTrue: [
		self addMorphBack: ((StringMorph contents: '*') color: self labelColor) ].

	(' ' asUTF8 = dflt or: [dflt isEmpty]) ifFalse: [
		self addMorphBack: (self labelMorphFor: '=', labelFragment default asString)].

! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 3/19/2010 00:48'!
alias: aString

	alias _ aString! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 3/9/2010 23:55'!
defaultValue: something
	"no op"! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 9/14/2010 22:04'!
deleteTemplate

	owner deleteVariableTemplate: self! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 5/3/2010 21:32'!
duplicate

	| copy |
	copy _ self fullCopy.
	copy addLabel.
	World activeHand attachMorph: copy! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 6/23/2010 01:23'!
editName
	| old new lambda |
	lambda _ self owner.
	old _ self commandSpec.
	new _ StringDialog askWithCancel: 'Name' localized initialAnswer: commandSpec.
	(new isEmpty or: [old = new])
		ifTrue: [^ self].
	lambda isCustomBlock ifTrue: [
		self commandSpec: new.
		^ self].
	(lambda renameParm: old to: new) 
		ifTrue: [ self commandSpec: new ]
! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/21/2010 22:15'!
handlesMouseOver: evt

	^ (owner isKindOf: BlockMorph) and: [
		owner isCustomBlock and: [
			owner isTemplate]]
! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/21/2010 22:15'!
handlesMouseOverDragging: evt
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ (owner isKindOf: BlockMorph) and: [
		owner isCustomBlock and: [
			owner isTemplate]]
! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 11/29/2009 19:15'!
isAbstractFunctionCall
	"allow me to be dropped onto boolean args, as in the IF block"

	^true! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 5/10/2010 01:13'!
isBlockTemplate

	| def |

	((owner isKindOf: BlockMorph) and: [
		owner isCustomBlock]) ifTrue: [
			def _ owner definition.
			def ifNotNil: [
				(def typeOfParameterIndex: (owner argMorphs indexOf: self)) = #template
						ifTrue: [^true]]].


	^ super isBlockTemplate
! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 6/7/2010 23:08'!
isPrototypeTemplate

	(owner isKindOf: CommandBlockMorph)
		ifFalse: [^ false].
	(owner isCustomBlock and: [owner isTemplate])
		ifFalse: [^ false].
	^ true! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/12/2010 03:04'!
labelFragment
	^ labelFragment! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/12/2010 03:04'!
labelFragment: aBlockLabelFragment
	labelFragment _ aBlockLabelFragment! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/24/2010 23:43'!
mouseEnter: evt

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self.
	"owner hideArgumentPlaceHolders."
	submorphs first color: color twiceDarker
! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/24/2010 23:35'!
mouseEnterDragging: evt

	World activeHand submorphs size < 1 ifTrue: [
		^ self].

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/27/2010 22:47'!
mouseLeave: evt

	(owner notNil and: [owner isFrozen]) 
		ifTrue: [^ self].
	submorphs first color: Color white! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/22/2010 15:50'!
mouseLeaveDragging: evt

	World activeHand submorphs size < 1 ifTrue: [
		^self ].

	owner isFrozen 
		ifTrue: [^ self].
	submorphs first color: Color white! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/20/2010 01:54'!
parameterDefaultValue: aString

	labelFragment default: aString! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/15/2010 00:10'!
parameterType: aSymbol

	labelFragment type: aSymbol! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 9/1/2010 01:03'!
rootForGrabOf: aMorph

	((owner isKindOf: BlockMorph) and: [
		owner isCustomBlock and: [owner isTemplate not and: [owner definition notNil]]]) ifTrue: [
			(owner definition typeOfParameterIndex: (owner argMorphs indexOf: aMorph)) = #template
				ifTrue: [^self fullCopy]].


	(owner notNil and: [owner isPartsBin])
		ifTrue: [ ^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

! !

!VariableBlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/27/2010 23:13'!
updateFragment

	labelFragment
		isInput: true;
		label: self variable! !


!VariableBlockMorph methodsFor: 'Cellular' stamp: 'JM 10/26/2011 11:56'!
setReceiversForClone: aSprite

	"overridden to ignore command when we're special form"
	isSpecialForm ifFalse: [ ^ super setReceiversForClone: aSprite ].! !
