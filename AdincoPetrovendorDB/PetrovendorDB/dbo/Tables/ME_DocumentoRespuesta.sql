CREATE TABLE [dbo].[ME_DocumentoRespuesta] (
    [IdDocumentoRespuesta] INT            IDENTITY (1, 1) NOT NULL,
    [IdRespuesta]          INT            NOT NULL,
    [Nombre]               VARCHAR (MAX)  NOT NULL,
    [Documento]            NVARCHAR (MAX) NOT NULL,
    [IdPedido]             INT            NULL,
    CONSTRAINT [PK_ME_DocumentoRespuesta] PRIMARY KEY CLUSTERED ([IdDocumentoRespuesta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_DocumentoRespuesta_ME_Respuestas] FOREIGN KEY ([IdRespuesta]) REFERENCES [dbo].[ME_Respuestas] ([IdRespuestas])
);

