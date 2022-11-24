-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017-01-01
-- Description:	Lista las operaciones de comercializacion para un periodo t en un contrato
-- =============================================
CREATE PROCEDURE sp_COM_ConsultaOperacionesComercializacion 
-- Add the parameters for the stored procedure here
@IdContrato       INT  = 0,
@Periodo          DATE,
@TipoHidrocarburo INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT COM_OperacionComercializacion.IdOperacionComercializacion,
                COM_OperacionComercializacion.IdContrato,
                COM_OperacionComercializacion.MesReporte,
                COM_OperacionComercializacion.FechaTransaccion,
                COM_OperacionComercializacion.IdTipoHidrocarburo,
                COM_OperacionComercializacion.VolumenVendido,
                COM_OperacionComercializacion.PrecioVentaUnitario,
                COM_OperacionComercializacion.CostoUnitarioComercializacion,
                COM_OperacionComercializacion.PrecioPuntoMedicion,
                COM_OperacionComercializacion.IdFactura,
                COM_OperacionComercializacion.NumeroFolioPedimento,
                COM_OperacionComercializacion.EPT,
                COM_OperacionComercializacion.OperacionBajoReglasMercado,
                COM_OperacionComercializacion.ClasificacionDocumentoSoporte,
                CO_TipoHidrocarburo.TipoHidrocarburo,
                CO_TipoHidrocarburo.Hidrocarburo
         FROM COM_OperacionComercializacion
              INNER JOIN CO_TipoHidrocarburo ON COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
         WHERE(COM_OperacionComercializacion.IdContrato = @IdContrato)
              AND (COM_OperacionComercializacion.MesReporte = @Periodo)
              AND (CO_TipoHidrocarburo.TipoHidrocarburo = @TipoHidrocarburo);
     END;
