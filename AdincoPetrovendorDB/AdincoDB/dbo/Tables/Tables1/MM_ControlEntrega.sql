CREATE TABLE [dbo].[MM_ControlEntrega] (
    [id_]             INT            IDENTITY (1, 1) NOT NULL,
    [IdAlmacen]       NVARCHAR (MAX) NULL,
    [IdMaterial]      INT            NULL,
    [CantidadTotal]   FLOAT (53)     NULL,
    [IdUnidad]        INT            NULL,
    [IdPedido]        INT            NULL,
    [Descripcion]     NVARCHAR (MAX) NULL,
    [FolioEntrega]    NVARCHAR (MAX) NULL,
    [FolioRecepcion]  NVARCHAR (MAX) NULL,
    [Fecha]           DATETIME       NULL,
    [Disponible]      FLOAT (53)     NULL,
    [Movimiento]      INT            NULL,
    [IdUnidadAlterna] INT            NULL,
    [Promedio]        FLOAT (53)     NULL,
    [CreadoPor]       INT            NULL,
    CONSTRAINT [PK_admin_cntrl_entrega] PRIMARY KEY CLUSTERED ([id_] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

