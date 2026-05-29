sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"ns/projectmanagerdashboard/test/integration/pages/projectsList",
	"ns/projectmanagerdashboard/test/integration/pages/projectsObjectPage",
	"ns/projectmanagerdashboard/test/integration/pages/workPackagesObjectPage"
], function (JourneyRunner, projectsList, projectsObjectPage, workPackagesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('ns/projectmanagerdashboard') + '/test/flp.html#app-preview',
        pages: {
			onTheprojectsList: projectsList,
			onTheprojectsObjectPage: projectsObjectPage,
			onTheworkPackagesObjectPage: workPackagesObjectPage
        },
        async: true
    });

    return runner;
});

