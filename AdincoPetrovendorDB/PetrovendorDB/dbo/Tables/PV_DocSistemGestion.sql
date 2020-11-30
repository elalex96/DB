CREATE TABLE [dbo].[PV_DocSistemGestion] (
    [IdDocSistemaGestion] INT            IDENTITY (1, 1) NOT NULL,
    [DocSistemaGestion]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PV_DocSistemGestion] PRIMARY KEY CLUSTERED ([IdDocSistemaGestion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

