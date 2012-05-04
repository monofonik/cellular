DialogBoxMorph subclass: #WatcherPlotMorph
	instanceVariableNames: 'graph dataPoints '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Watchers'!

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/4/2012 16:55'!
addDataPoint: aNumber

	aNumber isNumber ifFalse: [ ^ self ].
	dataPoints addLast: aNumber.
	(dataPoints size > graph width) ifTrue: [ dataPoints removeFirst ].
	graph data: dataPoints.! !

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/4/2012 16:38'!
initialize

	super initialize withButtonsForYes: false no: false okay: true cancel: false.

	dataPoints _ OrderedCollection new.
	graph _ GraphMorph openOn: dataPoints.
	
	mainColumn addMorphFront: graph.
	self title: 'Graph'.! !
