-- =============================================
-- Author:		Manuel CD
-- Create date: 05-12-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaPedimentosPorContrato] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             SET LANGUAGE spanish;
	    --
             DECLARE @IdContratista INT;
             SELECT @IdContratista = CA.IdContratista
             FROM CO_Contrato C
                  JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
             WHERE C.IdContrato = @IdContrato;

    -- Insert statements for procedure here
             SELECT PC.IdPedimentoComprobante AS IdPedimento,
                    PC.NumeroPedimento,
                    CP.Clave AS ClavePedimento,
                    PC.FolioComprobante,
                    PC.FechaPago,
                    PC.Regimen,
                    SI.RazonSocial AS Importador,
                    PC.AduanaES,
                    SE.RazonSocial AS Exportador,
                    PC.AcuseElectronico,
                    PCD.DescripcionMercancia,
                    TM.TipoMonedaCorto,
                    PCD.PrecioUnitario,
                    PCD.Cantidad
             FROM FI_PedimentoComprobante AS PC
                  INNER JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                  INNER JOIN dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
                  INNER JOIN dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
                  INNER JOIN dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
                  LEFT JOIN dbo.AP_Usuario UC ON PC.CreadoPor = UC.UsuarioID
                  LEFT JOIN dbo.AP_Usuario UM ON PC.ModificadoPor = UM.UsuarioID
                  LEFT JOIN dbo.FI_ClavesPedimento CP ON PC.ClavePedimento = CP.IdPedimento
                  LEFT JOIN dbo.CO_Contrato C ON PC.IdContrato = C.IdContrato
             WHERE PC.CvTipoDocFacturacion = 2
                   AND C.IdContratista = @IdContratista
             ORDER BY IdPedimento DESC

         END;
