CREATE TABLE [dbo].[AP_BitacoraLogin] (
    [IdBitacoraLogin]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [IpAddress]         NVARCHAR (50)  NULL,
    [HostName]          NVARCHAR (MAX) NULL,
    [SistemaOperativo]  NVARCHAR (100) NULL,
    [Browser]           NVARCHAR (50)  NULL,
    [VersionBrowser]    NVARCHAR (50)  NULL,
    [FechaIngreso]      DATETIME       NULL,
    [FechaFinalizacion] DATETIME       NULL,
    [IdUsuario]         INT            NULL,
    [Aplicacion]        TINYINT        NULL,
    [TipoUsuarioID]     INT            NULL,
    PRIMARY KEY CLUSTERED ([IdBitacoraLogin] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

