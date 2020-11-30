CREATE TABLE [dbo].[MPY_Approved_SES] (
    [IDSESMPY]             INT            IDENTITY (1, 1) NOT NULL,
    [SESNumber]            NVARCHAR (MAX) NULL,
    [SESLine]              NVARCHAR (MAX) NULL,
    [POSAPNumber]          NVARCHAR (MAX) NULL,
    [POLineNumber]         NVARCHAR (MAX) NULL,
    [Quantity]             NVARCHAR (MAX) NULL,
    [UnitPrice]            NVARCHAR (MAX) NULL,
    [Currency]             NVARCHAR (MAX) NULL,
    [UnitPricePerQuantity] NVARCHAR (MAX) NULL,
    [AccountAssignment]    NVARCHAR (MAX) NULL,
    [CostObject]           NVARCHAR (MAX) NULL,
    [MaterialGroup]        NVARCHAR (MAX) NULL,
    [MaterialgroupDesc2]   NVARCHAR (MAX) NULL,
    [IdDocuemnto]          INT            NULL,
    [UOM]                  VARCHAR (50)   NULL,
    CONSTRAINT [PK_MPY_Approved_SES] PRIMARY KEY CLUSTERED ([IDSESMPY] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

