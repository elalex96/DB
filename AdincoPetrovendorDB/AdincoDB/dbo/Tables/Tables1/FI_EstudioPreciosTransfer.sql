CREATE TABLE [dbo].[FI_EstudioPreciosTransfer] (
    [IdEstudioPrecioTransfer]  INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]               INT            NULL,
    [Nombre]                   NVARCHAR (MAX) NULL,
    [Descripcion]              NVARCHAR (MAX) NULL,
    [FolioOperacion]           NVARCHAR (50)  NULL,
    [IdDocFacturacionSIPAC]    NVARCHAR (50)  NULL,
    [ProcesadoSIPAC]           BIT            NULL,
    [FechaEstudio]             DATE           NULL,
    [FechaInicioVigencia]      DATE           NULL,
    [FechaFinVigencia]         DATE           NULL,
    [FechaCargaSIPAC]          DATE           NULL,
    [IdClasificacionDocumento] INT            NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEn]                 DATE           NULL,
    [Archivo]                  IMAGE          NULL,
    [IsEliminado]              BIT            NULL,
    [IdSubcontratista]         INT            NULL,
    [HashSHA256]               NVARCHAR (300) NULL,
    CONSTRAINT [PK_FI_EstudioPreciosTransfer] PRIMARY KEY CLUSTERED ([IdEstudioPrecioTransfer] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_EstudioPreciosTransfer_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

