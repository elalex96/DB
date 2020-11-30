CREATE TABLE [dbo].[PR_FI_Documento] (
    [IdDocumento]            INT            NOT NULL,
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
    [IdEliminacion]          INT            NULL,
    [IdReciclaje]            INT            IDENTITY (1, 1) NOT NULL
);

