CREATE TABLE [dbo].[Carso_Items_comparativaCabecera] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [FechaEntrega]        DATETIME       NULL,
    [TipoAdjudicacion]    INT            NULL,
    [JustificacionPedido] NVARCHAR (MAX) NULL,
    [Aprobadores]         NVARCHAR (MAX) NULL,
    [MensajeAprobacion]   NVARCHAR (MAX) NULL,
    [IdComparativa]       NVARCHAR (MAX) NULL,
    [p6]                  NVARCHAR (MAX) NULL,
    [p7]                  NVARCHAR (MAX) NULL,
    [p8]                  NVARCHAR (MAX) NULL,
    [p9]                  NVARCHAR (MAX) NULL,
    [p10]                 NVARCHAR (MAX) NULL,
    [DataAreaID]          NVARCHAR (MAX) NULL,
    [Procesado]           BIT            NULL,
    [Activo]              BIT            NULL,
    [CreadoEl]            DATETIME       NULL,
    [ProcesadoEl]         DATETIME       NULL,
    [IpAdress]            NVARCHAR (MAX) NULL,
    [Hostname]            NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

