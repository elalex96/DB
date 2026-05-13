CREATE TABLE [dbo].[PV_SistemaGestion] (
    [IdSistemaGestion]            INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]                 NVARCHAR (MAX) NULL,
    [IdTipoDocSG]                 INT            NULL,
    [Documento]                   NVARCHAR (MAX) NULL,
    [Activo]                      BIT            NULL,
    [NombreCertificacion]         NVARCHAR (50)  NULL,
    [CasaCertificadora]           NVARCHAR (200) NULL,
    [FechaEmisionCertificado]     DATETIME       NULL,
    [FechaVigenciaInicio]         DATETIME       NULL,
    [FechaVigenciaTermino]        DATETIME       NULL,
    [MetodosProcesosCertificados] NVARCHAR (500) NULL,
    [NoDeCertificado]             NVARCHAR (MAX) NULL,
    [Carpeta]                     NVARCHAR (300) NULL,
    [Identificador]               NVARCHAR (300) NULL,
    [Extension]                   NVARCHAR (300) NULL,
    [Mime]                        NVARCHAR (300) NULL,
    [AMS3]                        BIT            NULL,
    [Bucket]                      VARCHAR (50)   NULL,
    CONSTRAINT [PK_PV_SistemaGestion] PRIMARY KEY CLUSTERED ([IdSistemaGestion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

