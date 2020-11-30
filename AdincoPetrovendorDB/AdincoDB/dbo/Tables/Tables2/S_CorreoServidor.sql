CREATE TABLE [dbo].[S_CorreoServidor] (
    [IdCorreoServidor] INT            IDENTITY (1, 1) NOT NULL,
    [CuentaRegistro]   NVARCHAR (MAX) NULL,
    [Contrasena]       NVARCHAR (MAX) NULL,
    [SMTP]             NVARCHAR (MAX) NULL,
    [Puerto]           INT            NULL,
    [BBC]              NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_S_CorreoServidor] PRIMARY KEY CLUSTERED ([IdCorreoServidor] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

