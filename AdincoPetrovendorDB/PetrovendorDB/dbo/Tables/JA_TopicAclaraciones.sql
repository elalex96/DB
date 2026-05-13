CREATE TABLE [dbo].[JA_TopicAclaraciones] (
    [Comentario]         NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    [FechaCreado]        SMALLDATETIME  NULL,
    [FechaHoraJunta]     DATETIME       NULL,
    [IdDomicilio]        INT            NULL,
    [IdOferta]           INT            NULL,
    [IdSolPed]           INT            NULL,
    [IdTopic]            INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedorCreador] INT            NULL,
    [IdContratoCreador]  INT            NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEl]       DATETIME       NULL
);

