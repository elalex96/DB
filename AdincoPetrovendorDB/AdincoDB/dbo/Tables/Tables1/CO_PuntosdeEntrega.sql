CREATE TABLE [dbo].[CO_PuntosdeEntrega] (
    [PuntoEntregaID]            INT            IDENTITY (1000, 1) NOT NULL,
    [Nombre]                    NVARCHAR (MAX) NULL,
    [CreadoPor]                 INT            NULL,
    [CreadoEl]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEl]              DATETIME       NULL,
    [Activo]                    BIT            NULL,
    [TagPatinMedicion]          VARCHAR (100)  NULL,
    [TipoMedidor]               VARCHAR (100)  NULL,
    [TagMedidor]                VARCHAR (100)  NULL,
    [Clasificacion]             VARCHAR (100)  NULL,
    [IdentificacionResponsable] VARCHAR (150)  NULL,
    [Coordenadas]               VARCHAR (150)  NULL,
    [Latitud]                   VARCHAR (150)  NULL,
    [Longitud]                  VARCHAR (150)  NULL,
    PRIMARY KEY CLUSTERED ([PuntoEntregaID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

