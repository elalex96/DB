CREATE TABLE [dbo].[EN_ReceptorEntregable] (
    [IdReceptorEntregable] INT            IDENTITY (10000, 1) NOT NULL,
    [ReceptorEntregable]   VARCHAR (3000) NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEn]             DATETIME       NULL,
    CONSTRAINT [PK_EN_ReceptorEntregable] PRIMARY KEY CLUSTERED ([IdReceptorEntregable] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

go

create index IX_EN_ReceptorEntregable	on	EN_ReceptorEntregable(IdReceptorEntregable)