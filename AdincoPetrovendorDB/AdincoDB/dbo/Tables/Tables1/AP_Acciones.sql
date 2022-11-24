CREATE TABLE [dbo].[AP_Acciones] (
    [IdAccion]    TINYINT      NOT NULL,
    [Descripcion] VARCHAR (50) NOT NULL,
    [CreadoEl]    DATETIME     NOT NULL,
    CONSTRAINT [PK_AP_Acciones] PRIMARY KEY CLUSTERED ([IdAccion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

