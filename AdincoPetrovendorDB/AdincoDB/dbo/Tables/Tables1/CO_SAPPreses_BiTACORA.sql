CREATE TABLE [dbo].[CO_SAPPreses_BiTACORA] (
    [Id]                INT           NOT NULL,
    [IdPRESES]          INT           NULL,
    [CreadoPor]         INT           NULL,
    [IdEstatus]         INT           NULL,
    [CreadoEl]          DATE          NULL,
    [ComentarioInterno] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_CO_SAPPreses_BiTACORA] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPPreses_BiTACORA_CO_SAPPreses] FOREIGN KEY ([IdPRESES]) REFERENCES [dbo].[CO_SAPPRESES] ([IdPRESES])
);

