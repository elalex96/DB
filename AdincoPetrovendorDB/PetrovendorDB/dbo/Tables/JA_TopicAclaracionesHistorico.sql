CREATE TABLE [dbo].[JA_TopicAclaracionesHistorico] (
    [Comentario]         NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    [FechaCreado]        SMALLDATETIME  NULL,
    [FechaHoraJunta]     DATETIME       NULL,
    [IdDomicilio]        INT            NULL,
    [IdOferta]           INT            NULL,
    [IdSolPed]           INT            NULL,
    [IdTopic]            INT            NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEl]       DATETIME       NULL,
    [IdProveedorCreador] INT            NULL,
    [IdContratoCreador]  INT            NULL
);

