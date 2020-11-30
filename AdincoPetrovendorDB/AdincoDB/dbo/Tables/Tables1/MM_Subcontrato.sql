CREATE TABLE [dbo].[MM_Subcontrato] (
    [IdSubcontrato]               INT            IDENTITY (10000, 1) NOT NULL,
    [IdContratista]               INT            NULL,
    [IdContrato]                  INT            NULL,
    [IdSubcontratista]            INT            NULL,
    [IdSubcontratistaContratista] INT            NULL,
    [NombreContrato]              NVARCHAR (MAX) NULL,
    [Numero]                      NVARCHAR (MAX) NULL,
    [Fecha]                       DATE           NULL,
    [Termina]                     DATE           NULL,
    [CreadoPor]                   INT            NULL,
    [CreadoEl]                    DATETIME       NULL,
    [ModificadoPor]               INT            NULL,
    [ModificadoEl]                DATETIME       NULL,
    [Activo]                      BIT            NULL,
    CONSTRAINT [PK_MM_Subcontrato] PRIMARY KEY CLUSTERED ([IdSubcontrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

