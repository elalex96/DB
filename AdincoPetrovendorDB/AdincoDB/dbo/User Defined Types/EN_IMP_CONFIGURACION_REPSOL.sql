CREATE TYPE [dbo].[EN_IMP_CONFIGURACION_REPSOL] AS TABLE (
    [IdEntregable]      NVARCHAR (100)  NULL,
    [Area]              NVARCHAR (1000) NULL,
    [DiasAlertaPrevia]  NVARCHAR (100)  NULL,
    [DiasElaboracion]   NVARCHAR (100)  NULL,
    [DiasRevicion]      NVARCHAR (100)  NULL,
    [DiasAprobacion]    NVARCHAR (100)  NULL,
    [Activo]            NVARCHAR (10)   NULL,
    [Elaborador]        NVARCHAR (1000) NULL,
    [ReceptorAlerta]    NVARCHAR (1000) NULL,
    [LiderArea]         NVARCHAR (1000) NULL,
    [ElaboradorInterno] NVARCHAR (1000) NULL);

