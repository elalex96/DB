CREATE TABLE [dbo].[OF_OficioRelacion] (
    [IdOficioRelacion]        INT IDENTITY (1, 1) NOT NULL,
    [IdDocumentoOficio]       INT NOT NULL,
    [IdDocumentoOficioParent] INT NOT NULL,
    CONSTRAINT [PK_OF_OficioRelacion] PRIMARY KEY CLUSTERED ([IdOficioRelacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

