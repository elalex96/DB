CREATE TABLE [dbo].[AP_Permiso] (
    [IdPermiso]        INT           NOT NULL,
    [NombrePermiso]    VARCHAR (250) NULL,
    [BitActivo]        BIT           NULL,
    [FirmaObligatoria] BIT           NULL,
    CONSTRAINT [PK_AP_Permiso] PRIMARY KEY CLUSTERED ([IdPermiso] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

