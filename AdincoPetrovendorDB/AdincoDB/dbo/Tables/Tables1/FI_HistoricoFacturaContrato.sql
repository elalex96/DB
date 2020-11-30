CREATE TABLE [dbo].[FI_HistoricoFacturaContrato] (
    [IdHistFactCont]     INT      IDENTITY (1, 10000) NOT NULL,
    [IdFactura]          INT      NULL,
    [IdContratoAnterior] INT      NULL,
    [IdContratoNuevo]    INT      NULL,
    [FechaModificacion]  DATETIME NULL,
    [ModificadoPor]      INT      NULL
);

