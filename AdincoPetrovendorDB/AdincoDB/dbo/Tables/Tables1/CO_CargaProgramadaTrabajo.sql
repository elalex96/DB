CREATE TABLE [dbo].[CO_CargaProgramadaTrabajo] (
    [IdProgramadaTrabajo] INT             IDENTITY (1000, 1) NOT NULL,
    [Actividad]           VARCHAR (200)   NULL,
    [Unidad]              VARCHAR (100)   NULL,
    [IdContrato]          INT             NULL,
    [Fecha]               DATETIME        NULL,
    [Cantidad]            DECIMAL (10, 2) NULL,
    [UnidadesActividad]   DECIMAL (10, 2) NULL,
    [UnidadesTrabajo]     DECIMAL (10, 2) NULL,
    [Estatus]             VARCHAR (100)   NULL,
    [IdUsuario]           INT             NULL,
    [MesCarga]            DATE            NULL,
    [FechaModificacion]   DATETIME        NULL,
    [Activo]              BIT             NULL,
    CONSTRAINT [PK_CO_CargaProgramadaTrabajo] PRIMARY KEY CLUSTERED ([IdProgramadaTrabajo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

