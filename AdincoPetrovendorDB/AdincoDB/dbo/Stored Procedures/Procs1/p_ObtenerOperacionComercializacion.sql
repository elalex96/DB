-- p_ObtenerOperacionComercializacion 33023
CREATE PROC [dbo].[p_ObtenerOperacionComercializacion]
-- Add the parameters for the stored procedure here
@pIdOperacionComercializacion INT
AS
     SELECT IdOperacionComercializacion, 
            IdContrato, 
            MesReporte, 
            FechaTransaccion, 
            IdTipoHidrocarburo, 
            VolumenVendido, 
            PrecioVentaUnitario, 
            CostoUnitarioComercializacion, 
            PrecioPuntoMedicion, 
            IdFactura, 
            NumeroFolioPedimento, 
            EPT, 
            OperacionBajoReglasMercado, 
            ClasificacionDocumentoSoporte, 
            CreadoPor, 
            CreadoEl, 
            ModificadoPor, 
            ModificadoEl, 
            Activo, 
            PVUAnterior, 
            PPMAnterior, 
            ISNULL(PenaEconomica, 0) AS PenaEconomica
     FROM COM_OperacionComercializacion
     WHERE IdOperacionComercializacion = @pIdOperacionComercializacion;