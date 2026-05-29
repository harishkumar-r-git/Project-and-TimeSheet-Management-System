using my.timeSheet_mgmt.timeSheetService as service from '../../srv/timeSheet-service';
// using my.project_mgmt.projectService as Pservice from '../../srv/project-service';

annotate service.timeSheets with @(
    UI.HeaderInfo : {
    TypeName : 'Time Sheet',
    TypeNamePlural : 'Time Sheets',
    Title : { Value : WeekStartDate },
    Description : { Value : Status },
    // Initials : WeekStartDate,
    // ImageUrl : WeekStartDate,
  },
  UI.FieldGroup #GeneratedGroup1 : {
    $Type : 'UI.FieldGroupType',
    Data : [        
    { $Type : 'UI.DataField', Label : 'Employee', Value : Employee_ID, },
      { $Type : 'UI.DataField', Label : 'Week Start Date', Value : WeekStartDate, },
      { $Type : 'UI.DataField', Label : 'Status', Value : Status, Criticality : TSCriticality},
      { $Type : 'UI.DataField', Label : 'Total Hours', Value : TotalHours, },
      { $Type : 'UI.DataField', Label : 'Approved By', Value : ApprovedBy_ID, },
      { $Type : 'UI.DataField', Label : 'Approved At', Value : ApprovedAt, },
    ],
  },
   UI.SelectionFields : [
    WeekStartDate, Status, TotalHours, ApprovedBy_ID, ApprovedAt,
  ],
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'Time Sheet Details',
            Target : '@UI.FieldGroup#GeneratedGroup1',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Time Sheet Entries',
            ID : 'TimeSheetEntries',
            Target : 'Entries/@UI.LineItem#TimeSheetEntries',
        },
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Label : 'Week Start Date', Value : WeekStartDate, },
        { $Type : 'UI.DataField', Label : 'Status', Value : Status, Criticality : TSCriticality},
        { $Type : 'UI.DataField', Label : 'Total Hours', Value : TotalHours, },
        { $Type : 'UI.DataField', Label : 'Approved By', Value : ApprovedBy.Name, },
        { $Type : 'UI.DataField', Label : 'Approved At', Value : ApprovedAt, },
        { $Type : 'UI.DataFieldForAction', Label : 'Submit Time Sheet', Action : 'timeSheetService.submitTimeSheet', },

  ],
  Capabilities.FilterRestrictions : {
      FilterExpressionRestrictions : [
          {
              Property : WeekStartDate,
              AllowedExpressions : 'SingleRange'
          },
          {
              Property : ApprovedAt,
              AllowedExpressions : 'SingleRange'
          }
      ]
  },
//   UI.Identification : [
//     {
//       $Type : 'UI.DataField',
//       Label : 'Employee',
//       Value : Employee_ID
//     }
//   ]
);

annotate service.timeSheets with {
    
  Employee @(
    Common.Text : Employee.Name,
    Common.TextArrangement : #TextOnly,
    UI.Hidden : HideForDeveloper,
    Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'employees',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterIn',
                LocalDataProperty : Employee_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'EmpNo',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'Name',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'Email',
            },
        ],
        Label : 'Employee',
    },
    Common.ValueListWithFixedValues : false,
    
  );

  Status @(
    Common.Label : 'TimeSheet Status',
    Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'timeSheetStatusView',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : Status,
                ValueListProperty : 'Status',
            },
        ],
    },
    Common.ValueListWithFixedValues : true,
  );

  ApprovedBy @(
      Common.Text : ApprovedBy.Name,
      Common.TextArrangement : #TextOnly,
      Common.ValueList : {
          $Type : 'Common.ValueListType',
          CollectionPath : 'employees',
          Parameters : [
              {
                  $Type : 'Common.ValueListParameterIn',
                  LocalDataProperty : ApprovedBy_ID,
                  ValueListProperty : 'ID',
              },
              {
                  $Type : 'Common.ValueListParameterDisplayOnly',
                  ValueListProperty : 'EmpNo',
              },
              {
                  $Type : 'Common.ValueListParameterDisplayOnly',
                  ValueListProperty : 'Name',
              },
              {
                  $Type : 'Common.ValueListParameterDisplayOnly',
                  ValueListProperty : 'Email',
              },
              {
                  $Type : 'Common.ValueListParameterConstant',
                  ValueListProperty : 'isProjectManager',
                  Constant : true,
              },
          ],
      },
      Common.Label : 'Approved By',
      Common.FieldControl : #ReadOnly,
  );

  ApprovedAt @(
    Common.Label : 'Approved At',
    Common.FieldControl : #ReadOnly,
    );

  WeekStartDate @Common.Label : 'Week Start Date';

  TotalHours @Common.Label : 'Total Hours'
};

annotate service.timeSheetEntries with @(
    UI.HeaderInfo : {
    TypeName : 'Time Sheet Entry',
    TypeNamePlural : 'Time Sheet Entries ',
    Title : { Value : WorkPackage_ID },
    Description : { Value : EntryDate },
    // Initials : WeekStartDate,
    // ImageUrl : WeekStartDate,
  },
   UI.FieldGroup #GeneratedGroup1 : {
    $Type : 'UI.FieldGroupType',
    Data : [
      { $Type : 'UI.DataField', Label : 'Time Sheet', Value : Timesheet_ID, },
      { $Type : 'UI.DataField', Label : 'Assigned Work Packages', Value : WorkPackage_ID, },
      { $Type : 'UI.DataField', Label : 'Entry Date', Value : EntryDate, },
      { $Type : 'UI.DataField', Label : 'Hours', Value : Hours, },
      { $Type : 'UI.DataField', Label : 'Description', Value : Description, },
    ],
  },
  UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'Time Sheet Entries',
            Target : '@UI.FieldGroup#GeneratedGroup1',
        },
    ],
    UI.LineItem #TimeSheetEntries : [
        { $Type : 'UI.DataField', Label : 'Work Package Title', Value : WorkPackage_ID, },
        { $Type : 'UI.DataField', Label : 'Entry Date', Value : EntryDate, },
        { $Type : 'UI.DataField', Label : 'Hours', Value : Hours, },
        { $Type : 'UI.DataField', Label : 'Description', Value : Description, },
    ]
);

annotate service.timeSheetEntries with {
    WorkPackage @(
        Common.Text : WorkPackage.Title,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            CollectionPath : 'workPackages',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : WorkPackage_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'WPCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'Title'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'ProjectCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'ProjectName'
                },
            ]
        }
    );

    Timesheet @UI.Hidden;


};




