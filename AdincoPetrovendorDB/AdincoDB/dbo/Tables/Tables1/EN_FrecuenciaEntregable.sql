CREATE TABLE [dbo].[EN_FrecuenciaEntregable] (
    [IdFrecuenciaEntregable] INT            IDENTITY (10000, 1) NOT NULL,
    [FrecuenciaEntregable]   NVARCHAR (MAX) NULL,
    [FrecuenciaIngles]       VARCHAR (3000) NULL,
    CONSTRAINT [PK_EN_FrecuenciaEntregable] PRIMARY KEY CLUSTERED ([IdFrecuenciaEntregable] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

go

create index IX_EN_FrecuenciaEntregable	on	EN_FrecuenciaEntregable(IdFrecuenciaEntregable)
