StringDialog subclass: #NewEnvAttributeDialog
	instanceVariableNames: 'minText maxText spreadText defaultText colorSelection '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 16:05'!
createLabel: aString

	^ StringMorph new
		contents: (aString localized);
		font: (ScratchFrameMorph getFont: #StringDialogTypeIn).! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 16:05'!
createRow

	^ AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 16:06'!
createStringField

	^ StringFieldMorph new 
			client: self;
			borderWidth: 2;
			color: (Color r: (211/255) g: (214/255) b: (216/255)).! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/20/2011 16:31'!
getUserResponse
	"Wait for the user to type in and accept a string, then report that string. Answer the empty string if the user cancels the operation."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	self centerOnScreen.

	w _ self world.
	w activeHand newKeyboardFocus: typeinMorph.
	done _ false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	self delete.
	w doOneCycle.  "erase myself from the screen"
	response = #cancelled
		ifTrue: [^ '']
		ifFalse: [^ { typeinMorph contents asUTF8.
					minText contents asNumber.
					maxText contents asNumber.
					defaultText contents asNumber. 
					spreadText contents asNumber.
					colorSelection evaluate 
					}
			].! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 16:21'!
initialize

	| minLabel minGroup maxLabel maxGroup defaultLabel defaultGroup spreadLabel spreadGroup colorLabel colorGroup |
	super initialize.

	minGroup _ self createRow.
	minLabel _ self createLabel: 'Min value'.
	minText _ self createStringField.

	maxGroup _ self createRow.
	maxLabel _ self createLabel: 'Max value'.
	maxText _ self createStringField.

	defaultGroup _ self createRow.
	defaultLabel _ self createLabel: 'Default value'.
	defaultText _ self createStringField.

	spreadGroup _ self createRow.
	spreadLabel _ self createLabel: 'Spread size'.
	spreadText _ self createStringField.

	colorGroup _ self createRow.
	colorLabel _ self createLabel: 'Colour'.
	colorSelection _ ColorArgMorph new.

	minGroup addMorphBack: minLabel;
		addMorphBack: (Morph new extent: (27@5); color: Color transparent);
		addMorphBack: minText;
		addMorphBack: (Morph new extent: (0@5); color: Color transparent).

	maxGroup addMorphBack: maxLabel;
		addMorphBack: (Morph new extent: (23@5); color: Color transparent);
		addMorphBack: maxText;
		addMorphBack: (Morph new extent: (0@5); color: Color transparent).

	defaultGroup addMorphBack: defaultLabel;
		addMorphBack: (Morph new extent: (5@5); color: Color transparent);
		addMorphBack: defaultText;
		addMorphBack: (Morph new extent: (0@5); color: Color transparent).

	spreadGroup addMorphBack: spreadLabel;
		addMorphBack: (Morph new extent: (15@5); color: Color transparent);
		addMorphBack: spreadText;
		addMorphBack: (Morph new extent: (0@5); color: Color transparent).

	colorGroup addMorphBack: colorLabel;
		addMorphBack: (Morph new extent: (44@5); color: Color transparent);
		addMorphBack: colorSelection;
		addMorphBack: (Morph new extent: (87@5); color: Color transparent).

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: typeinMorph;
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: minGroup;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: maxGroup;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: defaultGroup;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: spreadGroup;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: colorGroup;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.
	

	! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 16:40'!
min

	^ minText contents asNumber.! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/20/2011 16:30'!
response

	"returns an array containing the resulting input"
	^ { 	typeinMorph contents asUTF8,
		minText contents asNumber,
		maxText contents asNumber,
		defaultText contents asNumber, 
		spreadText contents asNumber,
		color evaluate 
		}! !

!NewEnvAttributeDialog methodsFor: 'as yet unclassified' stamp: 'JM 9/1/2011 16:39'!
yes

	"verify all fields valid"

	[minText contents asNumber] ifError: [ minText borderColor: (Color fromString: 'red'). ^ self ].
	minText borderColor: #inset.
	[maxText contents asNumber] ifError: [ maxText borderColor: (Color fromString: 'red'). ^ self ].
	maxText borderColor: #inset.
	[defaultText contents asNumber] ifError: [ defaultText borderColor: (Color fromString: 'red'). ^ self ].
	defaultText borderColor: #inset.
	[spreadText contents asNumber] ifError: [ spreadText borderColor: (Color fromString: 'red'). ^ self ].
	spreadText borderColor: #inset.
	
	super yes.! !
