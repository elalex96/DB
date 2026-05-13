CREATE TABLE [dbo].[CO_TipoProgramaActividad] (
    [IdTipoProgramaActividad] INT            IDENTITY (10000, 1) NOT NULL,
    [TipoPrograma]            NVARCHAR (MAX) NULL,
    [Activo]                  BIT            NULL,
    [CreadoPor]               INT            NULL,
    [CreadoEn]                DATETIME       NULL,
    [ModificadoPor]           INT            NULL,
    [ModificadoEn]            DATETIME       NULL,
    CONSTRAINT [PK_CO_TipoProgramaActividad] PRIMARY KEY CLUSTERED ([IdTipoProgramaActividad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

