CREATE TABLE [dbo].[WA_Almacen] (
    [IdAlmacen]        INT            IDENTITY (10000, 1) NOT NULL,
    [Almacen]          NVARCHAR (MAX) NULL,
    [ClaveAlmacen]     NVARCHAR (MAX) NULL,
    [IdSubcontratista] INT            NULL,
    [Telefono]         NVARCHAR (MAX) NULL,
    [Domicilio]        NVARCHAR (MAX) NULL,
    [Correo]           NVARCHAR (MAX) NULL,
    [Observaciones]    NVARCHAR (MAX) NULL,
    [Activo]           BIT            NULL,
    [Firma]            NVARCHAR (MAX) NULL,
    [FolioAutomatico]  BIT            NULL,
    [UEPS]             INT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    CONSTRAINT [PK_WA_Almacen] PRIMARY KEY CLUSTERED ([IdAlmacen] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_WA_Almacen_PV_Subcontratista] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista])
);

