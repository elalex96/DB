CREATE TYPE [dbo].[CARSO_ItemDetalle] AS TABLE (
    [LineaPresupuesto]   NVARCHAR (MAX) NULL,
    [IdLineaPresupuesto] INT            NULL,
    [IdPosicion]         NVARCHAR (MAX) NULL,
    [Item]               NVARCHAR (MAX) NULL,
    [Cantidad]           FLOAT (53)     NULL,
    [Unidad]             NVARCHAR (MAX) NULL,
    [IdUnidad]           INT            NULL,
    [LugarEntrega]       NVARCHAR (MAX) NULL,
    [IdInstalacion]      INT            NULL,
    [Instalacion]        NVARCHAR (MAX) NULL,
    [CentroCosto]        NVARCHAR (MAX) NULL,
    [IdCentroCosto]      NVARCHAR (MAX) NULL,
    [p1]                 NVARCHAR (MAX) NULL,
    [p2]                 NVARCHAR (MAX) NULL,
    [p3]                 NVARCHAR (MAX) NULL,
    [p4]                 NVARCHAR (MAX) NULL,
    [p5]                 NVARCHAR (MAX) NULL);

