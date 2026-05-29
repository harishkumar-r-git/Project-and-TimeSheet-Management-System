using my.project_mgmt.projectService as service from '../../srv/project-service';

annotate service.projects with @(
  UI.HeaderInfo                  : {
    TypeName      : 'Project',
    TypeNamePlural: 'Projects',
    Title         : {Value: Name},
    Description   : {Value: Client},
    Initials      : Name,
    ImageUrl      : Name,
  },
  UI.HeaderFacets : [
    {
      $Type : 'UI.ReferenceFacet',
      Target : @UI.DataPoint#Rating1,
    },
    {
      $Type : 'UI.ReferenceFacet',
      Target : @UI.DataPoint#Progress1,
    }
  ],
  UI.FieldGroup #GeneratedGroup1 : {
    $Type: 'UI.FieldGroupType',
    Data : [
      {
        $Type: 'UI.DataField',
        Label: 'Project Code',
        Value: ProjectCode,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Project Name',
        Value: Name,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Client',
        Value: Client,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Start Date',
        Value: StartDate,
      },
      {
        $Type: 'UI.DataField',
        Label: 'End Date',
        Value: EndDate,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Status',
        Value: Status,
        Criticality: Criticality,

      },
      {
        $Type: 'UI.DataField',
        Label: 'Project Manager',
        Value: ProjectManager_ID,
      },
    ],
  },
  UI.FieldGroup #GeneratedGroup2 : {
    $Type: 'UI.FieldGroupType',
    Data : [
      {
        $Type: 'UI.DataField',
        Label: 'Budget',
        Value: Budget,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Infrastructure Cost',
        Value: InfrastructureCost,
      },
      {
        $Type: 'UI.DataField',
        Label: 'License Cost',
        Value: LicenseCost,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Budget Variance',
        Value: BudgetVariance,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Invoice',
        Value: invoiceContent
      },
      {
        $Type : 'UI.DataFieldForAction',
        Label : 'Calculate Variance',
        Action: 'projectService.getBudgetVariance'
      },
      {
        $Type : 'UI.DataFieldForAction',
        Label : 'Generate Invoice',
        Action: 'projectService.generateInvoice'
      },
    ],
  },
  UI.SelectionFields             : [
    Client,
    StartDate,
    Budget,
    Status,
    ProjectManager_ID,
  ],
  UI.Facets                      : [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'GeneratedFacet1',
      Label : 'Project Details',
      Target: '@UI.FieldGroup#GeneratedGroup1',
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'GeneratedFacet2',
      Label : 'Project Billing',
      Target: '@UI.FieldGroup#GeneratedGroup2',
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : 'Work Packages',
      ID    : 'WorkPackages',
      Target: 'WorkPackages/@UI.LineItem#WorkPackages',
    },
  ],
  UI.LineItem                    : [
    {
      $Type: 'UI.DataField',
      Label: 'Project Code',
      Value: ProjectCode,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Name',
      Value: Name,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Client',
      Value: Client,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Start Date',
      Value: StartDate,
    },
    {
      $Type: 'UI.DataField',
      Label: 'End Date',
      Value: EndDate,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Budget',
      Value: Budget,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Status',
      Value: Status,
      Criticality: Criticality,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Infrastructure Cost',
      Value: InfrastructureCost,
    },
    {
      $Type: 'UI.DataField',
      Label: 'License Cost',
      Value: LicenseCost,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Budget Variance',
      Value: BudgetVariance,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Project Manager',
      Value: ProjectManager_ID,
    },
    {
      $Type : 'UI.DataFieldForAction',
      Label : 'Start Project',
      Action: 'projectService.startProject'
    },
    {
      $Type : 'UI.DataFieldForAction',
      Label : 'Complete Project',
      Action: 'projectService.completeProject'
    },
  ],
  Capabilities.FilterRestrictions: {FilterExpressionRestrictions: [{
    Property          : StartDate,
    AllowedExpressions: 'SingleRange'
  }]},
  UI.DataPoint#Rating1 : {
    Label : 'Budget Health',
    Value : BudgetHealth,
    TargetValue : 5,
    Visualization : #Rating,
  },
  UI.DataPoint#Progress1 : {
    Label : 'Project Completion',
    Value : CompletedWPperPRoject,
    TargetValue : TotalWPperProject,
    Visualization : #Progress,
    Criticality : ProgressBar,
  },
);

annotate service.projects with {
  Status         @(
    Common.Label                   : 'Project Status',
    Common.ValueList               : {
      $Type         : 'Common.ValueListType',
      CollectionPath: 'projectStatusView',
      Parameters    : [{
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: Status,
        ValueListProperty: 'Status',
      }, ],
    },
    Common.ValueListWithFixedValues: true,
  );

  ProjectManager @(
    Common.Text           : ProjectManager.Name,
    Common.TextArrangement: #TextOnly,
    Common.ValueList      : {
      $Type         : 'Common.ValueListType',
      CollectionPath: 'employees',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterIn',
          LocalDataProperty: ProjectManager_ID,
          ValueListProperty: 'ID',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'EmpNo',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'Name',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'Email',
        },
        {
          $Type : 'Common.ValueListParameterConstant',
          ValueListProperty: 'isProjectManager',
          Constant: true,
        }
      ],
    },
    Common.Label          : 'Project Manager',
  );

  Client         @(
    Common.ValueList               : {
      $Type         : 'Common.ValueListType',
      CollectionPath: 'projects',
      Parameters    : [{
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: Client,
        ValueListProperty: 'Client',
      }, ],
    },
    Common.ValueListWithFixedValues: false,
  );

  StartDate      @Common.Label: 'Start Date';

  Budget @Measures.ISOCurrency : 'INR';

  HideForDeveloper    @UI.Hidden;

  EditControlForAdmin @UI.Hidden;

  EditControlForAdmin @Common.FieldControl: EditControlForAdmin;

  InfrastructureCost  @(
    UI.Hidden          : HideForDeveloper,
    Common.FieldControl: EditControlForAdmin,
    Measures.ISOCurrency : 'INR',
  );

  LicenseCost         @(
    UI.Hidden          : HideForDeveloper,
    Common.FieldControl: EditControlForAdmin,
    Measures.ISOCurrency : 'INR',
  );

  BudgetVariance @Measures.ISOCurrency : 'INR';
  
  invoiceContent      @(
    UI.Hidden          : HideForDeveloper,
  );

};

// annotate service.projects with @(
//     Common.SideEffects #BudgetVarianceSideEffect: {
//         TriggerAction:    'projectService.getBudgetVariance',
//         TargetProperties: ['BudgetVariance']
//     },
// );

annotate service.workPackages with @(
  UI.HeaderInfo                 : {
    TypeName      : 'Work Package',
    TypeNamePlural: 'Work Packages',
    Title         : {Value: Title},
    Description   : {Value: Project.Name},
  // Initials : WeekStartDate,
  // ImageUrl : WeekStartDate,
  },
  UI.FieldGroup #GeneratedGroup1: {
    $Type: 'UI.FieldGroupType',
    Data : [
      {
        $Type: 'UI.DataField',
        Label: 'Project',
        Value: Project.Name,
      },
      {
        $Type: 'UI.DataField',
        Label: 'WP Code',
        Value: WPCode,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Title',
        Value: Title,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Planned Hours',
        Value: PlannedHours,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Actual Hours',
        Value: ActualHours,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Assigned Employee',
        Value: AssignedTo_ID,
      },
      {
        $Type: 'UI.DataField',
        Label: 'Status',
        Value: Status,
      },
    ],
  },
  UI.Facets                     : [{
    $Type : 'UI.ReferenceFacet',
    ID    : 'GeneratedFacet1',
    Label : 'Work Package Details',
    Target: '@UI.FieldGroup#GeneratedGroup1',
  }, ],
  UI.LineItem #WorkPackages     : [
    {
      $Type: 'UI.DataField',
      Label: 'Work Package Code',
      Value: WPCode,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Title',
      Value: Title,
    },
    {
      $Type: 'UI.DataField',
      Label: 'PlannedHours',
      Value: PlannedHours,
    },
    {
      $Type: 'UI.DataField',
      Label: 'ActualHours',
      Value: ActualHours,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Assigned Employee',
      Value: AssignedTo_ID,
    },
    {
      $Type: 'UI.DataField',
      Label: 'Status',
      Value: Status,
    },
  ],
);

annotate service.workPackages with {
  AssignedTo @(
    Common.Text           : AssignedTo.Name,
    Common.TextArrangement: #TextOnly,
    Common.ValueList      : {
      $Type         : 'Common.ValueListType',
      CollectionPath: 'employees',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterIn',
          LocalDataProperty: AssignedTo_ID,
          ValueListProperty: 'ID'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'EmpNo'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'Name'
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'Email',
        },
      ]
    }
  )
}

