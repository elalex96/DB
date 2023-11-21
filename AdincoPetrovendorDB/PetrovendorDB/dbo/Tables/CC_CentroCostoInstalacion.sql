
CREATE TABLE [dbo].[CC_CentroCostoInstalacion] (
    [IdCentroCostoInstalacion]  INT      IDENTITY (1, 1) NOT NULL,
	[IdCentroCosto]             INT      NOT NULL,
    [IdInstalacion]             INT      NOT NULL,
	[IdContrato]                INT      NOT NULL,
    [Activo]                    BIT      NOT NULL,
    [CreadoEl]                  DATETIME NULL,
    [CreadoPor]                 INT      NULL,
    [ModificadoEl]              DATETIME NULL,
    [ModificadoPor]             INT      NULL,
    PRIMARY KEY CLUSTERED ([IdCentroCostoInstalacion] ASC),
	CONSTRAINT [FK_CC_CentroCostoInstalacion_CentroCosto] FOREIGN KEY ([IdCentroCosto]) REFERENCES [dbo].[CC_CentroCosto] ([IdCentroCosto])
	)