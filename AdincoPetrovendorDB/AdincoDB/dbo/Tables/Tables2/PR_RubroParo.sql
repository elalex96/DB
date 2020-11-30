CREATE TABLE [dbo].[PR_RubroParo] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [Clave]          VARCHAR (20)    NOT NULL,
    [Subclave]       VARCHAR (20)    NOT NULL,
    [ClaveCompuesta] VARCHAR (20)    NOT NULL,
    [Rubros]         VARCHAR (200)   NOT NULL,
    [Tipo]           VARCHAR (200)   NOT NULL,
    [Causa]          NVARCHAR (2000) NOT NULL,
    CONSTRAINT [PK_PR_RubroParo] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

