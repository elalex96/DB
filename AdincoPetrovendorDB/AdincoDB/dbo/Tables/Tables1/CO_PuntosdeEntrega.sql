CREATE TABLE [dbo].[CO_PuntosdeEntrega] (
    [PuntoEntregaID]   INT            IDENTITY (1000, 1) NOT NULL,
    [Nombre]           NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [Activo]           BIT            NULL,
    [TagPatinMedicion] VARCHAR (100)  NULL,
    [TipoMedidor]      VARCHAR (100)  NULL,
    [TagMedidor]       VARCHAR (100)  NULL,
    [Clasificacion]    VARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([PuntoEntregaID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

