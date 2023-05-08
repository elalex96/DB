CREATE TABLE [dbo].[PV_ClasificacionEmpresa] (
    [ClasificacionID] INT           IDENTITY (1, 1) NOT NULL,
    [Clasificacion]   VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_Cat_ClasificacionEmpresa] PRIMARY KEY CLUSTERED ([ClasificacionID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

