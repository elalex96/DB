CREATE TABLE [dbo].[JA_Documento] (
    [CreadoPor]     INT            NULL,
    [Documento]     NVARCHAR (MAX) NULL,
    [Extension]     NVARCHAR (150) NULL,
    [FechaCreado]   SMALLDATETIME  NULL,
    [IdDocumento]   INT            IDENTITY (1, 1) NOT NULL,
    [IdTopic]       INT            NULL,
    [NombreArchivo] NVARCHAR (MAX) NULL
);

