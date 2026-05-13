CREATE TABLE [dbo].[EN_DestinatarioOficioEntidadContrato] (
    [idDestinatarioEntidadContrato] INT IDENTITY (10000, 1) NOT NULL,
    [idDestinatarioEntidad]         INT NULL,
    [idEntidad]                     INT NULL,
    [idContrato]                    INT NULL,
    CONSTRAINT [PK__EN_Desti__5338DE233A812BB2] PRIMARY KEY CLUSTERED ([idDestinatarioEntidadContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

