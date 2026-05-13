CREATE TABLE [dbo].[MA_WS_BitacoraErrores] (
    [IdError]          INT            IDENTITY (1, 1) NOT NULL,
    [HResult]          INT            NULL,
    [Mensaje]          NVARCHAR (MAX) COLLATE Modern_Spanish_CI_AS NULL,
    [StackTrace]       NVARCHAR (MAX) COLLATE Modern_Spanish_CI_AS NULL,
    [IdUsuario]        INT            NULL,
    [IdSubcontratista] INT            NULL,
    [IdContrato]       INT            NULL,
    [FechaRegistro]    DATETIME       NULL
);

