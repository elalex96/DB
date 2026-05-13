CREATE TABLE [dbo].[EMP_SolicitudDescargaArchivos] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [FechaInicio]    DATE            NULL,
    [FechaFin]       DATE            NULL,
    [TipoSolicitud]  VARCHAR (100)   NULL,
    [UsuarioId]      INT             NOT NULL,
    [ContratoId]     INT             NOT NULL,
    [FechaSolicitud] DATETIME        NOT NULL,
    [FechaProcesado] DATETIME        NULL,
    [Procesado]      BIT             NOT NULL,
    [UUIDAmazon]     NVARCHAR (2000) NULL,
    [Carpeta]        NVARCHAR (200)  NULL,
    [NombreArchivo]  VARCHAR (200)   NULL,
    [Size]           FLOAT (53)      NULL,
    [Meta]           NVARCHAR (200)  NULL,
    CONSTRAINT [PK_EMP_SolicitudDescargaArchivos] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_EMP_SolicitudDescargaArchivos_AP_Usuario] FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EMP_SolicitudDescargaArchivos_CO_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

