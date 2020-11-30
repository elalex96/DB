CREATE TABLE [dbo].[EN_InstanciasBitacoraRespaldos] (
    [IdInstanciasBitacoraRespaldos] INT IDENTITY (10000, 1) NOT NULL,
    [IdBitacoraRespaldos]           INT NULL,
    [IdInstanciaEntregable]         INT NULL,
    [Activo]                        BIT NULL,
    CONSTRAINT [PK_InstanciasBitacoraRespaldos] PRIMARY KEY CLUSTERED ([IdInstanciasBitacoraRespaldos] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_BitacoraRespaldos] FOREIGN KEY ([IdBitacoraRespaldos]) REFERENCES [dbo].[EN_BitacoraRespaldos] ([IdBitacoraRespaldos]),
    CONSTRAINT [FK_InstanciaEntregableRespaldos] FOREIGN KEY ([IdInstanciaEntregable]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable])
);

