CREATE TABLE [dbo].[ListaNegra] (
    [RFC]                                           VARCHAR (20)  NOT NULL,
    [Contribuyente]                                 VARCHAR (MAX) NULL,
    [Situacion]                                     VARCHAR (20)  NOT NULL,
    [NoFechaOficioGlobalPresuncion]                 VARCHAR (200) NOT NULL,
    [PublicacionPaginaSATPresuntos]                 SMALLDATETIME NULL,
    [PublicacionDOFpresuntos]                       SMALLDATETIME NULL,
    [PublicacionPaginaSATDesvirtuados]              SMALLDATETIME NULL,
    [NoFechaOficioGlobalContribuyentesDesvirtuaron] VARCHAR (MAX) NULL,
    [PublicacionDOFDesvirtuados]                    SMALLDATETIME NULL,
    [NoFechaOficioGlobalDefinitivos]                VARCHAR (MAX) NULL,
    [PublicacionPaginaSATDefinitivos]               SMALLDATETIME NULL,
    [PublicacionDOFDefinitivos]                     SMALLDATETIME NULL,
    [NoFechaOficioGlobalSentenciaFavorable]         VARCHAR (MAX) NULL,
    [PublicacionPaginaSATSentenciaFavorable]        SMALLDATETIME NULL,
    [PublicacionDOFSentenciaFavorable]              SMALLDATETIME NULL,
    CONSTRAINT [PK_ListaNegra] PRIMARY KEY CLUSTERED ([RFC] ASC, [Situacion] ASC, [NoFechaOficioGlobalPresuncion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

