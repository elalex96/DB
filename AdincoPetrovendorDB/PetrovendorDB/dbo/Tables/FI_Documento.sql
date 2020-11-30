CREATE TABLE [dbo].[FI_Documento] (
    [IdDocumento]            INT            IDENTITY (1, 1) NOT NULL,
    [Documento]              NVARCHAR (MAX) NULL,
    [IdTipoDocumento]        INT            NOT NULL,
    [IdFactura]              INT            NULL,
    [IdPedimentoComprobante] INT            NULL,
    [IdDocFacturacionSIPAC]  NVARCHAR (50)  NULL,
    [NombreExtensionArchivo] NVARCHAR (150) NULL,
    [IdUsuario]              INT            NULL,
    [FechaCarga]             DATETIME       NULL,
    [IsEliminado]            BIT            NULL,
    [DocumentoByte]          IMAGE          NULL,
    CONSTRAINT [PK_FI_Documento] PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_Documento_FI_TipoDocumento] FOREIGN KEY ([IdTipoDocumento]) REFERENCES [dbo].[FI_TipoDocumento] ([id_TipoDocumento])
);

