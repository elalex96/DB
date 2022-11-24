CREATE TABLE [dbo].[JA_ComentarioBase] (
    [IdComentarioBase] INT            IDENTITY (1, 1) NOT NULL,
    [Comentario]       NVARCHAR (MAX) NULL,
    [IdUsuario]        INT            NULL,
    [IdPerfil]         INT            NULL,
    [IdTopic]          INT            NULL,
    [FechaCreado]      DATETIME       NULL,
    [IdSolPed]         INT            NULL,
    [Visto]            BIT            NULL,
    [IdProveedor]      INT            NULL,
    [IdContrato]       INT            NULL,
    PRIMARY KEY CLUSTERED ([IdComentarioBase] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

