CREATE TABLE [dbo].[CO_TipoHidrocarburo] (
    [IdTipoHidrocarburo] INT            IDENTITY (10000, 1) NOT NULL,
    [TipoHidrocarburo]   INT            NULL,
    [Hidrocarburo]       NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    CONSTRAINT [PK_TipoHidrocarburo] PRIMARY KEY CLUSTERED ([IdTipoHidrocarburo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

