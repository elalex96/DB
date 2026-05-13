CREATE TYPE [dbo].[Entregables_Importacion] AS TABLE (
    [IdEntregable]      NVARCHAR (1) NULL,
    [Area]              NVARCHAR (1) NULL,
    [DiasAlertaPrevia]  NVARCHAR (1) NULL,
    [DiasElaboracion]   NVARCHAR (1) NULL,
    [DiasRevicion]      NVARCHAR (1) NULL,
    [DiasAprobacion]    NVARCHAR (1) NULL,
    [Activo]            NVARCHAR (1) NULL,
    [Elaborador]        NVARCHAR (1) NULL,
    [ReceptorAlerta]    NVARCHAR (1) NULL,
    [LiderArea]         NVARCHAR (1) NULL,
    [ElaboradorInterno] NVARCHAR (1) NULL);

