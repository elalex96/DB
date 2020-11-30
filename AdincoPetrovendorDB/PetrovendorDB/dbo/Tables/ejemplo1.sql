CREATE TABLE [dbo].[ejemplo1] (
    [IdDocumento]               INT            IDENTITY (1, 1) NOT NULL,
    [IdTipoDocumento]           INT            NULL,
    [IdUsuario]                 INT            NULL,
    [IdTipoValidacionDocumento] INT            NULL,
    [IdProveedor]               INT            NULL,
    [Activo]                    BIT            NULL,
    [Documento]                 NVARCHAR (MAX) NOT NULL,
    [CreadoPor]                 INT            NULL,
    [CreadoEl]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEl]              DATETIME       NULL,
    [Descripcion]               NVARCHAR (MAX) NULL
);

