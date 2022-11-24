CREATE TABLE [dbo].[MM_DomicilioEntregaPedido] (
    [IdDomicilioEntrega] INT            IDENTITY (1, 1) NOT NULL,
    [Calle]              NVARCHAR (300) NULL,
    [NoExterior]         NVARCHAR (200) NULL,
    [NoInterior]         NVARCHAR (200) NULL,
    [Colonia]            NVARCHAR (300) NULL,
    [Municipio]          NVARCHAR (300) NULL,
    [Estado]             NVARCHAR (300) NULL,
    [CP]                 NVARCHAR (50)  NULL,
    [Referencia]         NVARCHAR (MAX) NULL,
    [IdProveedor]        INT            NULL,
    [NoSecuencia]        INT            NULL,
    CONSTRAINT [PK_MM_DomicilioEntregaPedido] PRIMARY KEY CLUSTERED ([IdDomicilioEntrega] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

