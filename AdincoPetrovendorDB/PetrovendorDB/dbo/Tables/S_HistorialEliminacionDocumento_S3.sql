CREATE TABLE [dbo].[S_HistorialEliminacionDocumento_S3] (
    [IdHistorialDocumento] INT      IDENTITY (1, 1) NOT NULL,
    [IdDocumento]          INT      NULL,
    [IdProveedor]          INT      NULL,
    [EliminadoPor]         INT      NULL,
    [EliminadoEl]          DATETIME NULL,
    CONSTRAINT [PK_S_HistorialEliminacionDocumento_S3] PRIMARY KEY CLUSTERED ([IdHistorialDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

