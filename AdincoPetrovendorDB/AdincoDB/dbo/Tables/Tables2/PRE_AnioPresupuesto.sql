CREATE TABLE [dbo].[PRE_AnioPresupuesto] (
    [IdAnio]      INT           NOT NULL,
    [Descripcion] VARCHAR (500) NULL,
    CONSTRAINT [PK_PRE_AnioPresupuesto] PRIMARY KEY CLUSTERED ([IdAnio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

