CREATE TABLE [dbo].[TA_BitacoraCorreo] (
    [IdEnvioCorreo]     INT            IDENTITY (1, 1) NOT NULL,
    [IdDocumento]       INT            NULL,
    [Detalle]           NVARCHAR (MAX) NULL,
    [Correo]            NVARCHAR (350) NULL,
    [Enviado]           BIT            NULL,
    [FechaEnvio]        DATETIME       NULL,
    [IdUsuarioEnvio]    INT            NULL,
    [IdProveedorEnvio]  INT            NULL,
    [IdUsuarioReceptor] INT            NULL,
    CONSTRAINT [PK_TA_BitacoraCorreo] PRIMARY KEY CLUSTERED ([IdEnvioCorreo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

