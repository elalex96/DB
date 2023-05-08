CREATE TYPE [dbo].[ConceptosCNCompraDirecta] AS TABLE (
    [IdCDCN]                     INT            NULL,
    [DescripcionBienesServicios] NVARCHAR (MAX) NULL,
    [ValorFactura]               FLOAT (53)     NULL,
    [PCN]                        FLOAT (53)     NULL,
    [IdActividadBS]              INT            NULL,
    [ClasificacionSH]            INT            NULL);

