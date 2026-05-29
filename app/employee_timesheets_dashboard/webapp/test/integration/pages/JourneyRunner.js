sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"ns/employeetimesheetsdashboard/test/integration/pages/timeSheetsList",
	"ns/employeetimesheetsdashboard/test/integration/pages/timeSheetsObjectPage",
	"ns/employeetimesheetsdashboard/test/integration/pages/timeSheetEntriesObjectPage"
], function (JourneyRunner, timeSheetsList, timeSheetsObjectPage, timeSheetEntriesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('ns/employeetimesheetsdashboard') + '/test/flp.html#app-preview',
        pages: {
			onThetimeSheetsList: timeSheetsList,
			onThetimeSheetsObjectPage: timeSheetsObjectPage,
			onThetimeSheetEntriesObjectPage: timeSheetEntriesObjectPage
        },
        async: true
    });

    return runner;
});

