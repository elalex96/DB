CREATE TABLE [dbo].[FI_CFDIMetodoPago] (
    [IdCFDIMetodoPago] INT            IDENTITY (1, 1) NOT NULL,
    [Clave]            NVARCHAR (MAX) NULL,
    [Concepto]         NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_FI_CFDIMetodoPago] PRIMARY KEY CLUSTERED ([IdCFDIMetodoPago] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

