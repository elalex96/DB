CREATE TABLE [dbo].[PRECARGA_ENI_2020] (
    [id]                   INT           NULL,
    [contrato]             VARCHAR (80)  NULL,
    [consecutivo]          VARCHAR (250) NULL,
    [activo]               VARCHAR (2)   NULL,
    [arearesponsable]      VARCHAR (250) NULL,
    [elaborador]           VARCHAR (500) NULL,
    [revisor]              VARCHAR (500) NULL,
    [aprobador]            VARCHAR (500) NULL,
    [diaselaborar]         INT           NULL,
    [diasrevisar]          INT           NULL,
    [diasaprobar]          INT           NULL,
    [diasalerta]           INT           NULL,
    [IDCONTRATO]           INT           NULL,
    [IDENTREGABLE]         INT           NULL,
    [IDCONTRATOENTREGABLE] INT           NULL,
    [IDAREA]               INT           NULL,
    [IDELABORADOR]         INT           NULL,
    [IDREVISOR]            INT           NULL,
    [IDAPROBADOR]          INT           NULL,
    [PROCESADO]            BIT           NULL
);

