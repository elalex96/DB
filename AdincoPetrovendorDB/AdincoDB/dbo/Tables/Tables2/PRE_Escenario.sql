CREATE TABLE [dbo].[PRE_Escenario] (
    [IdEscenario] INT            NOT NULL,
    [Descripcion] VARCHAR (1500) NULL,
    CONSTRAINT [PK_PRE_Escenario] PRIMARY KEY CLUSTERED ([IdEscenario] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

