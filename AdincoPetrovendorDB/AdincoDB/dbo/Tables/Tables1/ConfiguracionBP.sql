CREATE TABLE [dbo].[ConfiguracionBP] (
    [IdContratoEntregable] INT           NULL,
    [CONSECUTIVO]          VARCHAR (70)  NULL,
    [ACTIVO]               BIT           NULL,
    [AREARESPONSABLE]      VARCHAR (250) NULL,
    [ELABORADOR]           VARCHAR (250) NULL,
    [REVISOR]              VARCHAR (250) NULL,
    [APROBADOR]            VARCHAR (250) NULL,
    [DIASELABORACION]      INT           NULL,
    [DIASREVISION]         INT           NULL,
    [DIASAAPROBACION]      INT           NULL,
    [DIASALERTA]           INT           NULL,
    [FECHAREGULADOR]       DATE          NULL,
    [FECHAINTERNA]         DATE          NULL,
    [IdEntregable]         INT           NULL,
    [IdContrato]           INT           NULL,
    [IdArea]               INT           NULL,
    [IdElaborador]         INT           NULL,
    [IdREvisor]            INT           NULL,
    [IdAprobador]          INT           NULL
);

