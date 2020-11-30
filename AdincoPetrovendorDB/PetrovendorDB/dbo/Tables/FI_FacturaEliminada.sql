CREATE TABLE [dbo].[FI_FacturaEliminada] (
    [IdFacturaEliminada] INT            IDENTITY (1, 1) NOT NULL,
    [IdFactura]          INT            NULL,
    [FechaEliminada]     DATETIME       NULL,
    [EliminadaPor]       INT            NULL,
    [UUID]               NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_FI_FacturaEliminada] PRIMARY KEY CLUSTERED ([IdFacturaEliminada] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

