CREATE TABLE [dbo].[S_NotificacionTareaBitacora] (
    [IdTareaBitacora] INT           NOT NULL,
    [InicioEjecucion] DATETIME      NOT NULL,
    [FinEjecucion]    DATETIME      NULL,
    [HostNameTarea]   VARCHAR (100) NOT NULL,
    [IPTarea]         VARCHAR (15)  NOT NULL,
    [TieneError]      BIT           NOT NULL,
    CONSTRAINT [PK_S_NotificacionTareaBitacora] PRIMARY KEY CLUSTERED ([IdTareaBitacora] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

