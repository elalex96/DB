CREATE TABLE [dbo].[MM_TipoContrato] (
    [IdTipoContrato] INT            IDENTITY (10000, 1) NOT NULL,
    [TipoContrato]   NVARCHAR (MAX) NULL,
    [Descripcion]    NVARCHAR (MAX) NULL,
    [ContractType]   NVARCHAR (MAX) NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [Activo]         BIT            NULL,
    CONSTRAINT [PK_MM_TipoContrato] PRIMARY KEY CLUSTERED ([IdTipoContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

