CREATE TABLE [dbo].[CO_Subcontrato] (
    [IdSubcontrato]    INT            IDENTITY (10000, 1) NOT NULL,
    [IdSubcontratista] INT            NULL,
    [IdContratante]    INT            NULL,
    [IdContrato]       INT            NULL,
    [FechaFirma]       DATE           NULL,
    [Numero]           NVARCHAR (MAX) NULL,
    [Objeto]           NVARCHAR (MAX) NULL,
    [InicioEjecucion]  NVARCHAR (MAX) NULL,
    [FinEjecucion]     NVARCHAR (MAX) NULL,
    [FechaFiniquito]   DATE           NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [Activo]           BIT            NULL,
    CONSTRAINT [PK_CO_Subcontrato] PRIMARY KEY CLUSTERED ([IdSubcontrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Subcontrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_Subcontrato_PV_Subcontratista] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista]),
    CONSTRAINT [FK_CO_Subcontrato_PV_SubcontratistaContratante] FOREIGN KEY ([IdContratante]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista])
);

