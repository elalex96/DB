CREATE TABLE [dbo].[MA_ServidorDeCorreo] (
    [IdServidor]     INT            IDENTITY (1, 1) NOT NULL,
    [CuentaRegistro] NVARCHAR (MAX) NULL,
    [Contrasena]     NVARCHAR (MAX) NULL,
    [SMTP]           NVARCHAR (MAX) NULL,
    [Puerto]         INT            NULL,
    [BBC]            NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_MA_ServidorDeCorreo] PRIMARY KEY CLUSTERED ([IdServidor] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

