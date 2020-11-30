CREATE TABLE [dbo].[EN_Robert] (
    [Ronda]                       NVARCHAR (255) NULL,
    [Frecuencia Entregable]       NVARCHAR (255) NULL,
    [Regulador]                   NVARCHAR (255) NULL,
    [Marco legal]                 NVARCHAR (255) NULL,
    [Articulo]                    NVARCHAR (MAX) NULL,
    [IdEntregable]                FLOAT (53)     NULL,
    [Consecutivo]                 NVARCHAR (255) NULL,
    [Activo]                      NVARCHAR (255) NULL,
    [Área]                        NVARCHAR (255) NULL,
    [Elaboro]                     NVARCHAR (255) NULL,
    [Reviso]                      NVARCHAR (255) NULL,
    [Aprobo]                      NVARCHAR (255) NULL,
    [Tiempo  para  elaborar]      FLOAT (53)     NULL,
    [Tiempo  para  Revisar]       FLOAT (53)     NULL,
    [Tiempo para Aprobar]         FLOAT (53)     NULL,
    [Tiempo para  Entregar]       FLOAT (53)     NULL,
    [Tiempo de entrega Regulador] NVARCHAR (255) NULL,
    [fecha regulador]             FLOAT (53)     NULL,
    [Fecha interna]               FLOAT (53)     NULL,
    [Receptor alerta]             NVARCHAR (255) NULL
);

