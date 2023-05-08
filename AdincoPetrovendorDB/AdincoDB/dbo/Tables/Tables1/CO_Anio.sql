CREATE TABLE [dbo].[CO_Anio] (
    [idAnio]    INT           IDENTITY (1, 1) NOT NULL,
    [Anio]      VARCHAR (MAX) NOT NULL,
    [Activo]    BIT           NOT NULL,
    [CreadoPor] INT           NULL,
    CONSTRAINT [PK_CO_Anio] PRIMARY KEY CLUSTERED ([idAnio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

