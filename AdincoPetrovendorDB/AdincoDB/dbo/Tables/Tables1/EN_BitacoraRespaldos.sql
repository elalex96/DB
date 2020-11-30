CREATE TABLE [dbo].[EN_BitacoraRespaldos] (
    [IdBitacoraRespaldos] INT           IDENTITY (10000, 1) NOT NULL,
    [FechaInicio]         DATETIME      NULL,
    [FechaFin]            DATETIME      NULL,
    [Opcion]              VARCHAR (250) NULL,
    [CreadoPor]           INT           NULL,
    [CreadoEn]            DATETIME      NULL,
    [ModificadoPor]       INT           NULL,
    [ModificadoEn]        DATETIME      NULL,
    [Activo]              BIT           NULL,
    CONSTRAINT [PK_BitacoraRespaldos] PRIMARY KEY CLUSTERED ([IdBitacoraRespaldos] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreadoPorBitacoraRespaldos] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

