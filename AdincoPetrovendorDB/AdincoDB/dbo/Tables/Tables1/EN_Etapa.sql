CREATE TABLE [dbo].[EN_Etapa] (
    [IdEtapa] INT            IDENTITY (1, 1) NOT NULL,
    [Etapa]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_EN_Etapa] PRIMARY KEY CLUSTERED ([IdEtapa] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

go

create index IX_EN_Etapa				on	EN_Etapa(IdEtapa)