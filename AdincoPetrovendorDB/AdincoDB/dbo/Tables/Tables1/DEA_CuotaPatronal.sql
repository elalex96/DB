CREATE TABLE [dbo].[DEA_CuotaPatronal] (
    [IdCuotaPatronal]        INT            IDENTITY (1, 1) NOT NULL,
    [DocType]                NVARCHAR (500) NULL,
    [Reverse]                NVARCHAR (100) NULL,
    [Reclass]                NVARCHAR (100) NULL,
    [RefDoc]                 NVARCHAR (500) NULL,
    [DocCurrency]            NVARCHAR (100) NULL,
    [Concept]                NVARCHAR (500) NULL,
    [CompanyCode]            NVARCHAR (100) NULL,
    [PostingDate]            NVARCHAR (100) NULL,
    [RequestedBy]            NVARCHAR (200) NULL,
    [FiscalYear]             NVARCHAR (100) NULL,
    [Period]                 NVARCHAR (100) NULL,
    [NombreArchivoImportado] NVARCHAR (200) NULL,
    [IdUsuario]              INT            NULL,
    [IdContrato]             INT            NULL,
    [FechaRegistro]          DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([IdCuotaPatronal] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

