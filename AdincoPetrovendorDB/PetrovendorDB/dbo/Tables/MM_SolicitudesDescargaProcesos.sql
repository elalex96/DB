CREATE TABLE [dbo].[MM_SolicitudesDescargaProcesos] (
    [IdSolicitud]             INT             IDENTITY (1, 1) NOT NULL,
    [Tipo]                    NVARCHAR (50)   NULL,
    [FechaInicio]             DATE            NULL,
    [FechaFin]                DATE            NULL,
    [IdContrato]              INT             NULL,
    [FechaRegistroSolicitud]  DATETIME        NULL,
    [FechaFinalProcesamiento] DATETIME        NULL,
    [Bucket]                  NVARCHAR (1000) NULL,
    [Folder]                  NVARCHAR (1000) NULL,
    [UUIDAmazon]              NVARCHAR (1000) NULL,
    [NombreArchivo]           NVARCHAR (1000) NULL,
    [Size]                    FLOAT (53)      NULL,
    [Meta]                    NVARCHAR (1000) NULL,
    [Procesado]               BIT             NULL,
    [IdUsuarioSolicitante]    INT             NULL,
    CONSTRAINT [PK_MM_SolicitudesDescargaProcesos] PRIMARY KEY CLUSTERED ([IdSolicitud] ASC)
);

