CREATE TABLE [dbo].[PR_TipoSistemaMedicion] (
    [IdTipoSistema] INT           IDENTITY (100, 1) NOT NULL,
    [Descripcion]   VARCHAR (250) NULL,
    [Orden]         INT           NULL,
    [Activo]        BIT           NULL,
    CONSTRAINT [PK_PR_TipoSistemaMedicion] PRIMARY KEY CLUSTERED ([IdTipoSistema] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

