CREATE TABLE [dbo].[BI_Oferta] (
    [IdOferta]          INT             IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT             NULL,
    [IdPeticionOferta]  INT             NULL,
    [RazonSocial]       VARCHAR (2500)  NULL,
    [EstatusCotizacion] VARCHAR (500)   NULL,
    [FechaFinalizado]   DATETIME        NULL,
    [FechaFinOferta]    DATETIME        NULL,
    [EstatusOferta]     VARCHAR (500)   NULL,
    [TipoOferta]        VARCHAR (1000)  NULL,
    [Descripcion]       VARCHAR (5000)  NULL,
    [Asignados]         VARCHAR (5000)  NULL,
    [Contrato]          VARCHAR (5000)  NULL,
    [Solicitante]       VARCHAR (MAX)   NULL,
    [DescripcionGral]   VARCHAR (3000)  NULL,
    [FechaRegistro]     DATETIME        NULL,
    [Tipo]              NVARCHAR (1000) NULL,
    [EstatusGralOferta] NVARCHAR (500)  NULL,
    CONSTRAINT [PK_BI_Oferta] PRIMARY KEY CLUSTERED ([IdOferta] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

