CREATE TABLE [dbo].[AP_BitacoraProcesadoSolicitudArchivos] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [Mensaje]       NVARCHAR (1000) NULL,
    [Detalle]       NVARCHAR (2000) NULL,
    [IdUsuario]     INT             NULL,
    [IdContrato]    INT             NULL,
    [FechaRegistro] DATETIME        NULL,
    [GeneradoDesde] VARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

