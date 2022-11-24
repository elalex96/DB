CREATE TABLE [dbo].[COM_PuntoVentaHidrocarburos] (
    [IdPuntoVentaHidrocarburos] INT            IDENTITY (10000, 1) NOT NULL,
    [Clave]                     NVARCHAR (MAX) NULL,
    [NombrePuntoVenta]          NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_COM_PuntoVentaHidrocarburos] PRIMARY KEY CLUSTERED ([IdPuntoVentaHidrocarburos] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

