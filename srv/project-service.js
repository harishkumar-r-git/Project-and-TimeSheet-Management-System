const cds = require('@sap/cds');
require('dotenv').config();

const { UPDATE, SELECT } = require('@sap/cds/lib/ql/cds-ql');

module.exports = cds.service.impl(async function () {

    const { projects, workPackages, actualCostPerProject } = this.entities;

    this.after('READ', ['projects', 'projects.drafts'], async (data, req) => {

        const records = Array.isArray(data) ? data : [data];

        const isNotAdmin = !req.user.is('admin') && !req.user.is('projectManager');

        for (const p of records) {  
            if (p) {
                p.HideForDeveloper = isNotAdmin;

                if (!isNotAdmin) {
                    (req.user.is('projectManager')) ? p.EditControlForAdmin = 0 : p.EditControlForAdmin = 3;
                } else {
                    p.InfrastructureCost = null;
                    p.LicenseCost = null;
                    p.BudgetVariance = null;
                }
            }

            if(p.Budget && p.Budget > 0) {

                const BudgetPercentage = ( parseFloat(p.BudgetVariance) / parseFloat(p.Budget) ) * 100;

                if(BudgetPercentage <= 100 && BudgetPercentage > 20) p.BudgetHealth = 5;
                else if(BudgetPercentage <= 20 && BudgetPercentage > 10) p.BudgetHealth = 4;
                else if(BudgetPercentage <= 10 && BudgetPercentage > 0) p.BudgetHealth = 3;
                else if(BudgetPercentage < 0 && BudgetPercentage > -10) p.BudgetHealth = 2;
                else if(BudgetPercentage <= -10) p.BudgetHealth = 1;
                else p.BudgetHealth = 0;
            }

            const projectWithPackages = await SELECT.one.from(projects).where({ ID: p.ID }).columns(
                '*',
                {
                    ref: ['WorkPackages'],
                    expand: ['*']
                }
            );

            const packages = projectWithPackages?.WorkPackages || [];

            p.TotalWPperProject = packages.length;

            p.CompletedWPperPRoject = packages.filter( wp => wp.Status == 'Completed').length;
            
            if( p.TotalWPperProject == 0 ) p.ProgressBar = 5;
            else if( p.CompletedWPperPRoject === 0 ) p.ProgressBar = 1;
            else if( p.CompletedWPperPRoject === p.TotalWPperProject ) p.ProgressBar = 3;
            else p.ProgressBar = 2;
        };

    });

    this.before('startProject', 'projects', async (req) => {

        const { ID } = req.params[0];

        const workPackagesofPID = await SELECT.from(workPackages).columns('Project_ID').where({ Project_ID : ID });

        if( workPackagesofPID.length == 0 ) return req.error(400, "Project should have atleast one WorkPackage to start.");

        const project = await SELECT.one.from(projects).where({ ID : ID });
        const today = new Date().toISOString().split('T')[0];
        
        if( project.StartDate < today ) return req.error(400, "The Start Date should not be in past");

        if( project.Status != 'Planning' && project.Status != 'OnHold') return req.error(400, "The Project should be in Planning or On Hold Status")

    })

    this.on('startProject', 'projects', async (req) => {

        const { ID } = req.params[0];

        await UPDATE(projects).set({ Status: 'Active', Criticality: 3 }).where({ ID: ID });
        
        return req.info(200,"Project Started");
    });

    this.before('completeProject', async (req) => {
        const { ID } = req.params[0];

        const workPackagesofProject = await SELECT.from(workPackages).where({ Project_ID : ID });
        const project = await SELECT.one.from(projects).where({ ID });

        const allCompleted = workPackagesofProject.every( wp => wp.Status == 'Completed');

        if(!allCompleted) return req.error(400, "All Work Packages should be Completed");

        if(project.Status != 'Active') return req.error(400, "The Project should be Active");
    })
    
    this.on('completeProject', 'projects', async (req) => {
    
        const { ID } = req.params[0];
        
        await UPDATE(projects).set({ Status: 'Completed', Criticality: 5 }).where({ ID: ID });
        
        return req.info(200,"Project Completed");
    });

    this.on('generateInvoice', async (req) => {

        const { ID } = req.params[0];
     
        const params = new URLSearchParams({
            date: '2024-06-17',
            number: 'IN001',
            from: 'LT',
            from_address: 'address',
            to: 'Amazon',
            ship_to: 'SshipAddress',
            name: 'USB',
            unit_cost: '50',
            quantity: '2',
            currency: 'INR',
            due_date: '2020-09-17',
            tax: '8',
            amount_paid: '10',
            locale: 'en-us',
            apiKey: process.env.API_KEY
        });

        const dest_conn = await cds.connect.to('invoice-generator');
        
        const response = await dest_conn.send({
            method: 'GET',
            path: `/generate?${params.toString()}`,
            headers: {
                Accept: 'application/pdf'
            }
        });

        const pdfBuffer = await new Promise((resolve, reject) => {
            const chunks = [];
            response.on('data', (chunk) => chunks.push(chunk));
            response.on('end', () => resolve(Buffer.concat(chunks)));
            response.on('error', (err) => reject(err));
    });
        const { ProjectCode } = await SELECT.one.from(projects).columns('ProjectCode').where({ ID : ID });
        
        await UPDATE(projects).set({ invoiceContent: pdfBuffer, invoiceName: `invoice-${ProjectCode}.pdf`,mediaType: 'application/pdf'}).where({ ID : ID})
        
        return { message: "Invoice Generated Successfully"};
    });

    this.on('getBudgetVariance', async (req) => {

        const { ID } = req.params[0];
    console.log(ID, req.user)

        let message = '';

        const project = await SELECT.one.from(projects).where({ ID: ID });

        if(!project) return req.error(404, "Project Not Found");   

        const totalLabourCost = await SELECT.one.from(actualCostPerProject).where({ ProjectID: ID });

        if(!totalLabourCost) {
            return req.error(400, "The Time Sheet is not Approved");
        }

        const totalProjectCost = parseFloat(project.InfrastructureCost) + parseFloat(project.LicenseCost) + parseFloat(totalLabourCost.TotalLabourCostPerWP);
        
        const BudgetVariance = parseFloat(project.Budget) - totalProjectCost;

        const VariancePercent = ((BudgetVariance / project.Budget) * 100).toFixed(2);

        await UPDATE(projects).set({ BudgetVariance: BudgetVariance }).where({ ID: ID });

        if (BudgetVariance > 0) {
            message = `The Project is Under Budget and Variance Percentage is ${VariancePercent}%`;

        } else if (BudgetVariance < 0) {
            message = `The Project is Over Budget and Variance Percentage is ${VariancePercent}%`;

        } else {
            message = 'The Project is exactly on Budget';
        }
        req.info(message);
        return await SELECT.one.from(projects).where({ ID });;
        
    })

})