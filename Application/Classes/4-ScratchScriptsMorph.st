PasteUpMorph subclass: #ScratchScriptsMorph
	instanceVariableNames: 'feedbackMorph lambdaMorph screenshooting droppedBlock droppedBottom kickedOutReporter nestedStack '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchScriptsMorph commentStamp: 'jm 8/3/2003 09:30' prior: 0!
I hold the scripts and partially assembled scripts for a ScriptableScratchMorph.
!


!ScratchScriptsMorph methodsFor: 'initialization' stamp: 'ee 11/4/2008 11:49'!
initialize

	super initialize.
	color _ Color white.
	borderWidth _ 0.
	self enableDragNDrop: true.
! !


!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'jens 3/3/2009 21:46'!
showCommentDropFeedback

	| hand comment target r |

	hand _ World activeHand.
	comment _ hand firstSubmorph.
	target _ comment attachTargetIn: self.
	target ifNil: [^ self].

	r _ target bounds.

	((target isKindOf: CBlockMorph) and: [target firstBlockList size > 0])
		ifTrue: [r _ r merge: target firstBlockList first fullBounds].
	(target isKindOf: IfElseBlockMorph)
		ifTrue: [
			(target trueBlockList size > 0)
				ifTrue: [r _ r merge: target trueBlockList first fullBounds].
			(target falseBlockList size > 0)
				ifTrue: [r _ r merge: target falseBlockList first fullBounds]].
	feedbackMorph
		bounds: (r expandBy: 3);
		color: Color transparent;
		borderColor: (comment topBarColor).
	self addMorphFront: feedbackMorph.
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'jens 7/27/2010 00:45'!
step
	"Give feedback about possible drop targets."

	| feedbackColor h b targetArg targetAssoc targetP targetBlock |

	feedbackMorph
		ifNil: [feedbackMorph _ BorderedMorph new borderWidth: 3]  "create feedback morph if necessary"
		ifNotNil: [feedbackMorph delete].  "remove old feedback"
	feedbackColor _ Color white.
	feedbackMorph useSquareCorners.

	lambdaMorph
		ifNotNil: [lambdaMorph delete. lambdaMorph _ nil].  "remove old lambda feedback"

	h _ World activeHand.
	h toolType = 'CutTool' ifTrue: [^ self showDeleteFeedback].

	(self bounds containsPoint: h position) ifFalse: [^ self].
	h submorphCount = 1 ifFalse: [^ self].
	b _ h firstSubmorph.
	(b isKindOf: ScratchCommentMorph) ifTrue: [^ self showCommentDropFeedback].
	(b isKindOf: BlockMorph) ifFalse: [^ self].

	b isReporter ifTrue: [ "reporter block"
		(targetArg _ self topArgMorphAt: b bounds exclude: nil) ifNil: [^ self].
		(targetArg acceptsTypeOf: b) ifFalse: [^ self].
		feedbackMorph
			bounds: (targetArg bounds expandBy: 5);
			color: (feedbackColor alpha: 0.4);
			borderColor: feedbackColor;
			useRoundedCorners.

		(targetArg isKindOf: OSlotMorph) ifTrue: [
			feedbackMorph
				bounds: (targetArg bounds expandBy: 8)].

		((targetArg isKindOf: SpecialArgMorph) 
		and: [(#(reporterslot booleanslot) includes: targetArg type)
		and: [targetArg owner notNil 
		and: [(#(function functionWithArgs) includes: targetArg owner selector) not]]]) ifTrue: [
			feedbackMorph
				color: (feedbackColor);
				bounds: (targetArg bounds insetBy: 3).
			lambdaMorph _ ImageMorph new form: ((b imageForm outlineWidth: 3 color: Color gray depth: 8) 
														withOutlineColor: Color lightGray lighter width: 1)].
	
		lambdaMorph ifNotNil: [
			lambdaMorph position: b position - 4.
			h addMorphBack: lambdaMorph].

		^ self addMorphFront: feedbackMorph].

	"non-reporter (i.e. command block or hat block)"
	targetAssoc _ b closestAttachTargetIn: self.
	targetAssoc ifNil: [
		(b bottomBlock isKindOf: CBlockMorph) ifFalse: [
			targetAssoc _ b bottomBlock closestAttachTargetIn: self.
			targetAssoc ifNotNil:[
				(targetAssoc value owner isKindOf: BlockMorph) ifTrue:[
					targetAssoc _ nil]]]].
	targetAssoc ifNil: [^ self].

	targetP _ targetAssoc key.
	targetBlock _ targetAssoc value.
	feedbackMorph borderColor: feedbackColor; color: feedbackColor.

	"subtract the attachment point x from the width so that the feedback in CBlock won't stick out"
	ScratchTranslator isRTL
		ifTrue: [feedbackMorph extent: (targetP x - targetBlock left)@5.
			self addMorphFront: (feedbackMorph position: targetP - (feedbackMorph width@0))]
		ifFalse: [feedbackMorph extent: (targetBlock right - targetP x)@5.
			self addMorphFront: (feedbackMorph position: targetP)].
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'md 2/20/2004 17:31'!
stepTime

	^ 50
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'jens 7/29/2010 22:32'!
topArgMorphAt: aRectangle exclude: aMorph
	"Give feedback about possible drop targets."

	| stack argM area targetArg |
	"find the top block or stack under the given point, excluding the given morph"

	area _ [:morph |
			| space |
			space _ morph bounds.
			({CSlotMorph. OSlotMorph} includes: morph class)
				ifTrue: [space _ morph bounds expandBy: 5].
			((morph isKindOf: SpecialArgMorph) and: [
				#(reporterslot booleanslot) includes: morph type])
					ifTrue: [space _ morph bounds insetBy: 8 ].
			space].

	stack _ submorphs
		detect: [:m | (m ~~ aMorph) and: [(m isKindOf: BlockMorph) and: [m fullBounds intersects: aRectangle]]]
		ifNone: [^ nil].


	targetArg _ (stack allMorphs) detect: [:m | (m isKindOf: ArgMorph) 
									and: [(m bounds containsPoint: World activeHand position)
									and: [m acceptsDroppedReporters]]] 
										ifNone: [nil].

	targetArg ifNotNil: [^ targetArg].

	stack allMorphsDo: [:b |
		((b isKindOf: CommandBlockMorph) and:
		 [(b isKindOf: HatBlockMorph) not]) ifTrue: [
			1 to: b argumentCount do: [:i |
				argM _ b argumentAt: i.
	
				(argM isKindOf: MultiArgMorph) ifTrue: [
					argM elements do: [:elmt |
						((area value: elmt) intersects: aRectangle) ifTrue: [
							^elmt]]].

				(((area value: argM) intersects: aRectangle) and:
				 [argM acceptsDroppedReporters])
					ifTrue: [^ argM]]].
		(b isKindOf: WhenHatBlockMorph) ifTrue: [
			argM _ b argMorph.
			((argM bounds intersects: aRectangle) and:
			 [argM acceptsDroppedReporters])
				ifTrue: [^ argM]]].
	^ nil
! !

!ScratchScriptsMorph methodsFor: 'stepping' stamp: 'md 3/1/2004 16:45'!
topBlockMorphAt: aPoint exclude: aMorph
	"Give feedback about possible drop targets."

	| stack answer blocksUnderHand |
	stack _ submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [m fullBounds containsPoint: aPoint]]
		ifNone: [^ nil].

	blocksUnderHand _ OrderedCollection new.
	stack allMorphsDo: [:s | ((s isKindOf: BlockMorph) and: [s bounds containsPoint: aPoint]) 
		ifTrue: 	[blocksUnderHand addLast: s]
	].
	
	(blocksUnderHand isEmpty) ifTrue: [^ nil]
	ifFalse: [answer _ blocksUnderHand first. ^ answer]	

! !


!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'jens 4/12/2010 16:17'!
cleanUp
	"Align all scripts vertically in alphabetical order"

	| sortedBlocks y collectedBlocks bTop bBottom cm bHeight |
	collectedBlocks _ OrderedCollection new.
	submorphs do: [:m | 
		((m isKindOf: BlockMorph) 
		or: [(m isKindOf: ScratchCommentMorph) and: [m anchor isNil]]) 
			ifTrue:[collectedBlocks add: m]].

	sortedBlocks _ collectedBlocks copy sortBy: [:s1 :s2 | s1 top < s2 top].

	y _ 20.
	(owner isKindOf: ScrollFrameMorph2) ifTrue: [
		owner hScrollPixels: 0.
		owner vScrollPixels: 0].
	sortedBlocks do: [:s |
		ScratchTranslator isRTL
			ifTrue: [(owner isKindOf: ScrollFrameMorph2)
				ifTrue: [s position: (owner left + owner visibleExtent x - s width - 29)@(self top + y)]
				ifFalse: [s position: (self right - s width - 20)@(self top + y)]]
			ifFalse: [s position: self position + (20@y)].

		bTop _ s top.
		bBottom _ s fullBounds bottom.
		cm _ s commentMorph.
		cm notNil ifTrue: [
			cm step.
			bBottom _ bBottom max: cm bottom].
		bHeight _ bBottom - bTop.

		y _ y + bHeight + 15].

	self layoutChanged.
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'md 2/18/2004 14:58'!
handlesMouseDown: evt
	
	^ true! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'jens 1/27/2010 14:31'!
mouseDown: evt

	| m |
	evt hand newKeyboardFocus: nil.

	evt redButtonPressed ifTrue: [ 
		evt hand toolType: nil.
		^owner mouseDown: evt].

	evt hand toolType ifNotNil: [
		"revert to normal cursor"
		evt hand toolType: nil.
		^ self].

	evt rightButtonPressed ifTrue: [
		Sensor waitNoButton.
		(m _ self ownerThatIsA: ScratchScriptEditorMorph) ifNil: [^ self rightButtonMenu].
		(m target notNil and: [m currentCategory = 'Scripts'])
			ifTrue: [m scriptsMenu: evt hand position].
		^ self].

	evt hand waitForClicksOrDrag: self event: evt.! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'ee 2/3/2009 13:29'!
mouseEnterDragging: evt
	"Switch the tabs to script if a block is current being dragged"

	| scriptEditorMorph |
	scriptEditorMorph _ self ownerThatIsA: ScratchScriptEditorMorph.
	(scriptEditorMorph currentCategory = 'Scripts') ifFalse:[
		scriptEditorMorph currentCategory: 'Scripts'].
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'jm 12/30/2008 18:34'!
mouseHold: evt

	| m |
	(m _ self ownerThatIsA: ScratchScriptEditorMorph) ifNil: [^ self].
	(m target notNil and: [m currentCategory = 'Scripts'])
		ifTrue: [m scriptsMenu: evt hand position].
! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'jens 8/4/2008 09:21'!
mouseMove: evt 
	owner mouseMove: evt! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'JM 3/8/2012 11:22'!
mouseUp: evt
	evt hand toolType ifNil: [owner ifNotNil: [owner mouseUp: evt]]! !

!ScratchScriptsMorph methodsFor: 'event handling' stamp: 'jens 6/28/2010 02:01'!
rightButtonMenu

	| menu be |
	menu _ CustomMenu new.
	menu add: 'clean up' action: #cleanUp.
	menu add: 'save picture of scripts' action: #saveScriptsToImage.
	be _ self ownerThatIsA: BlockEditorFrameMorph.
	be ifNotNil: [ be definition varNames size > 0 ifTrue: [
		menu add: 'turn block variables into script variables' action: #migrateBlockVars]].
	menu add: 'undo last drop' action: #undoLastDrop.
	menu addLine.
	menu add: 'make a block' action: #makeNewBlock.

	menu localize; invokeOn: self.
! !


!ScratchScriptsMorph methodsFor: 'drawing' stamp: 'jens 3/9/2009 13:25'!
drawOn: aCanvas
	"Fill with my texture patch. Fill with a solid color if there is no texture in the current skin dictionary."

	| patchF clipC y x |

	self isScreenshooting ifTrue: [
		aCanvas fillRectangle: self bounds color: Color transparent.
		^ self].

	patchF _ ScratchFrameMorph skinAt: #scriptsPaneTexture ifAbsent: [
		aCanvas fillRectangle: self bounds color: color.
		^ self].

	clipC _ aCanvas copyClipRect: self bounds.
	y _ self top.
	[y <= self bottom] whileTrue: [
		x _ self left.
		[x <= self right] whileTrue: [
			clipC paintImage: patchF at: x@y.
			x _ x + patchF width].
		y _ y + patchF height].
! !

!ScratchScriptsMorph methodsFor: 'drawing' stamp: 'jens 6/27/2010 23:22'!
showDeleteFeedback
	"Display feedback for the scissors tool."

	| h cutBlock r |
	h _ World activeHand.
	(cutBlock _ self topBlockMorphAt: h cursorPoint exclude: nil) ifNil: [^ self].
	((cutBlock isKindOf: CSlotMorph) or: [cutBlock isKindOf: OSlotMorph])
		ifTrue: [cutBlock _ cutBlock owner].
	r _ cutBlock bounds.
	((cutBlock isKindOf: CBlockMorph) and: [cutBlock firstBlockList size > 0])
		ifTrue: [r _ r merge: cutBlock firstBlockList first fullBounds].
	(cutBlock isKindOf: HatBlockMorph)
		ifTrue: [r _ cutBlock fullBounds].
	feedbackMorph
		bounds: (r expandBy: 3);
		color: Color transparent;
		borderColor: (Color r: 212/255 g: 40/255 b: 40/255).
	self addMorphFront: feedbackMorph.
! !


!ScratchScriptsMorph methodsFor: 'object i/o' stamp: 'jm 9/30/2003 21:29'!
fieldsVersion
	"I depend on my superclass for object i/o. Currently, thos methods are inherited from Morph."

	^ 1
! !


!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'jens 3/9/2009 13:02'!
isScreenshooting

	^ screenshooting ifNil: [screenshooting _ false]
! !

!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'jens 1/27/2010 14:32'!
saveScriptsToImage
	"Take a snapshot of all scripts for a sprite and save as a GIF file"

	| fName saveForm |

	saveForm _ self screenshot.

	fName _ ScratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Scripts Snapshot'
		type: #scriptsSnapshot.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	(fName asLowercase endsWith: '.gif') ifFalse: [fName _ fName, '.gif'].
	saveForm writeGIFFileNamed: fName.
! !

!ScratchScriptsMorph methodsFor: 'screenshot' stamp: 'jens 3/9/2009 13:44'!
screenshot
	"answer a Form of myself apt for exporting"

	| saveForm leftX topY rightX bottomY |

	screenshooting _ true.
	self changed.
	saveForm _ self imageForm.

	"clip"

	leftX _ submorphs anyOne left.
	topY _ submorphs anyOne top.
	rightX _ submorphs anyOne right.
	bottomY _ submorphs anyOne bottom.
	(self allMorphs select: [:m | m ~= self]) do: [:m |
		leftX _ leftX min: m left.
		topY _ topY min: m top.
		rightX _ rightX max: m right.
		bottomY _ bottomY max: m bottom].
	saveForm _ saveForm copy: (((leftX @ topY) - self position) rect: ((rightX @ bottomY) - self position)).

	screenshooting _ false.
	self changed.
	^ saveForm
! !


!ScratchScriptsMorph methodsFor: 'undo' stamp: 'jens 4/21/2009 11:03'!
recordDroppedBlock: aBlockMorph bottom: stackBottom kickedOut: aReporter

	droppedBlock _ aBlockMorph.
	droppedBottom _ stackBottom.
	kickedOutReporter _ aReporter. 
	nestedStack _ nil! !

!ScratchScriptsMorph methodsFor: 'undo' stamp: 'jens 4/21/2009 10:25'!
recordNestedStack: aBlockMorph
	nestedStack _ aBlockMorph! !

!ScratchScriptsMorph methodsFor: 'undo' stamp: 'jens 8/17/2009 00:35'!
undoLastDrop

	| arg next |
	droppedBlock ifNil: [^self ].
	(droppedBlock isKindOf: ReporterBlockMorph) ifTrue: [
		kickedOutReporter notNil 
			ifTrue: [ droppedBlock owner replaceArgMorph: droppedBlock by: kickedOutReporter]
			ifFalse: [(droppedBlock owner isKindOf: BlockMorph)
				ifTrue: [
					arg _ droppedBlock owner argMorphToReplace: droppedBlock.
					arg ifNotNil: [droppedBlock owner replaceArgMorph: droppedBlock by: arg]]].
		^self activeHand attachMorph: droppedBlock ].

	next _ droppedBottom nextBlock.
	nestedStack ifNotNil: [next _ nestedStack ].
	next ifNotNil: [droppedBlock owner addMorph: next ].
	(droppedBlock owner isKindOf: BlockMorph) ifTrue: [
		next ifNotNil: 
			[ droppedBlock owner attachBlock: next]].

	self activeHand attachMorph: droppedBlock! !


!ScratchScriptsMorph methodsFor: 'byob' stamp: 'jens 6/24/2010 00:52'!
makeNewBlock

	| be sf |
	be _ self ownerThatIsA: BlockEditorFrameMorph.
	be ifNil: [^self].
	sf _ be scratchFrame.
	sf ifNil: [^self].
	sf scriptsPane target addCustomBlock
! !

!ScratchScriptsMorph methodsFor: 'byob' stamp: 'jens 9/15/2010 00:39'!
migrateBlockVars

	| be |
	be _ self ownerThatIsA: BlockEditorFrameMorph.
	be ifNil: [^self ].
 	be definition migrateBlockVars.
	be buildScript! !
