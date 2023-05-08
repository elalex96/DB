CREATE TABLE [dbo].[EN_PorcentajeProgresoOpciones] (
    [Clave]       VARCHAR (100) NULL,
    [NombreClave] VARCHAR (MAX) NULL,
    [Porcentaje]  FLOAT (53)    NULL,
    UNIQUE NONCLUSTERED ([Clave] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

