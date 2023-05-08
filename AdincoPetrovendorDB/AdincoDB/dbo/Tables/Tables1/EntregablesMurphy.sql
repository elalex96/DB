CREATE TABLE [dbo].[EntregablesMurphy] (
    [IdContratoEntregable]  INT           NULL,
    [Consecutivo]           VARCHAR (50)  NULL,
    [Activo]                BIT           NULL,
    [AreaResponsable]       VARCHAR (150) NULL,
    [Elaborador]            VARCHAR (250) NULL,
    [Revisor]               VARCHAR (250) NULL,
    [Aprobador]             VARCHAR (250) NULL,
    [DiasElaborar]          INT           NULL,
    [DiasRevisar]           INT           NULL,
    [DiasAprobar]           INT           NULL,
    [DiasAlerta]            INT           NULL,
    [DiasRestaFechaInterna] INT           NULL,
    [IdContrato]            INT           NULL,
    [IdEntregable]          INT           NULL,
    [IdArea]                INT           NULL,
    [IdUsuarioElaborador]   INT           NULL,
    [IdUsuarioRevisor]      INT           NULL,
    [IdUsuarioRevisor2]     INT           NULL,
    [IdUsuarioRevisor3]     INT           NULL,
    [IdUsuarioAprobador]    INT           NULL
);

