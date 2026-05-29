namespace my.timeSheet_mgmt;

using { my.project_timesheet_mgmt as tdb } from '../db/ptm-schema';

@requires: ['developer', 'projectManager', 'admin']
service timeSheetService {

  @odata.draft.enabled
  @cds.redirection.target
  @(restrict: [
    { grant: 'READ',                         to: ['developer'],   where: 'Employee.Email = $user' },
    { grant: 'READ',                         to: ['projectManager', 'admin'] },
    { grant: ['CREATE', 'UPDATE', 'DELETE'], to: ['developer', 'admin'] }
  ])
  entity timeSheets as projection on tdb.Timesheets {
    *,
    virtual null as HideForDeveloper : Boolean,
    virtual null as ApprovedAtEditControl : Boolean,
    virtual null as TSCriticality : Integer default 2,
  } actions {

    @(restrict: [{ grant: 'EXECUTE', to: ['developer'] } ])
    action submitTimeSheet() returns String;

    @(restrict: [{ grant: 'EXECUTE', to: ['developer'] } ])
    action approveTimeSheet() returns String;

    @(restrict: [{ grant: 'EXECUTE', to: ['developer'] } ])
    action rejectTimeSheet(RejectionNote: String) returns String;

  };

  @cds.redirection.target
  @(restrict: [
    { grant: 'READ',                          to: ['developer', 'projectManager', 'admin'] },
    { grant: ['CREATE', 'UPDATE', 'DELETE'],  to: ['developer', 'admin']                  }
  ])
  entity timeSheetEntries as projection on tdb.TimesheetEntries;

  @readonly
  @(restrict: [
    { grant: 'READ',      to: ['developer', 'projectManager', 'admin'] }
  ])
  entity timeSheetStatusView as projection on tdb.TimeSheetStatusView;

  @readonly
  @(restrict: [
    { grant: 'READ',      to: ['developer', 'projectManager', 'admin'] }
  ])
  entity employees as projection on tdb.Employees;
  
  @readonly
  @(restrict: [
    { grant: 'READ',      to: ['developer'],   where: 'AssignedTo.Email = $user' },
    { grant: 'READ',      to: ['projectManager', 'admin']  }
  ])
  entity workPackages as projection on tdb.WorkPackages {
    *,
    Project.ProjectCode as ProjectCode,
    Project.Name as ProjectName
  };

}