CREATE TABLE [dbo].[PC_EquivalenciaPuntoVenta] (
    [IdEPV]                    INT            IDENTITY (1, 1) NOT NULL,
    [Nombre 1]                 NVARCHAR (255) NULL,
    [Denominación]             NVARCHAR (255) NULL,
    [IdPtoExpedicionRecepcion] INT            NULL,
    [PuntoVentaA]              VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_PC_EquivalenciaPuntoVenta] PRIMARY KEY CLUSTERED ([IdEPV] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

