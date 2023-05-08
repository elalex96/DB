CREATE TABLE [dbo].[EA_Adinco] (
    [IdEquiposAdinco] INT           IDENTITY (10000, 1) NOT NULL,
    [NombreEquipo]    VARCHAR (50)  NULL,
    [Caracteristicas] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_EA_Adinco] PRIMARY KEY CLUSTERED ([IdEquiposAdinco] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

