CREATE TABLE [dbo].[CAT_FlujosDetalle] (
    [IdFlujoDetalle] INT          NOT NULL,
    [IdFlujo]        INT          NULL,
    [Descripcion]    VARCHAR (50) NULL,
    [Orden]          INT          NULL,
    [Activo]         BIT          NULL,
    CONSTRAINT [PK_CAT_FlujosDetalle] PRIMARY KEY CLUSTERED ([IdFlujoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

