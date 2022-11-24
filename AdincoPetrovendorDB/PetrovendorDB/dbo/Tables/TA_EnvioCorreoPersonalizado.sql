CREATE TABLE [dbo].[TA_EnvioCorreoPersonalizado] (
    [IdEnvioCorreo]      INT           IDENTITY (1000, 1) NOT NULL,
    [Correo]             VARCHAR (200) NULL,
    [NombreDestinatario] VARCHAR (100) NULL,
    [IdUsuario]          INT           NULL,
    [IdProveedor]        INT           NULL,
    [IdContrato]         INT           NULL,
    [TipoNotificacion]   NVARCHAR (50) NULL,
    [Activo]             BIT           NULL,
    [CreadoEl]           DATETIME      NULL,
    CONSTRAINT [PK_TA_EnvioCorreoPersonalizado] PRIMARY KEY CLUSTERED ([IdEnvioCorreo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

