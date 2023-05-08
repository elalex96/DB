CREATE TABLE [dbo].[AP_ClasificacionMenu] (
    [idClasMenu]        INT          IDENTITY (1, 1) NOT NULL,
    [ClasificacionMenu] VARCHAR (50) NULL,
    [CreadoPor]         INT          NULL,
    [CreadoEl]          DATETIME     NULL,
    [ModificadoPor]     INT          NULL,
    [ModificadoEl]      DATETIME     NULL,
    [Activo]            BIT          NULL,
    PRIMARY KEY CLUSTERED ([idClasMenu] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

