CREATE TABLE [dbo].[FI_AprobacionFactura] (
    [IdAprobacionFactura] INT IDENTITY (1, 1) NOT NULL,
    [IdFactura]           INT NULL,
    [IdContrato]          INT NULL,
    [IdUsuarioAprobador]  INT NULL,
    [IdEstatus]           INT NULL,
    CONSTRAINT [PK_FI_AprobacionFactura] PRIMARY KEY CLUSTERED ([IdAprobacionFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

