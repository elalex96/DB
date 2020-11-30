CREATE TABLE [dbo].[CO_TipoFluido] (
    [IdTipoFluido]     INT            IDENTITY (1, 1) NOT NULL,
    [ID_TIPOFLUIDO]    INT            NOT NULL,
    [NombreTipoFluido] NVARCHAR (MAX) NOT NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_TipoFluido] PRIMARY KEY CLUSTERED ([IdTipoFluido] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

