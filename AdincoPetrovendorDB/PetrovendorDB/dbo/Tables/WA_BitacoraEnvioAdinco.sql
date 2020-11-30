CREATE TABLE [dbo].[WA_BitacoraEnvioAdinco] (
    [IdRegistroEnvioAdinco] INT            IDENTITY (1, 1) NOT NULL,
    [IdDocumento]           INT            NULL,
    [IdTipoEnvio]           INT            NULL,
    [FechaEnvio]            DATETIME       NULL,
    [IdDocumentoAdinco]     INT            NULL,
    [IdUsuario]             INT            NULL,
    [IdProveedor]           INT            NULL,
    [IdContrato]            INT            NULL,
    [WSMensaje]             NVARCHAR (MAX) NULL,
    [IsError]               BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdRegistroEnvioAdinco] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

