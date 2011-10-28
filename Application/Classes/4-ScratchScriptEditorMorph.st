DividedImageFrameMorph subclass: #ScratchScriptEditorMorph
	instanceVariableNames: 'thumbnailMorph nameMorph pageViewerMorph rotationButtons lockButton readoutMorphs penReadout currentCategory tabPaneMorph deleteButton '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchScriptEditorMorph commentStamp: '<historical>' prior: 0!
I am a viewer for the scripts and media closet of a Scratch object. I have a heading row containing the object name (editable) and a drop-down menu icon. Below that is a scrollable content area.
!


!ScratchScriptEditorMorph methodsFor: 'initialization' stamp: 'jm 7/4/2008 12:31'!
addNameBox

	nameMorph _ UpdatingStringFieldMorph new
		font: (ScratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: ScratchTranslator isRTL;
		acceptWhenFocusLost: true;
		position: thumbnailMorph topRight + (17@(thumbnailMorph height * 0.12)).

	self addMorphBack: nameMorph.
! !

!ScratchScriptEditorMorph methodsFor: 'initialization' stamp: 'jens 11/19/2009 21:49'!
createTabPane

	| tabOnForm tabOffForm tabID tabLabel |

	"create tab pane"
	tabPaneMorph _ ScratchTabPaneMorph new.
	tabPaneMorph
		borderWidth: 0;
		color: Color transparent;
		targetPane: self.

	tabOnForm _ (ScratchFrameMorph skinAt: #tabOn).
	tabOffForm _ (ScratchFrameMorph skinAt: #tabOff).

	"add the tabs"
	#(Scripts Costumes Sounds) do: [:spec |
		tabID _ spec asString.
		tabLabel _ tabID localized.
		tabPaneMorph
			createTab: tabID
			withLabel: tabLabel
			onForm: tabOnForm
			offForm: tabOffForm].

	"set current tab and add to frame"
	tabPaneMorph currentTab: 'Scripts'.
	self addMorph: tabPaneMorph.
! !

!ScratchScriptEditorMorph methodsFor: 'initialization' stamp: 'ee 11/4/2008 12:24'!
initialize

	super initialize.
	self
		initFrontFromForm: (ScratchFrameMorph skinAt: #scriptPaneFrameTransparent2)
		topSectionHeight: 90.
	self color: (Color r: (149/255) g: (154/255) b: (159/255)).

	thumbnailMorph _ ScratchThumbnailMorph new.
	self addMorph: (thumbnailMorph position: self position + (37@16)).

	self addNameBox.

	pageViewerMorph _ ScrollFrameMorph2 new
		growthFraction: 0.1;
		color: ScratchFrameMorph scriptsPaneColor.
	self addMorph: (pageViewerMorph position: (self left @ (self top + topSectionHeight))).

	rotationButtons _ #().
	readoutMorphs _ #().
	self target: nil.
	thumbnailMorph extent: 50@50.
	self extent: 300@400.
	self createTabPane.
! !


!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'jm 4/9/2009 10:09'!
bareMinimumWidth
	"Answer the bare minimum width for this pane to be useable."

	lockButton ifNil: [^ 100].
	^ lockButton right - self left! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'jm 2/28/2005 17:07'!
categoryChanged: aString
	"If the given category is my current category, update my contents. Otherwise, do nothing."

	self target ifNil: [^ self].
	currentCategory = aString ifTrue: [self currentCategory: aString].
! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'jm 2/28/2005 14:29'!
currentCategory

	^ currentCategory

! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'jm 4/23/2008 12:43'!
currentCategory: aString

	| xOffset |
	currentCategory _ aString.
	self target ifNil: [^ self].
	xOffset _ 0.

	World activeHand newKeyboardFocus: nil.

	currentCategory = 'Scripts' ifTrue: [
		pageViewerMorph contents: self target blocksBin].
	currentCategory = 'Costumes' ifTrue: [
		pageViewerMorph contents: (self target costumesPage: xOffset)].
	currentCategory = 'Sounds' ifTrue: [
		pageViewerMorph contents: (self target soundsPage: xOffset)].

	pageViewerMorph contents color: ScratchFrameMorph scriptsPaneColor.

	self world ifNotNil: [self world startSteppingSubmorphsOf: pageViewerMorph contents].

! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'ee 8/11/2008 13:48'!
getTabTop
	"Used by ScratchFrameMorph when creating the tab pane. This returns the y position of where the top of the tabs should align. This situation is unfortunate (tabs should probaby be part of ScratchScriptEditorMorph), but we'll fix it later."

	ScratchFrameMorph isXO ifTrue: [^ thumbnailMorph bottom + 20].
	(readoutMorphs size > 0)
		ifTrue: [^ (readoutMorphs at: 1) bottom + 6]
		ifFalse: [^ nameMorph bottom + 5 + (ScratchTranslator stringExtent: '0' font: (ScratchFrameMorph getFont: #XYReadoutBold)) y + 6].
! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'ee 11/4/2008 11:44'!
tabPane

	^ tabPaneMorph! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'ee 7/1/2003 12:58'!
target

	^ nameMorph target
! !

!ScratchScriptEditorMorph methodsFor: 'accessing' stamp: 'JM 9/20/2011 11:14'!
target: aScratchObjectOrNil
	"Start viewing the given object or no object."

	| sFrame nameSel |
	World activeHand newKeyboardFocus: nil.
	(aScratchObjectOrNil isNil or:
	 [aScratchObjectOrNil isScriptable not]) ifTrue: [
		thumbnailMorph target: nil.
		nameMorph target: nil; contents: 'no object '.
		pageViewerMorph contents: (Morph new color: Color red).

		(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [
			sFrame viewerPane target: nil].

		self showOrHideReadouts.
		^ self].

	thumbnailMorph target: aScratchObjectOrNil.

	nameSel _ (aScratchObjectOrNil isKindOf: ScratchStageMorph)
		ifTrue: [nil]
		ifFalse: [#className:].
	nameMorph
		target: aScratchObjectOrNil;
		getSelector: #className;
		putSelector: nameSel.

	self showOrHideReadouts.
	self fixLayout.
! !


!ScratchScriptEditorMorph methodsFor: 'drawing' stamp: 'ee 1/29/2009 10:12'!
drawBackgroundOn: aCanvas
	"Draw my background."

	color isTransparent ifTrue: [^ self].

	aCanvas
		fillRectangle: (self topLeft corner: pageViewerMorph topRight)
		color: color.
! !

!ScratchScriptEditorMorph methodsFor: 'drawing' stamp: 'ee 1/29/2009 10:35'!
drawSubmorphsOn: aCanvas
	"Display submorphs back to front."

	submorphs reverseDo: [:m |
		(m = tabPaneMorph) ifFalse: [aCanvas fullDrawMorph: m]].
! !

!ScratchScriptEditorMorph methodsFor: 'drawing' stamp: 'ee 1/29/2009 10:35'!
fullDrawOn: aCanvas
	"Draw my frame in front of my submorphs."

	| clipC |
	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(aCanvas isVisible: self fullBounds) ifFalse: [^ self].

	"myBox has integer position and extent and has a potentially inset bottom"
	myBox _ bounds truncated.
	clipC _ aCanvas copyClipRect: myBox.

	frameInFront
		ifTrue: [
			self drawOn: clipC.
			self drawSubmorphsOn: clipC.
			self drawFrameOn: clipC.
			aCanvas fullDrawMorph: tabPaneMorph]
		ifFalse: [
			self drawOn: clipC.
			self drawSubmorphsOn: clipC].
! !


!ScratchScriptEditorMorph methodsFor: 'event handling' stamp: 'ee 2/3/2009 13:28'!
handlesMouseOverDragging: evt

	| m |
	evt hand submorphs size = 1 ifFalse: [^ false].
	m _ evt hand firstSubmorph.

	^ m isKindOf: BlockMorph.
! !

!ScratchScriptEditorMorph methodsFor: 'event handling' stamp: 'ee 2/8/2009 17:02'!
mouseEnterDragging: evt
	"Switch the tabs to script if a block is current being dragged"

	(currentCategory = 'Scripts') ifFalse:[
		self currentCategory: 'Scripts'.
		tabPaneMorph currentTab: 'Scripts'].
! !


!ScratchScriptEditorMorph methodsFor: 'geometry' stamp: 'jm 10/28/2008 13:13'!
extent: aPoint

	super extent: aPoint.
	pageViewerMorph ifNotNil: [
		pageViewerMorph extent: self extent - (pageViewerMorph position - self position)].
! !

!ScratchScriptEditorMorph methodsFor: 'geometry' stamp: 'ee 2/5/2009 16:25'!
fixLayout

	| y x |
	"layout readout morphs vertically"
	y _ nameMorph bottom + 5.
	readoutMorphs do: [:m |
		m position: m left@y].

	"layout readout and name morphs horizontally"
	nameMorph position: (thumbnailMorph topRight + (17@(thumbnailMorph height * 0.12))).
	x _ nameMorph left.
	readoutMorphs do: [:m |
		m position: x@m top.
		x _ m right + 5].

	"layout lock and pen morphs"
	lockButton ifNotNil: [
		lockButton position: (nameMorph right + 4)@(nameMorph top + ((nameMorph height - lockButton height) / 2)).
		penReadout position: (lockButton right + 4)@(nameMorph top + ((nameMorph height - penReadout height) / 2))].

	"place tab morph"
	(readoutMorphs size > 1) ifTrue: [
		topSectionHeight _ (readoutMorphs at: 1) bottom - self top + tabPaneMorph height + 5].
	tabPaneMorph
		width: self width;
		position: (self left + 15) @ (self top + topSectionHeight - tabPaneMorph height + 1).

	"place scripts scroll pane"
	pageViewerMorph position: (self left @ (self top + topSectionHeight)).
	self extent: self extent. "force resize of page viewer morph"
! !


!ScratchScriptEditorMorph methodsFor: 'stepping' stamp: 'ee 4/14/2008 15:01'!
step

	currentCategory = 'Costumes' ifTrue: [self updateCostumeSelection].

	(penReadout isNil or: [penReadout owner ~= self]) ifTrue: [^ self].
	self target penDown
		ifTrue: [penReadout color: self target penColor]
		ifFalse: [penReadout color: Color transparent].
! !

!ScratchScriptEditorMorph methodsFor: 'stepping' stamp: 'jm 1/5/2006 11:11'!
stepTime

	^ 50
! !

!ScratchScriptEditorMorph methodsFor: 'stepping' stamp: 'ee 4/14/2008 15:01'!
updateCostumeSelection
	"Update the currently selected costume if the costumes tab is selected."

	| currentCostume |
	currentCategory = 'Costumes' ifFalse: [^ self].
	currentCostume _ self target costume.

	pageViewerMorph contents submorphsDo: [:m |
		((m isKindOf: MediaItemMorph) and:
		 [m media isImage]) ifTrue: [
			m highlight: (m media = currentCostume)]].
! !


!ScratchScriptEditorMorph methodsFor: 'byob' stamp: 'jens 1/8/2010 00:54'!
addCustomBlock

	self target addCustomBlock! !


!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'ee 5/14/2008 16:40'!
addComment: aPosition

	| c scriptsMorph |
	scriptsMorph _ (pageViewerMorph allMorphs select: [: m | m isKindOf: ScratchScriptsMorph]) first.
	scriptsMorph addMorph: (c _ ScratchCommentMorph new position: aPosition).
	World activeHand newKeyboardFocus: c commentMorph.
! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'jm 4/27/2007 16:12'!
animateRotationStyle

	| style thumbForm wasFlipped currentRotation pen center rotatedForm doFlip |
	style _ self target rotationStyle.

	thumbnailMorph updateThumbnail.
	thumbForm _ thumbnailMorph form deepCopy.
	currentRotation _ self target rotationDegrees rounded.
	wasFlipped _ ((currentRotation \\ 360) >= 90) & ((currentRotation \\ 360) <= 270).

	thumbnailMorph showDirection: false.

	pen _ (Pen newOnForm: thumbnailMorph form) color: Color white.
	center _ thumbnailMorph form center.
	currentRotation to: currentRotation + 360 by: 12 do: [:i |
		rotatedForm _ thumbForm.  "no rotation by default"
		style = #normal ifTrue: [rotatedForm _ thumbForm rotateBy: i].
		style = #leftRight ifTrue: [
			doFlip _ ((i \\ 360) >= 90) & ((i \\ 360) <= 270).
			wasFlipped ifTrue: [doFlip _ doFlip not].
			doFlip ifTrue: [rotatedForm _ thumbForm flipBy: #horizontal centerAt: 0@0]].

		thumbnailMorph form fill: thumbnailMorph form boundingBox fillColor: Color transparent.
		rotatedForm
			displayOn: thumbnailMorph form
			at: (thumbnailMorph extent - rotatedForm extent) // 2
			rule: Form paint.
		pen place: center.
		pen goto: center + (Point r: 22 degrees: i).
		thumbnailMorph changed.

		World displayWorldSafely.
		Delay waitMSecs: 20].

	thumbnailMorph showDirection: true.
	thumbnailMorph updateThumbnail.
! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'ee 11/5/2007 11:50'!
cleanUp
	"Align all scripts vertically in alphabetical order"

	| scriptsMorph |
	scriptsMorph _ (pageViewerMorph allMorphs select: [:c | c isKindOf: ScratchScriptsMorph]) first.
	scriptsMorph cleanUp.
	pageViewerMorph
		updateContentsExtent;
		updateScrollbars.

! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'ee 2/12/2009 16:23'!
deleteSprite
	"Ask the user if they want to delete the currently selected sprite"

	| response |
	response _ DialogBoxMorph askWithCancel: 'Delete this sprite?' localized.
	response = #cancelled ifTrue: [^ self].
	response ifTrue: [thumbnailMorph target undoableDeleteSprite].
! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'jens 3/9/2009 13:19'!
saveScriptsToImage
	"Take a snapshot of all scripts for a sprite and save as a GIF file"

	| fName saveForm |

	saveForm _ pageViewerMorph contents screenshot.

	fName _ ScratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Scripts Snapshot'
		type: #scriptsSnapshot.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	(fName asLowercase endsWith: '.gif') ifFalse: [fName _ fName, '.gif'].
	saveForm writeGIFFileNamed: fName.
! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'jens 1/8/2010 00:53'!
scriptsMenu: aPosition
	"Present a menu of Scratch script operations."

	| menu choice |
	self target ifNil: [^ self].
	menu _ CustomMenu new.
	menu add: 'clean up' action: #cleanUp.
	menu add: 'save picture of scripts' action: #saveScriptsToImage.
	menu add: 'add comment' action: #addComment:.
	menu add: 'undo last drop' action: #undoDrop.
	menu addLine.
	menu add: 'make a block' action: #addCustomBlock.

	choice _ menu localize startUp.
	choice ifNil: [^ self].
	choice = #addComment:
		ifTrue: [self perform: choice with: aPosition]
		ifFalse: [self perform: choice].
! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'jens 2/24/2011 12:50'!
setRotationStyle: aSymbol

	aSymbol == #Smooth ifTrue: [self target setRotationStyle: 1].
	aSymbol == #Flip ifTrue: [self target setRotationStyle: 2].
	aSymbol == #None ifTrue: [self target setRotationStyle: 0].

"
	self updateRotationButtonHighlight.

	(self target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	self animateRotationStyle.

"! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'jm 10/19/2007 11:35'!
toggleSpriteDraggable
	"Add buttons to set the rotation style."

	self target draggable: self target draggable not.
	self updateLockButton.
! !

!ScratchScriptEditorMorph methodsFor: 'menu/button ops' stamp: 'jens 4/16/2009 00:54'!
undoDrop

	| scriptsMorph |
	scriptsMorph _ (pageViewerMorph allMorphs select: [: m | m isKindOf: ScratchScriptsMorph]) first.
	scriptsMorph undoLastDrop
! !


!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 2/22/2009 21:37'!
addDeleteButton
	"Add button to delete sprite."

	self deleteDeleteButton.

	deleteButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #deleteSprite)
		offForm: (ScratchFrameMorph skinAt: #deleteSprite)
		overForm: (ScratchFrameMorph skinAt: #deleteSprite).

	deleteButton
		target: self;
		actionSelector: #deleteSprite;
		setBalloonText: 'Delete this sprite' localized;
		actWhen: #buttonUp;
		isMomentary: true;
		position: (lockButton right + 27)@(nameMorph top + ((nameMorph height - deleteButton height) / 2)).

	self addMorph: deleteButton.
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'ee 2/11/2009 14:13'!
addLockButton
	"Add button to set sprite locked status."

	self deleteLockButton.

	lockButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #locked)
		offForm: (ScratchFrameMorph skinAt: #unlocked).

	lockButton
		target: self;
		actionSelector: #toggleSpriteDraggable;
		setBalloonText: 'draggable on website?' localized;
		actWhen: #buttonUp;
		isMomentary: true;
		position: (nameMorph right + 4)@(nameMorph top + ((nameMorph height - lockButton height) / 2)).

	self addMorph: lockButton.
	self updateLockButton.
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'JM 9/20/2011 11:49'!
addReadouts
	"Add readouts for my target's position and direction."

	| x y label readout s |

	self deleteReadouts.
	readoutMorphs _ OrderedCollection new.

	x _ nameMorph left.
	y _ nameMorph bottom + 5.

	#(('x' xpos) ('y' ypos)('direction' heading)) do: [:spec |

		(ScratchTranslator isRTL and: [(spec at: 1) = 'x' or: [(spec at: 1) = 'y']])
			ifTrue: [s _ (':', spec first) asUTF8]
			ifFalse: [s _ (spec first localized, ScratchTranslator colonSuffix)].

		label _ StringMorph new
			contents: s;
			font: (ScratchFrameMorph getFont: #XYReadout);
			position: x@y.

		readout _ (UpdatingStringMorph on: self target selector: spec second)
			font: (ScratchFrameMorph getFont: #XYReadoutBold);
			forceUnicodeRendering: true;
			color: (Color gray: 0.2);
			contents: '-000';  "this sets the readout size"
			growable: false;
			stepTime: 100;
			position: (label right + 4)@y.

		ScratchTranslator isRTL ifTrue:[
			readout rightJustify: true].

		self addMorph: label; addMorph: readout.
		readoutMorphs add: label; add: readout.

		readout startStepping.
		x _ readout right + 2].

	ScratchTranslator isRTL ifTrue: [
		readoutMorphs reversed do: [: m |
			readoutMorphs remove: m.
			readoutMorphs add: m]].

	penReadout _ Morph new extent: 15@5.
	penReadout position: (lockButton right + 4)@(nameMorph top + ((nameMorph height - penReadout height) / 2));
		color: Color transparent.
	self addMorph: penReadout.
	readoutMorphs add: penReadout.
	penReadout startStepping.

	readoutMorphs _ readoutMorphs asArray.
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 3/21/2008 14:02'!
addRotationButtons
	"Add buttons to set the rotation style."

	| specs x y style button |
	self deleteRotationButtons.
	(self target respondsTo: #rotationStyle:) ifFalse: [^ self].

	specs _ #(
		(Smooth		'can rotate')
		(Flip		'only face left-right')
		(None		'don''t rotate')).

	x _ self left + 13.
	y _ self top + 18.
	specs do: [:pair |
		style _ pair first.
		button _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('rotStyle', style, 'On'))
			offForm: (ScratchFrameMorph skinAt: ('rotStyle', style))
			overForm: (ScratchFrameMorph skinAt: ('rotStyle', style, 'Over')).
		button
			target: self;
			arguments: (Array with: style);
			actionSelector: #setRotationStyle:;
			setBalloonText: pair second localized;
			actWhen: #buttonDown;
			position: x@y.
		self addMorph: button.
		rotationButtons _ rotationButtons copyWith: button.
		y _ y + button height + 2].

	self updateRotationButtonHighlight.
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'ee 2/12/2009 10:49'!
deleteDeleteButton
	"Delete my delete button."

	deleteButton ifNotNil: [
		deleteButton delete.
		deleteButton _ nil].
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 10/3/2007 16:42'!
deleteLockButton
	"Delete my lock button."

	lockButton ifNotNil: [
		lockButton delete.
		lockButton _ nil].
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 2/28/2005 17:46'!
deleteReadouts
	"Delete the position/rotation readouts."

	readoutMorphs do: [:m | m delete].
	readoutMorphs _ #().
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 2/28/2005 17:40'!
deleteRotationButtons
	"Delete the rotation style buttons."

	rotationButtons do: [:m | m delete].
	rotationButtons _ #().
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'JM 9/20/2011 11:49'!
showOrHideReadouts
	"If this is a sprite, show the position and direction readouts and the rotation style buttons. Otherwise, hide them."

	self deleteRotationButtons; deleteLockButton; deleteReadouts.

	nameMorph
		font: nameMorph font;
		width: nameMorph height * 4;
		rightJustify: ScratchTranslator isRTL.

	(self target isKindOf: ScratchSpriteMorph) ifTrue: [
		self addRotationButtons. "; addLockButton; addReadouts. - not needed in cellular"
		World ifNotNil: [World startSteppingSubmorphsOf: self]].
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 10/23/2007 15:24'!
updateLockButton

	lockButton ifNil: [^ self].
	self target draggable
		ifTrue: [lockButton off]
		ifFalse: [lockButton on].
! !

!ScratchScriptEditorMorph methodsFor: 'private' stamp: 'jm 2/28/2005 17:33'!
updateRotationButtonHighlight
	"Highlight the appropriate rotation style button. Do nothing if my target is not a sprite."

	| style sym |
	(self target isKindOf: ScratchSpriteMorph) ifFalse: [^ self].

	style _ self target rotationStyle.
	style = #normal ifTrue: [sym _ #Smooth].
	style = #leftRight ifTrue: [sym _ #Flip].
	style = #none ifTrue: [sym _ #None].

	rotationButtons do: [:m |
		sym = m arguments first ifTrue: [m on] ifFalse: [m off]].
! !
