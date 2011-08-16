Morph subclass: #LibraryItemMorph
	instanceVariableNames: 'target thumbnailMorph nameMorph scriptCountMorph cloneCountMorph isSelected rolloverOn lastUpdateMSecs highlightForm currentForm thumbWidth clonesWidth rolloverForm rotationToggleMorph '
	classVariableNames: 'InfoFont NameFont '
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!LibraryItemMorph commentStamp: 'jm 2/25/2005 14:10' prior: 0!
I represent a scriptable morph in the library pane. I display a thumbnail of the morph, its name, and some information about it.
!


!LibraryItemMorph methodsFor: 'initialization' stamp: 'jens 7/28/2009 23:03'!
buildRotationToggleMorph

	| x y onForm offForm |
	onForm _ ((ScratchFrameMorph skinAt: #rotStyleSmooth) magnifyBy: 0.9).
	offForm _ ((ScratchFrameMorph skinAt: #rotStyleNone) magnifyBy: 0.9).
	rotationToggleMorph _ ToggleButton
							onForm: onForm
							offForm: offForm.
	x _ onForm width.
	y _ onForm height.
	rotationToggleMorph
		position: (self right - x) @ (self top + y);
		target: self;
		actionSelector: #toggleRotationRule.
	self addMorph: rotationToggleMorph.
! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'JM 8/16/2011 14:00'!
buildSubmorphs
	"LibraryItemMorph open"

	thumbnailMorph _ ImageMorph new
		form: (Form extent: thumbWidth@thumbWidth depth: 16) fillWhite;
		position: (((self width - thumbWidth) - clonesWidth) // 2) @ 0.
	self addMorph: thumbnailMorph.

	nameMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemName);
		position: 0 @ (thumbnailMorph bottom -2).
	self addMorph: nameMorph.

	"scriptCountMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemInfo);
		contents: '';
		position: 0 @ nameMorph bottom.
	self addMorph: scriptCountMorph."

	cloneCountMorph _ StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemName);
		contents: 'clones';
		position: ((((self width - thumbWidth) - clonesWidth) // 2) + thumbWidth) @ 0.
	self addMorph: cloneCountMorph.

	self color: Color transparent.

	self buildRotationToggleMorph
! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'JM 8/16/2011 12:39'!
extent: aRectangle thumbWidth: w clonesWidth: c

	lastUpdateMSecs _ -1.
	self extent: aRectangle.
	thumbWidth _ w.
	clonesWidth _ c.

	self buildSubmorphs.
	self target: nil.
	isSelected _ nil.
	rolloverOn _ false.
	highlightForm _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #librarySelected).
	highlightForm extent: self extent.
	rolloverForm _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #libraryRollover).
	rolloverForm extent: self extent.
	currentForm _ nil.
	self highlight: false.
! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'jens 1/14/2011 00:47'!
updateNameAndInfo

	| w y txt |

	txt _ ((target objName asUTF8, ' (' asUTF8, 'Scripts' localized, ScratchTranslator colonSuffix, ' ' asUTF8, target scripts size printString asUTF8,')' asUTF8) asUTF8).

	target prototype ifNotNil: [
		txt _ (txt, ' kind of: ' asUTF8, target prototype objName asUTF8) asUTF8].

	self
		setProperty: #balloonText
		toValue: txt.

	nameMorph ifNotNil:[
		(target isKindOf: ScriptableScratchMorph) ifFalse: [
			nameMorph contents: '<no object>'.
			scriptCountMorph contents: ''.
			^ self].

		nameMorph contents = target objName ifFalse: [
			nameMorph contents: self truncatedLabel.
			nameMorph left: self left + ((self width - nameMorph width) // 2) + 1]].

	scriptCountMorph ifNotNil: [
		w _ 0.
		target scripts size > 0
			ifTrue: [
				w > 0 ifTrue: [w _ w + 2].
				scriptCountMorph contents: 'Scripts' localized, ScratchTranslator colonSuffix, ' ', target scripts size printString.
				w _ w + scriptCountMorph width + 2]
			ifFalse: [
				scriptCountMorph contents: ''].

		"layout info morph row"
		y _ nameMorph bottom.
		w > 0 ifTrue: [
			scriptCountMorph position: (self left + ((self width - (scriptCountMorph width)) // 2))@y]].
! !

!LibraryItemMorph methodsFor: 'initialization' stamp: 'jens 7/28/2009 22:29'!
updateRotationToggleMorph

	rotationToggleMorph ifNil: [
		self buildRotationToggleMorph ].
	(self target isNil
		or: [(self target isKindOf: ScratchStageMorph)
		or: [self target ownerSprite isNil]])
		ifTrue: [
			rotationToggleMorph isHidden: true.
			^self ]
		ifFalse: [rotationToggleMorph isHidden: false].
	rotationToggleMorph
		position: (self right - rotationToggleMorph width - 2) @ (self top + 2).
	self target rotateWithOwner
		ifTrue: [rotationToggleMorph on]
		ifFalse: [rotationToggleMorph off]
! !


!LibraryItemMorph methodsFor: 'accessing' stamp: 'jm 7/11/2008 06:45'!
color

	currentForm
		ifNil: [^ color]
		ifNotNil: [^ currentForm color].
! !

!LibraryItemMorph methodsFor: 'accessing' stamp: 'ee 3/20/2009 14:05'!
highlight: aBoolean

	| labelColor |
	isSelected = aBoolean ifTrue: [^ self].

	isSelected _ aBoolean.
	isSelected
		ifTrue: [
			rolloverOn _ false.
			highlightForm extent: self extent.
			currentForm _ highlightForm.
			self addMorphBack: (currentForm position: (self position + (0@0))).
			labelColor _ Color white]
		ifFalse: [
			currentForm ifNotNil: [
				currentForm delete.
				currentForm _ nil].
			labelColor _ Color gray: 0.8].

	nameMorph color: labelColor.
	"scriptCountMorph color: labelColor darker."
	self changed.
! !

!LibraryItemMorph methodsFor: 'accessing' stamp: 'jm 6/18/2004 09:15'!
target

	^ target
! !

!LibraryItemMorph methodsFor: 'accessing' stamp: 'jm 6/30/2004 13:47'!
target: aMorph

	target _ aMorph.
	self updateThumbnail.
! !


!LibraryItemMorph methodsFor: 'drawing' stamp: 'jm 7/10/2004 15:33'!
areasRemainingToFill: aRectangle
	"Drawing optimization. Since I clip drawing of my submorphs, this method tells Morphic that it isn't necessary to draw any morphs covered by me. This is a little lie because I have rounded corners."
	
	^ aRectangle areasOutside: self bounds
! !

!LibraryItemMorph methodsFor: 'drawing' stamp: 'nb 2/11/2008 22:04'!
drawOn: aCanvas
	"Draw my selected or rollover state if necessary."

	currentForm ifNotNil: [currentForm drawOn: aCanvas].
! !

!LibraryItemMorph methodsFor: 'drawing' stamp: 'jm 3/9/2005 10:43'!
drawSubmorphsOn: aCanvas
	"Clip submorph drawing to my bounds."

	| r |
	r _ self bounds.
	rolloverOn | isSelected ifTrue: [r _ r insetBy: 3].
	super drawSubmorphsOn: (aCanvas copyClipRect: r).

! !


!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 6/18/2004 09:24'!
handlesMouseDown: evt

	^ true
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'ee 5/14/2008 13:02'!
handlesMouseOverDragging: evt

	| m |
	evt hand submorphs size = 1 ifFalse: [^ false].
	m _ evt hand firstSubmorph.
	^ ((m isKindOf: BlockMorph) or: [(m isKindOf: MediaItemMorph) or: [m isKindOf: ScratchCommentMorph]])
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jens 3/8/2011 23:30'!
mouseDown: evt
	"Handle a mouse click. Left click either sets me as a target, deletes me, or copies me.  Shift left click makes me reappear in the middle of the screen.  Holding left button drags me. Right button brings up a menu."

	| duplicate frame |

	(evt hand toolType = 'CutTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isKindOf: ScratchStageMorph) not]) ifTrue: [
			self target undoableDeleteSprite].
		^ self].
	
	(evt hand toolType = 'CopyTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isKindOf: ScratchStageMorph) not]) ifTrue: [
			duplicate _ self target duplicate.
			self world activeHand
				attachMorph: duplicate;
				formerOwner: self target owner position: self target owner center].
		^ self].

	target ifNotNil: [
		evt shiftPressed ifTrue: [self select. ^ self target makeVisible].
		evt rightButtonPressed
			ifTrue: [
				Sensor waitNoButton. 
				(target isKindOf: ScratchStageMorph) 
					ifTrue: [^ self stageMenu]
					ifFalse: [^ self rightButtonMenu]]
			ifFalse:	[
				target closeBlockEditor.
				self select.
				frame _ self ownerThatIsA: ScratchFrameMorph.
				"Set the viewerPane target to my target so I stay highlighted while I am being dragged. This is sort of a hack because my target is not actually being viewed until the mouseUp: command is called."
				frame viewerPane target: self target.
				evt hand waitForClicksOrDrag: self event: evt]].
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'ee 2/21/2009 14:38'!
mouseEnterDragging: evt

	"| m s |

	m _ BorderedMorph new
		color: Color gray lighter lighter;
		borderWidth: 1;
		borderColor: Color gray;
		useRoundedCorners.
	s _ StringMorph
		contents: ('Copy to ', target objName)
		font: (ScratchFrameMorph getFont: #Button).
	s color: Color white.
	m
		addMorph: (s position: (5@2));
		width: s width + 10;
		height: s height + 5.
	(evt hand submorphs at: 1) addCopyTooltip: (m)."

	isSelected ifTrue: [^ self].

	rolloverOn _ true.
	currentForm _ rolloverForm.
	self addMorphBack: (currentForm position: (self position + (0@0))).
	self changed.
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 6/3/2009 20:01'!
mouseHold: evt

	(target isKindOf: ScratchStageMorph) ifFalse: [self rightButtonMenu].
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 5/19/2009 12:47'!
mouseLeaveDragging: evt

	"(evt hand submorphs at: 1) removeCopyTooltip."

	isSelected ifTrue: [^ self].

	rolloverOn _ false.
	currentForm ifNotNil: [
		currentForm delete.
		currentForm _ nil].
	self changed.
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 7/4/2008 19:52'!
mouseUp: evt
	"View my target if it is not already beeing viewed."

	| frame |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	self target ifNil: [^ self]. "deleted"

	self select.
	frame scriptsPane target = self target ifFalse: [
		self target viewBlocksAndScripts].
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 7/4/2008 19:53'!
select

	(self ownerThatIsA: ScratchLibraryMorph) unhighlightAll. "unhighlight others"
	self highlight: true.
	World displayWorldSafely. "force immediate feedback"
! !

!LibraryItemMorph methodsFor: 'event handling' stamp: 'jm 4/23/2008 17:20'!
startDrag: evt

	(self target isKindOf: ScratchStageMorph) ifTrue: [^ self]. "cannot drag stage thumbnail"

	(self ownerThatIsA: ScratchLibraryMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy].
! !


!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'ee 5/14/2008 13:00'!
acceptDroppingMorph: aMorph event: evt
	"Copy the dropped scripts of another object into its target."

	(aMorph isKindOf: MediaItemMorph) ifTrue: [
		target addMediaItem: aMorph media copy.
		evt hand rejectDropMorph: aMorph event: evt].

	(aMorph isKindOf: BlockMorph) ifTrue: [
		evt hand rejectDropMorph: aMorph event: evt.
		target addStack: aMorph fullCopy].

	(aMorph isKindOf: ScratchCommentMorph) ifTrue: [
		evt hand rejectDropMorph: aMorph event: evt.
		target addComment: aMorph fullCopy].
! !

!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'jens 7/28/2009 22:37'!
justDroppedInto: aMorph event: evt
	"When I am dropped into the viewer pane or the script editor, then delete the sprite associated with me."
	
	| targets |

	((self target isKindOf: ScratchSpriteMorph) and: [
	(aMorph isKindOf: ScratchStageMorph)]) ifTrue: [
		targets _ aMorph sprites select: [:each| 
			each containsPoint: aMorph adjustedCursorPoint ].
		targets size > 0
			ifTrue: [self target stickTo: targets first]
			ifFalse: [self target unhinge]].

	self delete.
true ifTrue: [^ self].

	"delete me when dropped on the blocks palette or the script editor"
	(((aMorph ownerThatIsA: ScratchViewerMorph) notNil) 
		or: [(aMorph ownerThatIsA: ScratchScriptEditorMorph) notNil]) ifTrue: [
		^ self target undoableDeleteSprite].

	"blocks cannot be dropped onto the stage"
	(owner isKindOf: ScratchStageMorph) ifTrue: [
		^ self rejectDropEvent: evt].
! !

!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'tis 11/10/2006 18:20'!
rejectDropEvent: evt
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.
! !

!LibraryItemMorph methodsFor: 'dropping/grabbing' stamp: 'ee 2/19/2009 11:52'!
wantsDroppedMorph: aMorph event: evt
	"Answer true if the given morph is a script, costume, sound or comment."

	^ (aMorph isKindOf: BlockMorph) or: [
		(aMorph isKindOf: MediaItemMorph) or: [
			aMorph isKindOf: ScratchCommentMorph]]
! !


!LibraryItemMorph methodsFor: 'stepping' stamp: 'jens 2/22/2011 23:12'!
step
	"Optimization: Don't update unless the costume has changed."

	| changeTime stage frame |
	target ifNil: [
		(frame _ (self ownerThatIsA: ScratchFrameMorph)) ifNotNil: [
			(stage _ frame workPane) ifNotNil: [
				stage updateSpritesList]].
		^ self].
	target world isNil ifTrue: [target _ nil. ^ self].
	changeTime _ target costumeChangeMSecs.
	changeTime = lastUpdateMSecs ifFalse: [
		self updateThumbnail.
		lastUpdateMSecs _ changeTime].
	Sensor anyButtonPressed ifFalse: [self updateNameAndInfo].
! !

!LibraryItemMorph methodsFor: 'stepping' stamp: 'jens 2/22/2011 23:12'!
updateThumbnail

	| f e r form smallSize anchor subs |

	self updateRotationToggleMorph.

	form _ thumbnailMorph form.
	form fillColor: Color transparent.
	target ifNil: [
		thumbnailMorph changed.
		^ self].

	self updateRotationToggleMorph.

	smallSize _ (form height // 3) @ (form height // 3).

	((target isKindOf: ScratchSpriteMorph) and: [target hasSubsprites]) ifTrue: [
		1 to: (target subsprites size min: 3) do: [:idx|
			subs _ ((target subsprites at: idx) imageForm asFormOfDepth: 16) toThumbnail: smallSize borderWidth: 0 borderColor: Color transparent.
			subs displayOn: form at: (form width - (subs width*idx)) @ (form height - subs height) ]].


	anchor _ ((target isKindOf: ScratchSpriteMorph) and: [target ownerSprite notNil]).

	f _ target imageForm asFormOfDepth: 16.
	((f width <= form width) & (f height <= form height)) ifTrue: [
		"target's image fits without shrinking"
		f displayOn: form at: ((form extent - f extent) // 2).
		thumbnailMorph changed.
		^ self].


	f width > f height 
		ifTrue: [e _ form width @ ((f height * form width) // f width)]
		ifFalse: [e _ ((f width * form height) // f height) @ form height].
	e _ e max: (8@8).
	r _ Rectangle center: (form extent // 2) extent: e.

	(WarpBlt toForm: form)
		sourceForm: f;
		cellSize: 2;  "do smoothing; this also installs a colormap"
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).

	anchor ifTrue: [
		(WarpBlt toForm: form)
			sourceForm: (target ownerSprite imageForm asFormOfDepth: 16);
			cellSize: 2;  "do smoothing; this also installs a colormap"
			combinationRule: Form paint;
			copyQuad: f boundingBox innerCorners toRect: (0@0 extent: smallSize).

		"anchor displayOn: form at: 0@0"].

	thumbnailMorph changed.
! !


!LibraryItemMorph methodsFor: 'right button menu' stamp: 'jens 3/9/2011 00:54'!
rightButtonMenu
	"Present the right button menu."

	| menu stage |
	menu _ CustomMenu new.
	menu add: 'show' action: #makeVisible.
	menu add: 'export this sprite' action: #exportObject.

	stage _ self target ownerThatIsA: ScratchStageMorph.
	stage ifNotNil: [
		(stage scratchServer notNil and: 
		[stage scratchServer sessionInProgress])
			ifTrue: [
				menu add: 'share this sprite' action: #shareObject ]].

	menu addLine.
	menu add: 'duplicate' action: #duplicateNoAttach.
	menu add: 'delete' action: #undoableDeleteSprite.
	(self target isKindOf: ScratchSpriteMorph) ifTrue: [
		menu addLine.
		menu add: 'clone' action: #spawn.
		menu add: 'parent...' action: #choosePrototype.
		self target instances size > 0 ifTrue: [
			menu add: 'children...' action: [self childrenMenu]].
		self target isNested ifTrue: [
			menu addLine ].
		self target hasSubsprites ifTrue: [
			menu add: 'detach all subsprites' action: #unhingeAll ].
		self target ownerSprite ifNotNil: [
			menu add: 'detach from ', self target ownerSprite objName action: #unhinge  ]].
	menu localize; invokeOn: self target.
! !



!LibraryItemMorph methodsFor: 'private' stamp: 'jens 9/16/2010 23:21'!
toggleRotationRule

	(self target isKindOf: ScratchStageMorph)
		ifTrue: [^ self].
	self target toggleRotationRule.
	self updateRotationToggleMorph! !

!LibraryItemMorph methodsFor: 'private' stamp: 'ee 3/28/2009 19:12'!
truncatedLabel
	"Answer the label string to used as the name morph."

	| ellipses s w n |

	nameMorph contents = target objName ifFalse: [
		n _ target objName.
		ellipses _ ScratchTranslator ellipsesSuffix asUTF32.
		1 to: n size do: [:i |
			s _ n copyFrom: 1 to: i.
			w _ nameMorph stringWidth: (s asUTF32, ellipses).
			w > (self width - 3) ifTrue: [
				^ (n copyFrom: 1 to: i - 1) asUTF32, ellipses]]].

	^ target objName
! !


!LibraryItemMorph methodsFor: 'BYOB' stamp: 'jens 3/9/2011 01:00'!
childrenMenu
	"Present the children menu on a sprite icon"

	| menu library frame |
	library _ self ownerThatIsA: ScratchLibraryMorph.
	library ifNil: [^ self].
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].

	menu _ CustomMenu new.
	menu beHorizontal.
	library spriteThumbnails do: [:tn |
		(tn target prototype == self target) ifTrue: [
			menu addIcon: tn imageForm 
			toolTip: tn target objName 
			action: tn target objName]].

	menu localize; invokeOn: library.
! !

!LibraryItemMorph methodsFor: 'BYOB' stamp: 'jens 3/9/2011 00:32'!
stageMenu
	"Present the right button menu on the stage icon"

	| menu library frame |
	library _ self ownerThatIsA: ScratchLibraryMorph.
	library ifNil: [^ self].
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].

	menu _ CustomMenu new.
	menu beHorizontal.
	library spriteThumbnails do: [:tn |
		tn target prototype ifNil: [
			menu addIcon: tn imageForm 
			toolTip: tn target objName 
			action: tn target objName]].

	menu localize; invokeOn: library.
! !
