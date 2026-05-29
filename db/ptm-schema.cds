namespace my.project_timesheet_mgmt;

using {
  cuid,
  managed
} from '@sap/cds/common';

type ProjectStatus   : String(20) enum {
  Planning = 'Planning';
  Active = 'Active';
  OnHold = 'OnHold';
  Completed = 'Completed';
  Cancelled = 'Cancelled';
}

type WPStatus        : String(20) enum {
  Open = 'Open';
  InProgress = 'InProgress';
  Completed = 'Completed';
  Blocked = 'Blocked';
}

type TimesheetStatus : String(20) enum {
  Draft = 'Draft';
  Submitted = 'Submitted';
  Approved = 'Approved';
  Rejected = 'Rejected';
}

entity Employees : cuid, managed {
  EmpNo            : String(10) not null;
  Name             : String(100) not null;
  Email            : String(200) not null;

  isProjectManager : Boolean default false;
  department       : Association to Departments;

  HourlyRate       : Decimal(10, 2); // restricted field
  Skills           : String(500);

  timesheets       : Association to many Timesheets
                       on timesheets.Employee = $self;

  managed_projects : Association to many Projects
                       on managed_projects.ProjectManager = $self;
}

entity Departments : cuid {
  deptCode  : String(5);
  deptName  : String(100);
  employees : Association to many Employees
                on employees.department = $self;
}

entity Projects : cuid, managed {
  ProjectCode        : String(20) not null          @mandatory;
  Name               : String(200) not null         @mandatory;
  Client             : String(200)                  @mandatory;
  StartDate          : Date                         @mandatory;
  EndDate            : Date                         @mandatory;
  Budget             : Decimal(15, 2) default 0     @mandatory;

  InfrastructureCost : Decimal(15, 2) default 0; // shared infra for whole project
  LicenseCost        : Decimal(15, 2) default 0; // project-wide licenses
  BudgetVariance     : Decimal(15, 2) default 0     @readonly;

  Status             : ProjectStatus default 'Planning';
  Criticality        : Integer default 2;
  ProjectManager     : Association to one Employees @mandatory;

  WorkPackages       : Composition of many WorkPackages
                         on WorkPackages.Project = $self;

  invoiceName        : String;

  // mediaType      : String; // e.g., 'application/pdf', 'image/png'

  @Core.MediaType                  : 'application/pdf' // Links the binary content to its type
  @Core.ContentDisposition.Filename: invoiceName
  @Core.ContentDisposition.Type    : 'inline' // 'inline' -> tells open file in new tab, 'attachment' tells download the file
  invoiceContent     : LargeBinary                  @readonly;
}

entity WorkPackages : cuid, managed {
  Project      : Association to Projects not null @mandatory;
  WPCode       : String(20) not null              @mandatory;
  Title        : String(200) not null             @mandatory;
  PlannedHours : Decimal(10, 2) default 0         @mandatory;

  ActualHours  : Decimal(10, 2) default 0;
  AssignedTo   : Association to Employees         @mandatory;
  Status       : WPStatus default 'Open';
}

entity Timesheets : cuid, managed {
  Employee      : Association to Employees not null ;
  WeekStartDate : Date not null @mandatory;
  Status        : TimesheetStatus default 'Draft';

  TotalHours    : Decimal(10, 2) default 0 @readonly;

  ApprovedBy    : Association to Employees;
  ApprovedAt    : Timestamp;
  RejectionNote : String(500);

  Entries       : Composition of many TimesheetEntries
                    on Entries.Timesheet = $self;
}

entity TimesheetEntries : cuid {
  Timesheet       : Association to Timesheets not null;
  WorkPackage     : Association to WorkPackages not null @mandatory;
  EntryDate       : Date not null @mandatory;
  Hours           : Decimal(4, 2) @mandatory;
  Description     : String(500);
}

view ApprovedHoursPerWP as
  select
    key te.WorkPackage.ID                                    as WorkPackageID,
        te.Timesheet.Employee                                as EmployeeID,
        te.WorkPackage.Project.ID                            as ProjectID,
        te.WorkPackage.Project.Budget                        as Budget,
        sum(te.Hours)                                        as ApprovedHours   : Decimal(10, 2),
        te.WorkPackage.AssignedTo.HourlyRate                 as HourlyRate,
        sum(te.Hours) * te.WorkPackage.AssignedTo.HourlyRate as ActualCostPerWP : Decimal(15, 2)

  from TimesheetEntries as te
  where
    te.Timesheet.Status = 'Approved'
  group by
    te.WorkPackage.ID,
    te.Timesheet.Employee,
    te.WorkPackage.Project.ID,
    te.WorkPackage.Project.Budget,
    te.WorkPackage.AssignedTo.HourlyRate;

view ActualCostPerProject as
  select from ApprovedHoursPerWP as a
  inner join Projects as p
    on a.ProjectID = p.ID
  {
    key a.ProjectID,
        p.Budget,
        p.InfrastructureCost,
        p.LicenseCost,
        p.BudgetVariance,

        sum(a.ApprovedHours)   as TotalApprovedHours   : Decimal(10, 2),
        sum(a.ActualCostPerWP) as TotalLabourCostPerWP : Decimal(15, 2)

  }
  group by
    a.ProjectID,
    p.Budget,
    p.InfrastructureCost,
    p.LicenseCost,
    p.BudgetVariance;

entity ProjectStatusView   as
  select from Projects {
    key Status
  }
  group by
    Status;

entity TimeSheetStatusView as
  select from Timesheets {
    key Status
  }
  group by
    Status;
