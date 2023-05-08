CREATE TABLE [dbo].[CO_ActMesGasto] (
    [IdActMesGasto]           INT      IDENTITY (1, 1) NOT NULL,
    [IdRegistro]              INT      NULL,
    [AnteriorMesPresentacion] DATE     NULL,
    [NuevoMesPresentacion]    DATE     NULL,
    [FechaModificacion]       DATETIME NULL,
    [ModificadoPor]           INT      NULL,
    [IdEstadoAnterior]        INT      NULL,
    [IdEstadoNuevo]           INT      NULL
);

