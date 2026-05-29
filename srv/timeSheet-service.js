const cds = require('@sap/cds');
const { UPDATE, SELECT } = require('@sap/cds/lib/ql/cds-ql');

module.exports = cds.service.impl(async function () {

  const { timeSheets, timeSheetEntries, employees } = this.entities;
  const { projects, workPackages, approvedHoursPerWP, actualCostPerProject } = cds.entities('my.project_mgmt.projectService');

  this.before(['CREATE', 'UPDATE'], 'timeSheets', async (req) => {

    const { ID, WeekStartDate, Entries } = req.data;

    const employee = await SELECT.one.from(employees).where({ Email: req.user.id }).columns( 'ID' );
    
    if (!employee) return req.error(404, `No employee profile exists for user: ${req.user.id}`);
    
    req.data.Employee_ID = employee.ID;

    const isMonday = new Date(WeekStartDate).getDay();

    if( isMonday !== 1 ) return req.error(400, "Week Starting Date should be MONDAY");

    if( !Entries || Entries.length === 0 ) return req.error(400, "Enter Atleast One Time Sheet Entry");

    for (const e of Entries) {

      const entryDate = new Date(e.EntryDate).getDay();

      if( entryDate < 1 || entryDate > 5 ) return req.error("The Entry Day should be Week Days");

      if( e.Hours > 9 || e.Hours < 1 ) return req.error("Enter Valid Office Hours");
    }

  });

  this.after( 'READ', 'timeSheets', async (data, req) => {

    const rows = Array.isArray(data) ? data : [data];

    const isDeveloper = req.user.is('developer');

    for( const row of rows ) {
        row.HideForDeveloper = isDeveloper; 

        if( row.Status == 'Approved' ) row.TSCriticality = 3;
        else if( row.Status == 'Draft' ) row.TSCriticality = 2;
        else if( row.Status == 'Rejected' ) row.TSCriticality = 1;
        else if( row.Status == 'Submitted' ) row.TSCriticality = 5;
        else row.TSCriticality = 0;
        
    }

  })


  this.before('submitTimeSheet', async (req) => {

    const { ID } = req.params[0];

    const entries = await SELECT.from(timeSheetEntries).where({ Timesheet_ID : ID });
    if(entries.length == 0 ) return req.error(400, "No Valid Work Packages");

    const totalHours = entries.reduce((sum, e) => sum + e.Hours, 0);

    await UPDATE(timeSheets).set({ TotalHours : totalHours}).where({ ID: ID});

    if(totalHours < 0 || totalHours > 40) {
        return req.error(400, 'The Total Hours should be between 0 to 40');
      }
      
    const workPackagesIDs = await SELECT.from(workPackages).columns('ID');
    
    const validWP = new Set(workPackagesIDs.map(wp => wp.ID));

    for (const entry of entries) {
      if (!validWP.has(entry.WorkPackage_ID)) {
        return req.error(400, `Invalid WorkPackage ID: ${entry.WorkPackage_ID}`);
      }
    }

    const timesheet = await SELECT.one.from(timeSheets).columns('Status').where({ ID : ID});
    
    if(timesheet.Status != 'Draft') return req.error(400, "The Time Sheet should be in Draft while submitting");

  })

  this.on('submitTimeSheet', async (req) => {

    const { ID } = req.params[0];

    await UPDATE(timeSheets).set( { Status : 'Submitted', TSCriticality : 5 }).where({ ID :ID });
    

    return req.info("TimeSheet submitted Successfully");
  })

  this.on('approveTimeSheet', 'timeSheets', async (req) => {

    const { ID } = req.params[0];

    await UPDATE(timeSheets).set( { Status : 'Approved', TSCriticality : 3 }).where({ ID :ID });
    
    return { ID , message : "TimeSheet Approved"};
  })

  this.after('approveTimeSheet', 'timeSheets', async (data, req) => {

    const { ID } = req.params[0];

    const entries = await SELECT.from(timeSheetEntries).columns('WorkPackage_ID').where({ Timesheet_ID: ID });

    const wpIDs = [...new Set(entries.map(e => e.WorkPackage_ID))];

    if (wpIDs.length === 0) return req.error(400, "The Time Sheet has no Work Packages");

      const approvedHoursAllWP = await SELECT.from(approvedHoursPerWP).columns('WorkPackageID', 'ApprovedHours', 'ProjectID').where({ WorkPackageID: { in: wpIDs } });

    for (const row of approvedHoursAllWP) {

      await UPDATE(workPackages).set({ ActualHours: row.ApprovedHours }).where({ ID: row.WorkPackageID });

    }

    const projectIDs = [...new Set(approvedHoursAllWP.map(r => r.ProjectID))];
    
    for (const projectID of projectIDs) {

      const project = await SELECT.one.from(projects).where({ ID: projectID });
      const labour = await SELECT.one.from(actualCostPerProject).where({ ProjectID: projectID });

      const totalProjectCost = parseFloat(project.InfrastructureCost) + parseFloat(project.LicenseCost) + parseFloat(labour?.TotalLabourCostPerWP || 0);

      const variance = parseFloat(project.Budget) - totalProjectCost;

      await UPDATE(projects).set({ BudgetVariance: variance }).where({ ID: projectID });

    }

  });


  this.on('rejectTimeSheet', 'timeSheets', async (req) => {

    const { ID } = req.params[0];
    const { RejectionNote } = req.data;

    await UPDATE(timeSheets).set( { Status : 'Rejected', RejectionNote : RejectionNote, TSCriticality : 1 }).where({ ID :ID });

    return true;
  });

})