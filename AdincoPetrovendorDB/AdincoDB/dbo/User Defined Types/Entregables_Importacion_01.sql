CREATE TYPE [dbo].[Entregables_Importacion_01] AS TABLE (
    [IdEntregable]     NVARCHAR (50)  NULL,
    [Area]             NVARCHAR (500) NULL,
    [DiasAlertaPrevia] NVARCHAR (50)  NULL,
    [DiasElaboracion]  NVARCHAR (50)  NULL,
    [DiasRevicion]     NVARCHAR (50)  NULL,
    [DiasAprobacion]   NVARCHAR (50)  NULL,
    [Activo]           NVARCHAR (50)  NULL,
    [Elaborador]       NVARCHAR (500) NULL,
    [Revisor]          NVARCHAR (500) NULL,
    [Aprobador]        NVARCHAR (500) NULL,
    [ReceptorAlerta]   NVARCHAR (500) NULL);

