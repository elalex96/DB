CREATE TABLE [dbo].[Carso_Comparativa_Destinatarios] (
    [id]            INT      IDENTITY (1, 1) NOT NULL,
    [Idusuario]     INT      NULL,
    [Activo]        BIT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoEl]  DATETIME NULL,
    [CreadoPor]     INT      NULL,
    [ModificadoPor] INT      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

