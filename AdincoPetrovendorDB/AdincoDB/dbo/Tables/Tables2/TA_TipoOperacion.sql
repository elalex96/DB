CREATE TABLE [dbo].[TA_TipoOperacion] (
    [IdTipoOperacion] INT            IDENTITY (1, 1) NOT NULL,
    [NombreOperacion] NVARCHAR (300) NULL,
    CONSTRAINT [PK_TATipoOperacion] PRIMARY KEY CLUSTERED ([IdTipoOperacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

