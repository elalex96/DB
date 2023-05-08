CREATE TABLE [dbo].[JA_ComentariosBasesConvocatoria] (
    [Comentario]         NVARCHAR (MAX) NULL,
    [FechaCreado]        DATETIME       NULL,
    [IdComentarioBases]  INT            IDENTITY (1, 1) NOT NULL,
    [IdEncabezado]       INT            NULL,
    [IdPerfil]           INT            NULL,
    [IdUsuario]          INT            NULL,
    [IdProveedorCreador] INT            NULL,
    [IdContratoCreador]  INT            NULL
);

