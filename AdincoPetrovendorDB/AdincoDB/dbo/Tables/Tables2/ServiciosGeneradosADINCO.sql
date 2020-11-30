CREATE TABLE [dbo].[ServiciosGeneradosADINCO] (
    [IdServicoGenerado] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]       NVARCHAR (MAX) NULL,
    [FechaEmision]      DATE           NULL,
    [FechaRecepcion]    DATE           NULL,
    [IdUsuario]         INT            NULL,
    [IdOperadora]       INT            NULL,
    [IdSubContratista]  INT            NULL,
    [IdContrato]        INT            NULL,
    [ModificadoPor]     INT            NULL,
    [RegistradoEl]      DATETIME       NULL,
    [ModificadoEl]      DATETIME       NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_ServiciosGeneradosADINCO] PRIMARY KEY CLUSTERED ([IdServicoGenerado] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

