CREATE TABLE [dbo].[TA_Correo] (
    [IdCorreo]    INT            IDENTITY (1, 1) NOT NULL,
    [HTML]        NVARCHAR (MAX) NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [Asunto]      NVARCHAR (MAX) NULL,
    [IdServidor]  INT            NOT NULL,
    CONSTRAINT [PK_TA_Correo] PRIMARY KEY CLUSTERED ([IdCorreo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_Correo_TA_CorreoServidor] FOREIGN KEY ([IdServidor]) REFERENCES [dbo].[TA_CorreoServidor] ([IdServidor])
);

