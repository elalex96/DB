CREATE TABLE [dbo].[PV_TipoCompra] (
    [IdTipoCompra] INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipo]   NVARCHAR (MAX) NULL,
    [Activo]       BIT            NULL,
    [CreadoEl]     DATETIME       NULL,
    [CreadorPor]   INT            NULL,
    [Descripcion]  NVARCHAR (MAX) NULL
);

