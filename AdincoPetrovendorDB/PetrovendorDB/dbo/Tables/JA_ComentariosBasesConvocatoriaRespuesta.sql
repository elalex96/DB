CREATE TABLE [dbo].[JA_ComentariosBasesConvocatoriaRespuesta] (
    [FechaCreado]        DATETIME       NULL,
    [IdEncabezado]       INT            NULL,
    [IdPerfil]           INT            NULL,
    [IdRespuesta]        INT            IDENTITY (1, 1) NOT NULL,
    [Idusuario]          INT            NULL,
    [Respuesta]          NVARCHAR (MAX) NULL,
    [IdProveedorCreador] INT            NULL,
    [IdContratoCreador]  INT            NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEl]       DATETIME       NULL
);

