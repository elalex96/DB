CREATE TABLE [dbo].[DEA_CuotaPatronalDetalle] (
    [IdCuotaPatronal]  INT             NULL,
    [LineItem]         NVARCHAR (200)  NULL,
    [GLAccount]        NVARCHAR (200)  NULL,
    [PostingKey]       NVARCHAR (500)  NULL,
    [AccountShortText] NVARCHAR (500)  NULL,
    [Amount]           NVARCHAR (100)  NULL,
    [Currency]         NVARCHAR (100)  NULL,
    [Text]             NVARCHAR (1000) NULL,
    [WBS]              NVARCHAR (200)  NULL,
    [CC]               NVARCHAR (100)  NULL,
    [BusinessArea]     NVARCHAR (100)  NULL,
    [TaxCode]          NVARCHAR (500)  NULL,
    [RI]               NVARCHAR (100)  NULL,
    [USD]              NVARCHAR (500)  NULL,
    [EUR]              NVARCHAR (500)  NULL,
    [MXN]              NVARCHAR (500)  NULL,
    FOREIGN KEY ([IdCuotaPatronal]) REFERENCES [dbo].[DEA_CuotaPatronal] ([IdCuotaPatronal])
);

