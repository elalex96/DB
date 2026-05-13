CREATE TABLE [dbo].[TA_Correo] (
    [IdCorreo]           INT            IDENTITY (1, 1) NOT NULL,
    [HTML]               NVARCHAR (MAX) NULL,
    [Descripcion]        NVARCHAR (MAX) NULL,
    [Asunto]             NVARCHAR (MAX) NULL,
    [IdServidor]         INT            NOT NULL,
    [DescripcionCliente] NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEl]           DATETIME       NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEl]       DATETIME       NULL,
    CONSTRAINT [PK_TA_Correo]
    CONSTRAINT [FK_TA_Correo_TA_CorreoServidor] FOREIGN KEY ([IdServidor]) REFERENCES [dbo].[TA_CorreoServidor] ([IdServidor])
);

