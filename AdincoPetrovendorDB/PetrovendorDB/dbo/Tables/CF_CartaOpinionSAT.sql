CREATE TABLE [dbo].[CF_CartaOpinionSAT] (
    [Carta]             NVARCHAR (MAX) NOT NULL,
    [Eliminado]         BIT            NOT NULL,
    [FechaEliminacion]  SMALLDATETIME  NULL,
    [FechaExpedicion]   SMALLDATETIME  NOT NULL,
    [IdCartaOponionSat] INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]       INT            NOT NULL,
    [NombreCarta]       NVARCHAR (MAX) NOT NULL,
    [Opinion]           BIT            NOT NULL,
    [SubidoEl]          SMALLDATETIME  NOT NULL,
    [SubidoPor]         INT            NOT NULL,
    [vigente]           BIT            NULL
);

