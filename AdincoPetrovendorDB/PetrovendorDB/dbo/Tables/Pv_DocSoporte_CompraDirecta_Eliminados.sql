CREATE TABLE [dbo].[Pv_DocSoporte_CompraDirecta_Eliminados] (
    [idEliminado]   INT            IDENTITY (1, 1) NOT NULL,
    [id]            INT            NOT NULL,
    [idFactura]     INT            NULL,
    [documento]     NVARCHAR (MAX) NULL,
    [nombreArchivo] NVARCHAR (MAX) NULL,
    [Carpeta]       NVARCHAR (300) NULL,
    [Identificador] NVARCHAR (300) NULL,
    [Extension]     NVARCHAR (300) NULL,
    [Mime]          NVARCHAR (300) NULL,
    [AMS3]          BIT            NULL,
    [EliminadoS3]   BIT            NULL,
    [isEliminado]   BIT            NULL,
    PRIMARY KEY CLUSTERED ([idEliminado] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

