CREATE TABLE [dbo].[CO_Marcador] (
    [IdMarcador]       INT            IDENTITY (10000, 1) NOT NULL,
    [MarcadorCorto]    NVARCHAR (MAX) NULL,
    [Marcador]         NVARCHAR (MAX) NULL,
    [TipoHidrocarburo] INT            NULL,
    CONSTRAINT [PK_CO_Marcadores] PRIMARY KEY CLUSTERED ([IdMarcador] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

