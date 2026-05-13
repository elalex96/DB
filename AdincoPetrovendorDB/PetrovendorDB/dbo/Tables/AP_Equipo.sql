CREATE TABLE [dbo].[AP_Equipo] (
    [IdEquipo]     INT           IDENTITY (1, 1) NOT NULL,
    [IP]           VARCHAR (50)  NULL,
    [SOEquipo]     VARCHAR (50)  NULL,
    [Ubicacion]    VARCHAR (200) NULL,
    [NombreEquipo] VARCHAR (50)  NULL,
    CONSTRAINT [PK_AP_Equipo] PRIMARY KEY CLUSTERED ([IdEquipo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

