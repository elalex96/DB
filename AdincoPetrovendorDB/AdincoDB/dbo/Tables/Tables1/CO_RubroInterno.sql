CREATE TABLE [dbo].[CO_RubroInterno] (
    [IdRubroInterno] INT            IDENTITY (10000, 1) NOT NULL,
    [NombreRubro]    NVARCHAR (MAX) NULL,
    [Clave]          NVARCHAR (MAX) NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_RubrosInternos] PRIMARY KEY CLUSTERED ([IdRubroInterno] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

