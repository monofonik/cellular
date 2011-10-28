Morph subclass: #BlockMorph
	instanceVariableNames: 'isSpecialForm oldColor highlightColor1 highlightColor2 shadowColor scratchProc hadError blockLayoutNeeded cachedForm cachedFeedbackForm copyTooltip lastLayoutTime originalColor isContrasted '
	classVariableNames: 'ArgFont CBlockBracketThickness Contrast DebugMenu LabelColor LabelFont PuzzleInset PuzzleWidth '
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!BlockMorph commentStamp: '<historical>' prior: 0!
I and my subclasses represent statements in a block-based graphical programming language.
!


!BlockMorph methodsFor: 'initialization' stamp: 'jens 1/27/2010 12:38'!
initialize

	super initialize.
	blockLayoutNeeded _ true.
	isSpecialForm _ false.
	color _ Color r: 0.4 g: 0.7 b: 0.8.
	oldColor _ color.
	scratchProc _ nil.
	hadError _ false.
	lastLayoutTime _ 0.
	isContrasted _ false
! !


!BlockMorph methodsFor: 'accessing' stamp: 'md 12/8/2004 01:00'!
acceptsDroppedReporters

	^ true
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 3/28/2005 19:20'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'ee 2/21/2009 14:40'!
addCopyTooltip: aMorph

	copyTooltip _ aMorph.
	self addMorph: copyTooltip.
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jens 3/4/2009 00:23'!
blockID
	"answer a temporary (!!) id for the receiver
	which can be used for tuple conversion of
	sticky comments"

	| sm |
	sm _ self ownerThatIsA: ScratchScriptsMorph.
	sm ifNil: [^ nil].
	^ (sm allMorphs select: [:m |
		m isKindOf: BlockMorph]) indexOf: self
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 6/26/2006 09:51'!
canBecomeWatcher
	"Answer true if this block can become a watcher when dropped onto the stage. False by default."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jens 12/14/2009 04:06'!
closestAttachTargetIn: newOwner
	"Answer the closest block attachment point among the blocks and stack submorphs of the given morph. Answer nil if there are no blocks close enough to attach myself to."

	| xThresh yThresh attachPoints best bestDist targetP dist ref topUsed bottomUsed |
	xThresh _ 65.
	((self isKindOf: CBlockMorph) and: [(self nestedBlockAt: (self top + self topBarHeight)) isNil])
		ifTrue: [yThresh _ 25]
		ifFalse: [yThresh _ 14].
	topUsed _ false.
	bottomUsed _ false.

	attachPoints _ OrderedCollection new:100.
	(newOwner allMorphs reject: [:m | m == newOwner ]) do: [:m |
		((m ~~ self) and:
		 [(m ~~ (self bottomBlock)) and:
		 [(m ~~ (self topBlock)) and:
		 [(m ~~ (self owner)) and:
		 [(m isKindOf: BlockMorph) and:
		 [m isReporter not | (m isKindOf: CommandScriptBlockMorph)]]]]]) ifTrue: [
			m blockAttachPoints: attachPoints]].

	((self isKindOf: HatBlockMorph) or: [(self ownerThatIsA: HatBlockMorph) ~= nil]) ifTrue: [
		"if I am a HatBlock or the bottom block of a HatBlock stack, I can only attach to the top block of a stack"
		attachPoints _ attachPoints select: [:assoc |
			(assoc value owner = newOwner) and:
			[assoc key y = assoc value top]]].

	(self isStop or:[self bottomBlock isStop]) ifTrue: [
		"I am a stop block; I can't attach to the top of a stack"
		attachPoints _ attachPoints select: [:assoc |
			assoc key y ~= assoc value top]].

	(self topBlock isForever not and: [self bottomBlock isForever]) ifTrue: [
		"My bottom block is a forever; I can't attach to the top of a stack"
		attachPoints _ attachPoints select: [:assoc |
			assoc key y ~= assoc value top]].

	best _ nil.
	bestDist _ 10000.
	attachPoints do: [:assoc |
		targetP _ assoc key.
		ScratchTranslator isRTL
			ifTrue: [ref _ self right]
			ifFalse: [ref _ self left].
		((ref - targetP x) abs < xThresh)
			ifTrue: [
				(((self top - targetP y) abs < yThresh) or: [self nextBlock isNil and: [(self bottom - targetP y) abs < yThresh]])
					ifTrue: [  "targetP is within sticking range"
						ScratchTranslator isRTL
							ifTrue: [dist _ (self topRight - targetP) r]
							ifFalse: [dist _ (self position - targetP) r].
						dist < bestDist ifTrue: [
							((self top - targetP y) abs < yThresh) ifTrue: [topUsed _ true. bottomUsed _ false].
							(self nextBlock isNil and: [(self bottom - targetP y) abs < yThresh]) ifTrue: [topUsed _ false. bottomUsed _ true].
							best _ assoc.
							bestDist _ dist]]]].

	"special case for the auto-wrapping of c-shaped/if-else blocks"
	(self isKindOf: CBlockMorph) ifTrue: [
	best ifNotNil: [
		bottomUsed ifTrue: [
				(best value owner isKindOf: BlockMorph) ifTrue: [
				self stretchHeight: 0. ^ best _ nil]].
		(self isStopOrForever or:[self bottomBlock isStopOrForever]) ifTrue: [
			bottomUsed ifTrue: [
					self stretchHeight: 0.
					^ best _ nil]].
		((best key y = best value top) and: [((self isForever or:[self bottomBlock isForever])) and: [(self nestedBlockAt: (best key y)) isNil not]])
					ifTrue: [self stretchHeight: 0. ^ best _ nil].
		(self nestedBlockAt: (best key y)) ifNil: [
			bottomUsed ifTrue: [
					self stretchHeight: 0.
					(best key y = best value bottom) ifTrue: [^ best _ nil].
					((best key y = best value top) and: [(best value owner isKindOf: BlockMorph)]) ifTrue: [^ best _ nil].
					((best key y = best value bottom) and: [(best value owner isKindOf: BlockMorph) not]) ifTrue: [^ best _ nil]].
			topUsed ifTrue: [
				((best key y = best value bottom) and: [best value nextBlock isNil not]) ifTrue: [self stretchHeight: 0. ^ best _ nil].
				"((best key y = best value top) and: [(best value owner isKindOf: BlockMorph)]) ifTrue: [self stretchHeight: 0. ^ best _ nil]."
				(best key y = best value top) ifTrue: [self stretchHeight: best value fullBounds height - 17. ^ best]].
			self stretchHeight: 0]].
	best ifNil: [
		self stretchHeight: 0]].

	 ^ best
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 10/21/2003 18:54'!
codeString
	"Answer a human-readable string representing the code for this block sequence."

	| s |
	s _ WriteStream on: (String new: 5000).
	self printCodeOn: s indent: 0.
	^ s contents

! !

!BlockMorph methodsFor: 'accessing' stamp: 'jens 3/3/2009 23:18'!
commentMorph
	"answer a comment which has been sticked to the receiver, if any"

	| sm |
	sm _ self ownerThatIsA: ScratchScriptsMorph.
	sm ifNil: [^ nil].
	^ sm submorphs detect: [: m |
		(m isKindOf: ScratchCommentMorph) and: [
			m anchor == self]] ifNone: [nil].
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jens 3/3/2009 23:17'!
hasComment
	"answer true if a comment is sticked to the receiver"

	^ self commentMorph notNil
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 3/2/2005 12:37'!
helpScreenName
	"Answer the name of the help screen for this block, or nil if no help is available."

	^ nil
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 12/9/2008 17:30'!
isArgMorph
	"True only for ArgMorphs."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 12/9/2008 17:35'!
isBlockMorph
	"True only for BlockMorphs."

	^ true
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 3/28/2005 19:14'!
isBooleanReporter
	"Answer true if this block reports a boolean value. Answer false by default."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 4/15/2007 20:02'!
isForever
	"True only for forever command blocks."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 12/21/2008 12:21'!
isHatBlock

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 6/26/2006 09:45'!
isReporter
	"Answer true if this block reports a value. False by default."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'DaveF 7/11/2003 00:41'!
isSpecialForm

	^isSpecialForm.! !

!BlockMorph methodsFor: 'accessing' stamp: 'DaveF 7/10/2003 17:39'!
isSpecialForm: aBoolean
	"Sets a flag indicating that this block has a special evaluation rule."

	isSpecialForm _ aBoolean.! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 4/15/2007 11:49'!
isStop
	"True for only stop command blocks."

	^ false
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 4/15/2007 20:02'!
isStopOrForever
	"True for stop or forever command blocks."

	^ self isStop or: [self isForever]
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 3/28/2009 20:48'!
lastLayoutTime
	"Return the millisecond clock value the last time I was sent layoutChanged. This value can be used by other morphs to detect when layout changes have occured."

	^ lastLayoutTime
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 4/4/2005 09:08'!
litUp: aBoolean
	"If the argument true, light up this block. Otherwise, revert to it's old color."
	"Note: We use super color: so we don't overwrite oldColor. We also force a world update to ensure that the highlighting is seen by the user."

	aBoolean
		ifTrue:	[super color: (Color h: 60 s: 0.9 v: 0.89)]
		ifFalse:	[oldColor ifNotNil: [super color: oldColor]].

	aBoolean ifTrue: [
		World
			cycleWhileWaitingMSecs: ScratchProcess blockHighlightMSecs
			doInput: true
			doSteps: false].
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jens 3/1/2011 00:20'!
newScriptOwner: newOwner
	"Update the receiver of all blocks to be the given morph. Used when moving scripts from one object to another."

	| rcvr |

	self allMorphsDo: [:m |
		((m isKindOf: CustomCommandBlockMorph) or: [
		m isKindOf: CustomReporterBlockMorph]) ifTrue: [
			newOwner ensureCustomBlockExists: m definition ].
		(m isKindOf: BlockMorph) ifTrue: [
			rcvr _ newOwner.
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm not]) ifTrue: [
				(m receiver isKindOf: ScratchStageMorph) ifTrue: [rcvr _ m receiver].
				newOwner ensureVariableExists: m variable.  "ensure that variable exists"
				m color: rcvr variableBlockColor].
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm]) ifFalse: [ 
				m receiver: rcvr ]].
		((m isKindOf: CommandBlockMorph) and: [
		m isSpecialForm not]) ifTrue: [
			m argMorphs do: [:arg |
				((arg isKindOf: ChoiceArgMorph) and:
				 [arg getOptionsSelector = #listVarMenu]) ifTrue: [
					arg choice ifNotNil: [newOwner ensureListExists: arg choice]]]].
		(m isKindOf: ListContentsBlockMorph) ifTrue: [
			newOwner ensureListExists: m commandSpec].
		(m isKindOf: HatBlockMorph) ifTrue: [m scriptOwner: newOwner]].
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jens 3/1/2011 00:21'!
newScriptOwnerPrivate: newOwner
	"Update the receiver of all blocks to be the given morph. Supress ensuring whether a custom block exists.
	used when creating a new recursive block"

	| rcvr |

	self allMorphsDo: [:m |

" commented out from #newScriptOwner: 
for use in ScriptableScratchMorph ->> #definitionFor:

		((m isKindOf: CustomCommandBlockMorph) or: [
		m isKindOf: CustomReporterBlockMorph]) ifTrue: [
			newOwner ensureCustomBlockExists: m definition ].
"
		(m isKindOf: BlockMorph) ifTrue: [
			rcvr _ newOwner.
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm not]) ifTrue: [
				(m receiver isKindOf: ScratchStageMorph) ifTrue: [rcvr _ m receiver].
				newOwner ensureVariableExists: m variable.  "ensure that variable exists"
				m color: rcvr variableBlockColor].
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm]) ifFalse: [ 
				m receiver: rcvr ]].
		((m isKindOf: CommandBlockMorph) and: [
		m isSpecialForm not]) ifTrue: [
			m argMorphs do: [:arg |
				((arg isKindOf: ChoiceArgMorph) and:
				 [arg getOptionsSelector = #listVarMenu]) ifTrue: [
					arg choice ifNotNil: [newOwner ensureListExists: arg choice]]]].
		(m isKindOf: ListContentsBlockMorph) ifTrue: [
			newOwner ensureListExists: m commandSpec].
		(m isKindOf: HatBlockMorph) ifTrue: [m scriptOwner: newOwner]].
! !

!BlockMorph methodsFor: 'accessing' stamp: 'tis 8/2/2006 14:29'!
presentHelpScreen
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr _ self ownerThatIsA: ScratchFrameMorph.
	fr
		ifNil: [^ nil]
		ifNotNil: [fr presentHelpScreen: self helpScreenName]
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 4/19/2004 21:36'!
receiver
	"Overridden by blocks which have receivers."

	^ nil
! !

!BlockMorph methodsFor: 'accessing' stamp: 'ee 2/21/2009 14:40'!
removeCopyTooltip

	copyTooltip delete.
	copyTooltip _ nil.
! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 6/4/2009 14:44'!
showError
	"Make this block to show an error."

	super color: (Color r: 0.831 g: 0.156 b: 0.156).! !

!BlockMorph methodsFor: 'accessing' stamp: 'jm 6/4/2009 13:19'!
showErrorFeedback
	"Show that this stack encountered an error."

	hadError _ true.
	cachedFeedbackForm _ nil.
	self changed.
! !


!BlockMorph methodsFor: 'block enumerating' stamp: 'jm 12/8/2002 19:22'!
blockSequence
	"Answer the sequence of blocks starting with myself. Each block is a submorph of the previous block."

	| result this |
	result _ OrderedCollection new: 20.
	this _ self.
	[this isNil] whileFalse: [
		result addLast: this.
		this _ this nextBlock].
	^ result asArray
! !

!BlockMorph methodsFor: 'block enumerating' stamp: 'ee 10/17/2007 15:59'!
bottomBlock
	"Answer the bottom Block of this stack. The top block may be a CommandBlockMorph, or perhaps some other kind of BlockMorph."

	| m |
	m _ self.
	[m nextBlock isKindOf: BlockMorph] whileTrue: [m _ m nextBlock].
	^ m
! !

!BlockMorph methodsFor: 'block enumerating' stamp: 'jm 6/22/2004 18:17'!
firstBlockList
	"If I am a control block, answer an array containing the block sequences for my first nested block (i.e., the blocks for the 'true' case of an if-then-else block). If I'm not a control structure block, just answer an empty array."

	^ #()
! !

!BlockMorph methodsFor: 'block enumerating' stamp: 'jm 12/8/2002 19:23'!
nextBlock
	"Answer the block myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs detect: [:m | m isKindOf: BlockMorph] ifNone: [nil]
! !

!BlockMorph methodsFor: 'block enumerating' stamp: 'jm 3/26/2005 21:08'!
nextBlock: aBlockMorph
	"Add the given block to this stack."

	self addMorph: aBlockMorph.
! !

!BlockMorph methodsFor: 'block enumerating' stamp: 'jens 12/14/2009 05:13'!
topBlock
	"Answer the top Block of this stack. The top block may be a HatBlockMorph, a CommandBlockMorph, or perhaps some other kind of BlockMorph."

	| m |
	m _ self.
	[(m owner isKindOf: BlockMorph) and: [(m owner isKindOf: ReporterBlockDropTargetMorph) not]] whileTrue: [m _ m owner].
	^ m
! !

!BlockMorph methodsFor: 'block enumerating' stamp: 'jens 6/29/2010 13:16'!
tupleSequence
	"Answer a sequence of tuples (Array) describing this stack of blocks."

	^ self blockSequence collect: [:b | b asBlockTuple]
! !


!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 07:32'!
computeHighlightColors

	| h s v |
	h _ color hue.
	s _ color saturation.
	v _ color brightness.
	highlightColor1 _ Color h: h s: (s - 0.13) v: (v + 0.1).
	highlightColor2 _ Color h: h s: s v: (v + 0.07).
	shadowColor _ color mixed: 0.7 with: Color black.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 07:31'!
drawBodyOn: aCanvas 

	aCanvas
		fillRectangle: (self left@(self top + 5) corner: (self right - 1)@(self bottom - 7))
		color: color.
	aCanvas
		fillRectangle: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 7))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(self top + 3) corner: self right@(self bottom - 7))
		color: shadowColor.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 07:31'!
drawBottomEdgeOn: aCanvas

	| right y gapStart gapEnd |
	right _ self width - 1.
	y _ self height - 7.
	gapStart _ PuzzleInset.
	gapEnd _ PuzzleInset + PuzzleWidth.

	self drawHLineFrom: 1 to: right - 1 y: y color: color on: aCanvas.
	self drawHLineFrom: 2 to: right - 2 y: y + 1 color: color on: aCanvas.

	self drawHLineFrom: gapStart to: gapEnd y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: color on: aCanvas.

	self drawHLineFrom: 3 to: gapStart y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 2 y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 6 color: shadowColor on: aCanvas.

	self drawPoint: gapStart@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: gapStart@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapStart + 1)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (gapEnd - 1)@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 1)@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 2)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (right - 1)@y color: shadowColor on: aCanvas.
	self drawPoint: (right - 2)@(y + 1) color: shadowColor on: aCanvas.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'ee 7/1/2008 15:02'!
drawFinalOn: aCanvas fromCanvas: c

	| flipped |
	ScratchTranslator isRTL 
		ifTrue: [flipped _ c form flipBy: #horizontal centerAt: c form center.
			aCanvas paintImage: flipped at: self topLeft]
		ifFalse:[aCanvas paintImage: c form at: self topLeft].
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/25/2005 16:52'!
drawHLineFrom: startX to: endX y: yOffset color: c on: aCanvas

	| y |
	y _ self top + yOffset.
	aCanvas
		fillRectangle: ((self left + startX)@y corner: (self left + endX)@(y + 1))
		color: c.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jens 4/20/2010 22:42'!
drawOn: aCanvas 

	| c |

	self contrastColor.

	self computeHighlightColors.
	c _ FormCanvas extent: self extent depth: 32.
	c _ c copyOffset: self topLeft negated.
	self isReporter ifTrue: [
		self drawSmoothTopEdgeOn: c.
		self drawReporterBodyOn: c.
		self drawSmoothBottomEdgeOn: c.
		^ self].

	self isStop ifTrue: [
		self drawTopEdgeOn: c.
		self drawStopBodyOn: c.
		self drawSmoothBottomEdgeOn: c.
		self drawFinalOn: aCanvas fromCanvas: c.
		^ self].

	self drawTopEdgeOn: c.
	self drawBodyOn: c.
	self drawBottomEdgeOn: c.

	self drawFinalOn: aCanvas fromCanvas: c.

	self drawInlinePaletteOn: aCanvas.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/25/2005 16:52'!
drawPoint: aPoint color: c on: aCanvas

	aCanvas fillRectangle: (self topLeft + aPoint extent: 1) color: c.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 07:31'!
drawReporterBodyOn: aCanvas 

	aCanvas
		fillRectangle: (self left@(self top + 3) corner: (self right - 1)@(self bottom - 3))
		color: color.
	aCanvas
		fillRectangle: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 3))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(self top + 2) corner: self right@(self bottom - 3))
		color: shadowColor.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 07:31'!
drawSmoothBottomEdgeOn: aCanvas

	| right y |
	right _ self width - 1.
	y _ self height - 3.

	self drawHLineFrom: 1 to: right - 1 y: y color: color on: aCanvas.
	self drawHLineFrom: 2 to: right - 2 y: y + 1 color: color on: aCanvas.
	self drawHLineFrom: 3 to: right - 2 y: y + 2 color: shadowColor on: aCanvas.

	self drawPoint: (right - 1)@y color: shadowColor on: aCanvas.
	self drawPoint: (right - 2)@(y + 1) color: shadowColor on: aCanvas.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/26/2005 12:12'!
drawSmoothTopEdgeOn: aCanvas

	| right |
	right _ self width - 1.

	self drawHLineFrom: 2 to: right - 2 y: 0 color: highlightColor1 on: aCanvas.
	self drawHLineFrom: 1 to: right - 1 y: 1 color: highlightColor2 on: aCanvas.
	self drawHLineFrom: 0 to: right y: 2 color: color on: aCanvas.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 4/15/2007 19:40'!
drawStopBodyOn: aCanvas 

	aCanvas
		fillRectangle: (self left@(self top + 5) corner: (self right - 1)@(self bottom - 3))
		color: color.

	aCanvas
		fillRectangle: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 3))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(self top + 2) corner: self right@(self bottom - 3))
		color: shadowColor.
! !

!BlockMorph methodsFor: 'drawing' stamp: 'jm 3/26/2005 13:22'!
drawTopEdgeOn: aCanvas

	| right gapStart gapEnd |
	right _ self width - 1.
	gapStart _ PuzzleInset.
	gapEnd _ PuzzleInset + PuzzleWidth.

	self drawHLineFrom: 2 to: gapStart y: 0 color: highlightColor1 on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 2 y: 0 color: highlightColor1 on: aCanvas.

	self drawHLineFrom: 1 to: gapStart y: 1 color: highlightColor2 on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 1 y: 1 color: highlightColor2 on: aCanvas.

	self drawHLineFrom: 0 to: gapStart + 1 y: 2 color: color on: aCanvas.
	self drawHLineFrom: gapEnd - 1 to: right y: 2 color: color on: aCanvas.

	self drawHLineFrom: 0 to: gapStart + 2 y: 3 color: color on: aCanvas.
	self drawHLineFrom: gapEnd - 2 to: right y: 3 color: color on: aCanvas.

	self drawHLineFrom: 0 to: right y: 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: 4 color: highlightColor1 on: aCanvas.
! !


!BlockMorph methodsFor: 'drawing-optimization' stamp: 'jm 12/4/2006 13:56'!
changed
	"Don't flush my cachedForm when I do 'self changed'."

	owner ifNotNil: [owner invalidRect: (self fullBounds expandBy: 3)].
! !

!BlockMorph methodsFor: 'drawing-optimization' stamp: 'jm 11/30/2006 21:42'!
fullBounds
	"This is the hook that triggers lazy re-layout. It works because layoutChanged clears the fullBounds cache. Once per cycle, the fullBounds is requested from every morph in the world, and that request gets propagated through the entire submorph hierarchy, causing re-layout where needed. Note that multiple layoutChanges to the same morph can be done with little cost, since the layout is only done when the morph needs to be displayed."
	"Detail: Expands by 3 pixels if I have a process to allow for the running/error feedback."

	fullBounds ifNil: [
		"do layout here"
		blockLayoutNeeded ifTrue: [
			super fullBounds.
			self fixBlockLayout.
			fullBounds _ nil.
			super fullBounds.  "recompute after layout"
			self changed].
		blockLayoutNeeded _ false].

	scratchProc ifNotNil: [^ super fullBounds expandBy: 3].  "allow for running/error feedback"

	^ super fullBounds
! !

!BlockMorph methodsFor: 'drawing-optimization' stamp: 'jens 4/26/2010 01:59'!
fullDrawOn: aCanvas
	"Optimization: To speed up redisplay, especially when giving feedback that a stack is running, we create a cached form of the stack in the top block of the stack and simply display that. We also keep a cached image of the running/error feedback outline. This allows the running feedback to be turned on and off quickly. The caches are flushed whenever the layout of the stack changes."

	| offset |
	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(owner isKindOf: BlockMorph) ifTrue: [^ super fullDrawOn: aCanvas].  "only cache at top level"

	cachedForm ifNil: [self updateCachedForm].
	cachedForm ifNil: [^ super fullDrawOn: aCanvas].  "should not happen"

	offset _ 0@0.
	scratchProc ifNotNil: [
		offset _ 3@3.
		cachedFeedbackForm ifNil: [self updateCachedFeedbackForm].
		cachedFeedbackForm ifNotNil: [
			aCanvas paintImage: cachedFeedbackForm at: self fullBounds topLeft]].

	cachedForm ifNil: [^ self].
	aCanvas paintImage: cachedForm at: self fullBounds topLeft + offset.
! !

!BlockMorph methodsFor: 'drawing-optimization' stamp: 'jm 12/4/2006 13:55'!
invalidRect: damageRect
	"Flush my cachedForm if some submorph reports a change."

	super invalidRect: (damageRect expandBy: 3).  "allows for running feedback"
	cachedForm _ nil.
! !

!BlockMorph methodsFor: 'drawing-optimization' stamp: 'jm 11/29/2006 12:29'!
updateCachedFeedbackForm
	"Create a cached feedback Form to show this stack's running (or error) status."

	| outlineColor |
	cachedForm ifNil: [^ self].
	outlineColor _ (scratchProc notNil and: [scratchProc errorFlag])
		ifTrue: [Color r: 0.831 g: 0.156 b: 0.156]
		ifFalse: [Color gray: 0.953].

	cachedFeedbackForm _ cachedForm
		outlineWidth: 3
		color: outlineColor
		depth: 8.
! !

!BlockMorph methodsFor: 'drawing-optimization' stamp: 'jm 6/4/2009 14:54'!
updateCachedForm
	"Create a cached Form of this stack's appearance."

	| c offset |
	oldColor ifNotNil: [color _ oldColor].
	c _ FormCanvas extent: self fullBounds extent depth: 32.
	ScratchTranslator isRTL
		ifTrue: [
			offset _ scratchProc ifNil: [0@0] ifNotNil: [3@3].
			c _ c copyOffset: (self fullBounds topLeft + offset) negated]
		ifFalse: [c _ c copyOffset: self topLeft negated].
	self drawOn: c.
	self drawSubmorphsOn: c.
	cachedForm _ c form.
	lastLayoutTime _ Time millisecondClockValue.
! !


!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jens 4/17/2010 20:32'!
aboutToBeGrabbedBy: aHandMorph
	"If I'm being used as an argument, replace myself with an appropriate argument morph. Copied from WatcherMorph."

	| m |
	(owner isKindOf: CommandBlockMorph) 
	| (owner isKindOf: WhenHatBlockMorph)
	| (owner isKindOf: MultiArgMorph) ifTrue: [
		"if I was being used as argument, replace myself with a generic argument morph"
		m _ owner argMorphToReplace: self. 
		m ifNotNil: [owner replaceArgMorph: self by: m]].
! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jens 8/3/2010 08:47'!
attachBlock: aBlockMorph
	"Attach the given block to me. Assume the block has been positioned correctly."

	self addMorph: aBlockMorph.
! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jens 3/23/2010 23:50'!
handleReporterDrop
	"This block, a reporter, has just been dropped. Try to embed it in a command block."

	| scriptsMorph editorMorph argM argOwner trgt tp|
	scriptsMorph _ self ownerThatIsA: ScratchScriptsMorph.
	editorMorph _ self ownerThatIsA: BlockEditorFrameMorph.
	trgt _ scriptsMorph ifNil: [editorMorph].

	self isReporter ifTrue: [
		(#(
			'ScratchScriptsMorph'
			'BlockEditorFrameMorph'
			'ReporterBlockDropTargetMorph'
		) includes: owner class printString) ifFalse: [^self ]].

	argM _ owner topArgMorphAt: self bounds exclude: self.
	(argM notNil and: [argM acceptsTypeOf: self]) ifFalse: [
		scriptsMorph ifNotNil: [
			scriptsMorph recordDroppedBlock: self bottom: nil kickedOut: nil ].
		^ self].

	"tp _ argM owner typeOfArg: argM."

	(argM isKindOf: BlockMorph)
		ifTrue: [
			argOwner _ argM owner.
			argOwner replaceArgMorph: argM by: self.
			((argM isKindOf: CSlotMorph) or: [
			argM isKindOf: OSlotMorph]) ifTrue: [
				argM _ argM body ].
			trgt ifNotNil: [ argM ifNotNil: [
				trgt addMorph: argM.
				argM position: (argOwner left+90)@(argM top - 20)]].
			scriptsMorph ifNotNil: [
				scriptsMorph recordDroppedBlock: self bottom: nil kickedOut: argM]]
		ifFalse: [
			argM owner replaceArgMorph: argM by: self.
			scriptsMorph ifNotNil: [
				scriptsMorph recordDroppedBlock: self bottom: nil kickedOut: nil]].

"
	#reporter = tp ifTrue: [
		self lambdaMenu ]

"! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jens 12/14/2009 05:17'!
justDroppedInto: newOwner event: evt
	"Handle being dropped into a new situation."

	| frame targetAssoc targetP targetBlock bottomBlockUsed upperBlock |
	bottomBlockUsed _ false.

	owner ifNil:	[^self].

	(frame _ newOwner ownerThatIsA: ScratchFrameMorph)
		ifNotNil: [frame projectModified].

	((self ownerThatIsA: ScratchViewerMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area"
		self delete.
		^ self].

	((self ownerThatIsA: ScratchBlockPaletteMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area of a Block Editor"
		self delete.
		^ self].

	"blocks cannot be dropped onto the stage"
	(owner isKindOf: ScratchStageMorph) ifTrue: [
		^ self rejectDropEvent: evt].

	"okay to drop blocks into the world during development"
	((owner == World) and: [Preferences noviceMode not]) ifTrue: [^ self].

	((owner isKindOf: ScratchScriptsMorph) or:
	 [(owner isKindOf: BlockMorph) or:
	 [(owner isKindOf: ScratchStageMorph) and: [self isReporter]]]) ifFalse: [
		^ self rejectDropEvent: evt].

	self isReporter ifTrue: [^ self handleReporterDrop].
	(newOwner isKindOf: ScratchScriptsMorph) ifTrue: [
		newOwner recordDroppedBlock: self bottom: self bottomBlock kickedOut: nil].

	targetAssoc _ self closestAttachTargetIn: newOwner.
	targetAssoc ifNil: [
		(self bottomBlock isKindOf: CBlockMorph) ifFalse: [
			targetAssoc _ self bottomBlock closestAttachTargetIn: newOwner.
			targetAssoc ifNotNil:[
				bottomBlockUsed _ true.
				(targetAssoc value owner isKindOf: BlockMorph) ifTrue:[
					targetAssoc _ nil]]]].
	targetAssoc ifNil: [^ self].

	"make sure no processes are running"
	self = self topBlock ifTrue: [self stop].

	targetP _ targetAssoc key.
	targetBlock _ targetAssoc value.

	self allMorphsDo: [:m | m == targetBlock ifTrue: [^self ]].	"avoid infinite recursion, kludge for BYOB"

	targetP y = targetBlock top
		ifTrue: [
			"c-shaped block should nest the target block"
			((bottomBlockUsed not) and: [(self isKindOf: CBlockMorph)]) ifTrue:[
				(targetBlock owner isKindOf: BlockMorph)
					ifTrue: [(targetBlock owner) attachBlock: self]
					ifFalse: [self position: (targetP x - self bracketThickness)@(targetP y - self topBarHeight - 3)].
				(newOwner respondsTo: #recordNestedStack:) ifTrue: [
					newOwner recordNestedStack: targetBlock ].
				self attachBlockNested: targetBlock. ^ self].
			"for all other non-c-shaped blocks"
			(bottomBlockUsed or:[((targetBlock owner isKindOf: BlockMorph) not) and: [(self isKindOf: CBlockMorph) not]]) ifTrue:[
				ScratchTranslator isRTL
					ifTrue: [self bottomBlock position: (targetP x - self bottomBlock width) @ (targetP y - (self bottomBlock height - 4))]
					ifFalse: [self bottomBlock position: targetP x @ (targetP y - (self bottomBlock height - 4))].
				upperBlock _ self bottomBlock owner.
				[upperBlock isKindOf: BlockMorph] whileTrue: [
					upperBlock nextBlock ifNotNil:[
						ScratchTranslator isRTL
							ifTrue: [upperBlock position: (targetP x - upperBlock width) @ (upperBlock nextBlock position y - (upperBlock height - 4))]
							ifFalse: [upperBlock position: targetP x @ (upperBlock nextBlock position y - (upperBlock height - 4))].
						upperBlock _ upperBlock owner]]].
			((bottomBlockUsed not) and: [targetBlock owner isKindOf: BlockMorph]) ifTrue:[
				ScratchTranslator isRTL
					ifTrue: [self position: (targetP x - self width) @ (targetP y - (self height - 4))]
					ifFalse: [self position: targetP x @ (targetP y - (self height - 4))]].
			(targetBlock owner isKindOf: BlockMorph) ifTrue:[
				ScratchTranslator isRTL
					ifTrue: [self topBlock position: (targetP x - self topBlock width) @ targetP y]
					ifFalse: [self topBlock position: targetP x @ targetP y].
				targetBlock owner attachBlock: self topBlock].
			ScratchTranslator isRTL
				ifTrue: [targetBlock position: (targetP x - targetBlock width) @ (self bottomBlock position y + self bottomBlock height + 4)]
				ifFalse: [targetBlock position: targetP x @ (self bottomBlock position y + self bottomBlock height + 4)].
			((bottomBlockUsed not) and: [((targetBlock owner isKindOf: BlockMorph) not) and: [(self isKindOf: CBlockMorph)]]) ifFalse:[
				self bottomBlock attachBlock: targetBlock]]
		ifFalse: [
			self assert: [(self isKindOf: HatBlockMorph) not].  "I am not a HatBlockMorph"
			ScratchTranslator isRTL
				ifTrue: [self position: (targetP - (self width @0))]
				ifFalse: [self position: targetP].

			targetBlock attachBlock: self].
! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'JM 10/26/2011 11:40'!
receiver: anObject
	"Set my receiver. Does nothing here, but overridden in blocks that have a receiver."
! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jm 8/3/2003 10:02'!
rejectDropEvent: evt
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.
! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jm 3/17/2003 17:59'!
rootForGrabOf: aMorph
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].
! !

!BlockMorph methodsFor: 'dropping/grabbing' stamp: 'jens 12/9/2009 13:20'!
slideBackToFormerSituation: evt

	| wasEmbedded o pane oldP slideForm startPoint s |
	wasEmbedded _ false.
	(o _ evt hand formerOwner) ifNil: [^ self].
	(o isKindOf: BlockMorph) ifTrue: [
		wasEmbedded _ true.
		(pane _ o ownerThatIsA: ScratchScriptsMorph) ifNotNil: [
			o _ pane]].

	"restore the old position relative to the old owner,
	in case the old owner has been scrolled in the meantime"
	oldP _ evt hand formerPosition + o position.

	slideForm _ self imageForm offset: 0@0.
	startPoint _ evt hand fullBounds origin.
	owner isNil ifFalse: [owner privateRemoveMorph: self].
	self world isNil ifFalse: [self world displayWorld ].
	slideForm slideFrom: startPoint to: oldP nSteps: 12 delay: 15.
	self position: oldP.
	o addMorph: self.
	wasEmbedded ifTrue: [self justDroppedInto: o event: evt].

	"scroll the dropped morph into view in case the owner has been
	scrolled in the meantime"
	s _ o ownerThatIsA: ScrollFrameMorph.
	s ifNotNil: [s scrollMorphIntoView: self ]

! !


!BlockMorph methodsFor: 'event handling' stamp: 'jm 12/30/2008 18:18'!
click: evt
	"If a tool is selected, handle a click with that tool. Otherwise, toggle my process."

	evt hand toolType ifNotNil: [
		"handle mouse clicks when the mouse is in different modes"
		^ self handleTool: evt hand toolType hand: evt hand].

	self topBlock toggleProcess.
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 1/4/2007 23:28'!
delete

	self topBlock stop.
	ScratchFrameMorph putInClipboard: self.
	super delete
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 12/30/2008 18:10'!
doubleClick: evt
	"If I'm a block with a receiver that's in a Scratch window, execute me."

	self topBlock toggleProcess.
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jens 5/3/2010 21:30'!
duplicate

	World activeHand attachMorph: self fullCopy.
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jens 12/4/2009 01:06'!
handleTool: toolName hand: hand

	| myStack myOwner copiedStack sFrame varToDelete |
	toolName = 'CopyTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(owner isKindOf: ScratchBlockPaletteMorph) ifTrue: [^ self].  "ignore if in palette"
		^ self duplicate].

	toolName = 'CutTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(self topBlock owner isKindOf: ScratchScriptsMorph) ifTrue: [
			myStack _ self nextBlock.
			myOwner _ self owner.
			myStack ifNotNil: [
				(myOwner isKindOf: CBlockMorph)
					ifTrue: [
						copiedStack _ myStack shallowCopy.
						self topBlock owner addMorph: copiedStack.
						[myStack top > myOwner bottom] whileTrue: [
							myStack position: (myStack left)@(myStack top - 1).
							self world displayWorldSafely].
						copiedStack delete.
						myOwner attachBlock: myStack]
					ifFalse: [
						(myOwner isKindOf: ScratchScriptsMorph)
							ifTrue: [myOwner addMorph: myStack]
							ifFalse: [
								copiedStack _ myStack shallowCopy.
								(self topBlock owner) addMorph: copiedStack.
								[myStack top > myOwner bottom] whileTrue: [
									myStack position: (myStack left)@(myStack top - 1).
									self world displayWorldSafely].
								copiedStack delete.
								myOwner attachBlock: myStack]]].

				self isReporter ifTrue: [
					owner ifNotNil: [(owner isKindOf: CustomCommandBlockMorph)
						ifTrue: [ owner isTemplate ifTrue: [
							owner removeParameter: self.
							^self]]].
					self aboutToBeGrabbedBy: hand].
				ScratchFrameMorph putInClipboard: self.
				self delete.
				(myOwner isKindOf: ScratchScriptsMorph) ifTrue: [myOwner step].
				^ self]
		ifFalse: [
			sFrame _ self ownerThatIsA: ScratchFrameMorph.
			sFrame ifNil: [^self].
			((owner isKindOf: ScratchBlockPaletteMorph) and:
			 [sFrame viewerPane currentCategory = #variables]) ifTrue: [
				(self isKindOf: SetterBlockMorph) ifTrue: [
					self variable ifNotNil: [
						varToDelete _ self variable.
						(self confirm: 'Really delete variable: ', varToDelete, '?') ifFalse: [^ self].
						self receiver deleteVariable: varToDelete]].
				(self isKindOf: VariableBlockMorph) ifTrue: [
					varToDelete _ self commandSpec.
					(self confirm: 'Really delete variable: ', varToDelete, '?') ifFalse: [^ self].
					self receiver deleteVariable: varToDelete].
				((varToDelete notNil) and: [sFrame notNil]) ifTrue: [
					sFrame workPane deleteVariable: varToDelete.
					sFrame viewerPane categoryChanged: 'variables']]].
	^ self].

! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 8/13/2003 10:22'!
handlesMouseDown: evt

	^ true
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 11/27/2007 16:03'!
mouseDown: evt
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.
	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[evt hand waitForClicksOrDrag: self event: evt].
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 12/19/2008 15:45'!
mouseHold: evt

	self rightButtonMenu.
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jens 10/5/2010 10:20'!
rightButtonMenu

	| menu |
	menu _ CustomMenu new.
	menu add: 'help' action: #presentHelpScreen.

	(owner isKindOf: ScratchBlockPaletteMorph) ifFalse: [
		menu addLine.
		menu add: 'duplicate' action: #duplicate.	
		(self owner isKindOf: BlockMorph) ifFalse: [  "we can't yet delete a blocks inside a script"
			menu add: 'delete' action: #delete]].

	DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' action: #showTuples].
	
	menu localize; invokeOn: self.
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 8/7/2007 14:32'!
showTuples

	(StringHolder new contents: self tupleSequence printString)
		openLabel: 'Tuple'! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 12/13/2006 21:27'!
startDrag: evt

	| startEvt rootForGrab |
	evt hand toolType ifNil: [
		startEvt _ evt hand firstClickEvent.
		startEvt ifNil: [startEvt _ evt].
		rootForGrab _ self rootForGrabOf: self.
		rootForGrab ifNil: [^ self].
		evt hand grabMorph: rootForGrab.
		rootForGrab position: evt hand position + (rootForGrab topLeft - startEvt cursorPoint)].

	self handleTool: evt hand toolType hand: evt hand.
! !

!BlockMorph methodsFor: 'event handling' stamp: 'jm 10/20/2004 15:02'!
wantsKeyboardFocusFor: aSubmorph
	"Don't allow shift-click editing of block labels."

	^ false
! !


!BlockMorph methodsFor: 'processes' stamp: 'jm 6/4/2009 13:25'!
clearProcess
	"Called on the top block of a running stack when all processes are stopped."

	scratchProc ifNotNil: [self scratchProc: nil].
! !

!BlockMorph methodsFor: 'processes' stamp: 'jm 6/4/2009 13:01'!
hasRunningProcess

	^ scratchProc notNil and: [scratchProc isRunning]
! !

!BlockMorph methodsFor: 'processes' stamp: 'jm 6/4/2009 13:44'!
scratchProc: aScratchProcess

	hadError == true ifTrue: [cachedFeedbackForm _ nil].
	hadError _ false.
	scratchProc _ aScratchProcess.
	self changed.
! !

!BlockMorph methodsFor: 'processes' stamp: 'jm 3/12/2004 04:19'!
start
	"Start a process running this block stack. This default implementation does nothing."
! !

!BlockMorph methodsFor: 'processes' stamp: 'jm 11/29/2006 11:53'!
stop

	scratchProc ifNotNil: [
		self changed.
		scratchProc stop.
		scratchProc _ nil].
! !

!BlockMorph methodsFor: 'processes' stamp: 'jm 6/4/2009 13:28'!
toggleProcess

	(scratchProc isNil or: [scratchProc errorFlag])
		ifTrue: [self start]
		ifFalse: [self stop].
! !


!BlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:51'!
fieldsVersion

	^ 1
! !

!BlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:52'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isSpecialForm
		oldColor
	) from: anObjStream.
! !

!BlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:17'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isSpecialForm
		oldColor
	) on: anObjStream.
! !


!BlockMorph methodsFor: 'private' stamp: 'ee 3/3/2008 14:36'!
blockAttachPoints: aSet
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| nextB result |
	result _ #().
	(self isKindOf: HatBlockMorph) ifFalse: [
		ScratchTranslator isRTL
			ifTrue: [result _ result copyWith: (self topRight -> self)]
			ifFalse: [result _ result copyWith: (self topLeft -> self)]].
	nextB _ self nextBlock.
	nextB ifNil:[
		self isStopOrForever ifFalse: [
			ScratchTranslator isRTL
				ifTrue: [result _ result copyWith: (self bottomRight -> self)]
				ifFalse: [result _ result copyWith: (self bottomLeft -> self)]]].

	nextB
		ifNotNil: [nextB blockAttachPoints: aSet].

	aSet addAll: result.
! !

!BlockMorph methodsFor: 'private' stamp: 'jm 3/29/2009 12:58'!
commentLayoutChanged

	lastLayoutTime _ Time millisecondClockValue.

! !

!BlockMorph methodsFor: 'private' stamp: 'md 6/10/2004 17:24'!
copyRecordingIn: aDict

		^ (super copyRecordingIn: aDict) clearProcess.
	! !

!BlockMorph methodsFor: 'private' stamp: 'jens 1/8/2010 01:25'!
fixBlockLayout
	"This default implementation just clears my cached forms."

	blockLayoutNeeded ifFalse: [^ self].
	cachedForm _ nil.
	cachedFeedbackForm _ nil.
! !

!BlockMorph methodsFor: 'private' stamp: 'jens 2/11/2010 00:15'!
layoutChanged

	blockLayoutNeeded ifFalse: [super layoutChanged].
	blockLayoutNeeded _ true.

! !

!BlockMorph methodsFor: 'private' stamp: 'jm 11/29/2006 12:21'!
nonControlFlowSubmorphs
	"Answer a collection of submorphs minus any blocks that are part of the control flow. For example, command blocks omit their submorph that is the next block in the block sequence, C-blocks omit both their next block and the first block of their nested block list, etc."

	^ submorphs select: [:m | (m ~~ self nextBlock)]
! !

!BlockMorph methodsFor: 'private' stamp: 'jm 12/10/2005 11:03'!
printCodeOn: aStream indent: indent
	"Append a human-readable string for this block on the given stream."

	indent timesRepeat: [aStream nextPutAll: '    '].
	aStream nextPutAll: self class name; cr.
	self nextBlock ifNotNil: [self nextBlock printCodeOn: aStream indent: indent].
! !

!BlockMorph methodsFor: 'private' stamp: 'jm 3/14/2009 13:51'!
printCodeSubmorph: aMorph on: aStream

	(aMorph isKindOf: ArgMorph) ifTrue: [aMorph printArgOn: aStream].
	(aMorph isKindOf: BlockMorph) ifTrue: [
		aStream nextPut: $(.
		aMorph printCodeOn: aStream indent: 0.
		aStream skip: -1.  "remove carriage return"
		aStream nextPut: $)].
	(aMorph isKindOf: StringMorph) ifTrue: [
		((aMorph contents = '?') | (aMorph contents = '%'))
			ifTrue: [aStream skip: -1].	"remove space before ? or %"
		aStream nextPutAll: aMorph contents].
! !

!BlockMorph methodsFor: 'private' stamp: 'jens 6/28/2010 21:54'!
tabFields

	| fields nxt nxtFields |
	fields _ OrderedCollection new.
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: ExpressionArgMorph)
			ifTrue: [fields add: m ]
			ifFalse: [(m respondsTo: #tabFields)
				ifTrue: [fields addAll: m tabFields ]]]. 

	nxt _ self nextBlock.
	nxt ifNil: [^ fields].
	nxtFields _ nxt tabFields.
	nxtFields size = 0 ifTrue: [
		^ fields ].
	^ fields, nxtFields 
! !


!BlockMorph methodsFor: 'BYOB OOP' stamp: 'jens 2/8/2011 13:21'!
disinheritAttribute

	| sel rcv oi |
	(self ownerThatIsA: ScratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel _ self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv _ self receiver.
	(rcv isKindOf: ScriptableScratchMorph) 
		ifFalse: [^ false].
	oi _ rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv undeleteAttribute: att]].
	^ false! !

!BlockMorph methodsFor: 'BYOB OOP' stamp: 'jens 2/8/2011 13:20'!
inheritAttribute

	| sel rcv oi |
	(self ownerThatIsA: ScratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel _ self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv _ self receiver.
	(rcv isKindOf: ScriptableScratchMorph) 
		ifFalse: [^ false].
	oi _ rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv deleteAttribute: att]].
	^ false! !

!BlockMorph methodsFor: 'BYOB OOP' stamp: 'jens 2/17/2011 22:54'!
isDeletedAttribute

	| sel rcv oi |
	(self ownerThatIsA: ScratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel _ self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv _ self receiver.
	(rcv isKindOf: ScriptableScratchMorph) 
		ifFalse: [^ false].

	((self isKindOf: VariableBlockMorph) 
	or: [self isKindOf: ListContentsBlockMorph]) ifTrue: [
		^ (rcv allVarNames includes: self commandSpec) not].

	self isCustomBlock ifTrue: [
		^ rcv inheritedBlockIds includes: self id].

	sel = #get: ifTrue: [
		 ^ rcv deletedAttributes includes: (self argumentAt: 1) choice].
		
	oi _ rcv objectInterface.
	rcv deletedAttributes do: [:att |
		(oi at: att) second = sel ifTrue: [
			^ true]].
	^ false! !

!BlockMorph methodsFor: 'BYOB OOP' stamp: 'jens 2/8/2011 13:25'!
isInheritableAttribute
	"indicate if my context menu lets me delete my attribute"

	| sel rcv oi |
	(self ownerThatIsA: ScratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel _ self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv _ self receiver.
	(rcv isKindOf: ScriptableScratchMorph) 
		ifFalse: [^ false].
	rcv prototype ifNil: [
		^ false].
	oi _ rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ true]].
	^ false! !


!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/13/2010 23:40'!
addAreasOf: outerRect outside: innerRect color: col to: coll

	coll addAll: (((outerRect areasOutside: innerRect) 
		collect: [:r | Array with: r with: col])
		reject: [:pair | ((pair first intersects: innerRect) 
					and: [(pair first right > innerRect left) 
					and: [(pair first left > innerRect left)
					and: [pair first top < innerRect bottom]]])
					or: [pair first left > innerRect right]])! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/12/2010 21:44'!
addHLineFrom: startX to: endX y: yOffset color: c to: coll

	| y |
	y _ self top + yOffset.
	coll add: (Array
				with: ((self left + startX)@y corner: (self left + endX)@(y + 1))
				with: c)! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/12/2010 21:43'!
addPoint: aPoint color: c to: coll

	coll add: (Array 
				with: (self topLeft + aPoint extent: 1)
				with: c)
! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 11/6/2009 11:52'!
cachedForm
	^cachedForm! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'DaveF 8/4/2003 15:07'!
color: aColor
	"Remember the color of this block, for lighting-up purposes."

	super color: aColor.
	oldColor _ aColor.! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 2/17/2011 22:56'!
contrastColor

	| ob |

	isContrasted _ false.
	originalColor ifNotNil: [
		color _ originalColor ].
	Contrast = #off ifTrue: [
		self isDeletedAttribute ifFalse: [
			^ self ]].
	self isDeletedAttribute 
		ifTrue: [^ color _ color twiceLighter]
		ifFalse: [
			ob _ self outerLoop.
			ob ifNil: [ 
				self isReporter
					ifTrue: [
						(owner isKindOf: MultiArgMorph)
							ifTrue: [ob _ owner owner]
							ifFalse: [ob _ owner]]
					ifFalse: [
						((owner isKindOf: ProcedureHatBlockMorph) and: [owner nextBlock ~= self])
							ifTrue: [ob _ owner]]]].
	ob ifNil: [^ self ].
	ob color = color ifTrue: [
		originalColor _ color.
		#slight = Contrast ifTrue: [ ^ color _ color slightlyLighter ].
		#normal = Contrast ifTrue: [ ^ color _ color lighter ].
		#strong = Contrast ifTrue: [
			isContrasted _ true.
			color _ color twiceLighter " lighter slightlyLighter "]].

	submorphs do: [:m | (m isKindOf: StringMorph)
		ifTrue: [m color: self labelColor ]
		ifFalse: [ (m isKindOf: MultiArgMorph)
			ifTrue: [m contrastColor]]].	

! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/8/2010 05:51'!
drawInlinePaletteOn: aCanvas
	^self! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 3/23/2010 22:12'!
isBlockTemplate

	^ (self rootForGrabOf: self) ~= self! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/20/2010 00:35'!
isCShape

	^ false! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/27/2010 12:39'!
isContrasted
	^isContrasted ifNil: [isContrasted _ false]! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 2/3/2010 10:11'!
isContrasted: bool
	isContrasted _ bool! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 1/12/2010 04:03'!
isCustomBlock
	^false! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 12/17/2009 02:07'!
isLambdaForm
	^false! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/20/2010 12:32'!
isNestedCShape

	^ self outerLoop notNil
! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/20/2010 00:45'!
nests: aBlock
	^ false! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 4/20/2010 11:13'!
outerLoop

	| all |
	all _ self allOwners select: [:o | (o isKindOf: BlockMorph) and: [o notNil and: [o isCShape]]].
	all size < 1 ifTrue: [^ nil].
	^ all detect: [:o | o nests: self] ifNone: [nil]! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 5/18/2010 01:04'!
pauseProcess
	"Called on the top block of a running stack when all processes are stopped."

	scratchProc ifNotNil: [scratchProc pause].
! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 3/3/2010 16:26'!
refreshAttributeArgs

	self allMorphsDo: [:m |
		(m isKindOf: AttributeArgMorph) ifTrue: [
			m refresh ]]! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 5/18/2010 01:06'!
resumeProcess
	"Called on the top block of a running stack when all processes are stopped."

	scratchProc ifNotNil: [scratchProc resume].
! !

!BlockMorph methodsFor: 'byob lambdas' stamp: 'jens 5/18/2010 01:10'!
scratchProc
	^ scratchProc! !


!BlockMorph methodsFor: 'byob fast copying' stamp: 'jens 6/18/2010 02:06'!
fastCopy

	"copies only the receiver without the nextBlock and its parts"

	| dict new |
	dict _ IdentityDictionary new: 100.
	new _ self fastCopyRecordingIn: dict.
	new allMorphsDo: [:m | m updateReferencesUsing: dict].
	^ new	! !

!BlockMorph methodsFor: 'byob fast copying' stamp: 'jens 6/18/2010 02:06'!
fastCopyRecordingIn: dict

	"copies just the receiver withoug the nextBlock and its parts"

	| new parts |
	new _ self copy.
	dict at: self put: new.
	parts _ self nonControlFlowSubmorphs.
	parts size > 0 ifTrue: [
		new privateSubmorphs:
			(parts collect: [:m |
				(m copyRecordingIn: dict) privateOwner: new])].

	properties ifNotNil: [new privateProperties: properties copyAll].
	^ new
! !

!BlockMorph methodsFor: 'byob fast copying' stamp: 'jens 6/16/2010 23:11'!
fastDuplicate

	"for debugging"

	World activeHand attachMorph: self fastCopy.
! !


!BlockMorph methodsFor: 'Cellular' stamp: 'JM 10/26/2011 11:39'!
setReceiversForClone: aSprite

	"used by cellular after cloning the blocksbin of the prototype. ensures that all command blocks have their receiver set to the correct sprite."

	self receiver: aSprite.

	(self submorphs select: [ :sub | sub isKindOf: BlockMorph ]) do: [ :each |
		each setReceiversForClone: aSprite ].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BlockMorph class
	instanceVariableNames: ''!

!BlockMorph class methodsFor: 'class initialization' stamp: 'jens 1/8/2010 03:17'!
contrast
	^ Contrast! !

!BlockMorph class methodsFor: 'class initialization' stamp: 'jens 1/8/2010 03:08'!
contrastNormal
	Contrast _ #normal.
	BlockMorph allInstancesDo: [:b | b changed ].! !

!BlockMorph class methodsFor: 'class initialization' stamp: 'jens 1/8/2010 03:03'!
contrastOff
	Contrast _ #off.
	BlockMorph allInstancesDo: [:b | b changed ].! !

!BlockMorph class methodsFor: 'class initialization' stamp: 'jens 1/8/2010 03:05'!
contrastSlight
	Contrast _ #slight.
	BlockMorph allInstancesDo: [:b | b changed ].! !

!BlockMorph class methodsFor: 'class initialization' stamp: 'jens 3/18/2010 10:58'!
contrastStrong
	Contrast _ #strong.
	ReporterBlockMorph allInstancesDo: [:b | b changed ].! !

!BlockMorph class methodsFor: 'class initialization' stamp: 'nb 1/20/2008 19:38'!
initialize
	"self initialize"

	LabelColor _ Color white.

	PuzzleInset _ 11.
	PuzzleWidth _ 14.
	CBlockBracketThickness _ 12.

	DebugMenu _ false.
! !

!BlockMorph class methodsFor: 'class initialization' stamp: 'jm 6/20/2007 19:06'!
setLabelFont
	"BlockMorph setLabelFont"

	| menu fName fSize |
	menu _ CustomMenu new.
	StrikeFont fontNames do: [:fn | menu add: fn action: fn].
	menu addLine.
	menu add: 'normal' action: #normal.
	(fName _ menu startUp) ifNil: [^ self].

	#normal = fName ifTrue: [
		LabelFont _ StrikeFont fontName: 'VerdanaBoldNarrowSpace' size: 10.
		^ self].

	menu _ CustomMenu new.
	(StrikeFont sizesForFontName: fName) do: [:sz | menu add: sz printString action: sz].
	(fSize _ menu startUp) ifNil: [^ self].
	LabelFont _ StrikeFont fontName: fName size: fSize.
! !


BlockMorph initialize!
