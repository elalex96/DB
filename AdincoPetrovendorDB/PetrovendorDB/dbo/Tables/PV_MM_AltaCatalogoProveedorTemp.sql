CREATE TABLE [dbo].[PV_MM_AltaCatalogoProveedorTemp] (
    [CreadoPor]               INT            NULL,
    [DescripcionCorta]        NVARCHAR (MAX) NULL,
    [DescripcionLarga]        NVARCHAR (MAX) NULL,
    [EstatusAprobacion]       INT            NULL,
    [FechaRegistro]           DATETIME       NULL,
    [FichaTecnica]            NVARCHAR (MAX) NULL,
    [IdAltaCatalogoProveedor] INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]             INT            NULL,
    [IdSubFamilia]            INT            NULL,
    [IdSugerencia]            INT            NULL,
    [IdTipoCatalogo]          INT            NULL,
    [IdTipoMoneda]            INT            NULL,
    [ImagenMaterial]          NVARCHAR (MAX) NULL,
    [IsActivo]                BIT            NULL,
    [Precio]                  MONEY          NULL,
    [UMB]                     INT            NULL
);

