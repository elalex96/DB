CREATE TABLE [dbo].[FI_CFDIRelacionados] (
    [IdCFdiRelacionado] INT            IDENTITY (10000, 1) NOT NULL,
    [CFDIId]            INT            NULL,
    [TipoRelacion]      VARCHAR (50)   NULL,
    [UUID]              NVARCHAR (MAX) NULL,
    [NoParcialidad]     INT            NULL,
    [idContrato]        INT            NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEl]          DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEl]      DATETIME       NULL,
    [Activo]            BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdCFdiRelacionado] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([CFDIId]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

