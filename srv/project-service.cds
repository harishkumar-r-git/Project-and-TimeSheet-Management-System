namespace my.project_mgmt;

using { my.project_timesheet_mgmt as pdb } from '../db/ptm-schema';

@requires: ['developer', 'projectManager', 'admin']
service projectService {



  @cds.redirection.target
  @(restrict: [
    { grant: 'READ', to: ['developer', 'projectManager', 'admin'] },
    { grant: 'UPDATE', to: ['projectManager', 'admin'] },
    { grant: ['CREATE', 'DELETE'], to: ['admin'] }
  ])
  entity employees as projection on pdb.Employees;

  @cds.redirection.target
  @odata.draft.enabled
  @(restrict: [
    { grant: 'READ',                         to: ['developer', 'projectManager', 'admin'] },
    { grant: ['CREATE','UPDATE','DELETE'],   to: ['projectManager', 'admin'] }
  ])
  entity projects as projection on pdb.Projects {
    *,
    virtual null as HideForDeveloper : Boolean,
    virtual null as EditControlForAdmin : Integer,
    virtual null as BudgetHealth : Integer,
    virtual null as TotalWPperProject : Integer,
    virtual null as CompletedWPperPRoject : Integer,
    virtual null as ProgressBar : Integer,

   } actions {
    
    @(restrict: [{ grant: 'EXECUTE',         to: ['projectManager', 'admin'] }])
    action startProject() returns String;

    @(restrict: [{ grant: 'EXECUTE',          to: ['projectManager', 'admin'] }])
    action completeProject() returns String;

    @(restrict: [{ grant: 'EXECUTE',          to: ['projectManager', 'admin'] }])
    action generateInvoice() returns String;

    @(restrict: [{ grant: 'EXECUTE',          to: ['projectManager', 'admin'] }])
    action getBudgetVariance() returns projects;
  };

  @(restrict: [
    { grant: 'READ',                         to: ['developer', 'projectManager', 'admin'] },
    { grant: ['CREATE', 'UPDATE', 'DELETE'], to: ['projectManager', 'admin']             }
  ])
  entity workPackages as projection on pdb.WorkPackages;

  @(restrict: [
    { grant: 'READ', to: ['developer', 'projectManager', 'admin'] }
  ])
  entity departments as projection on pdb.Departments;

  @readonly
  @(requires: ['projectManager', 'admin'])
  entity approvedHoursPerWP as projection on pdb.ApprovedHoursPerWP;
  
  @readonly
  @(requires: ['projectManager', 'admin'])
  entity actualCostPerProject as projection on pdb.ActualCostPerProject;

  @readonly
  @(restrict: [
    { grant: 'READ', to: ['developer', 'projectManager', 'admin'] }
  ])
  entity projectStatusView as projection on pdb.ProjectStatusView;

}
