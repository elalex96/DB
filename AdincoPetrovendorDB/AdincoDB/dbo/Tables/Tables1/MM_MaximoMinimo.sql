CREATE TABLE [dbo].[MM_MaximoMinimo] (
    [IdMaximoMinimo]          INT            IDENTITY (1, 1) NOT NULL,
    [IdMaterial]              INT            NULL,
    [Descripcion]             NVARCHAR (MAX) NULL,
    [CantidadSolicitudPedido] FLOAT (53)     NULL,
    [CantidadMinima]          FLOAT (53)     NULL,
    [CantidadMaxima]          FLOAT (53)     NULL,
    [Activo]                  INT            NULL,
    [CreadoPor]               INT            NULL,
    CONSTRAINT [PK_admin_max_nin_cntrl] PRIMARY KEY CLUSTERED ([IdMaximoMinimo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

