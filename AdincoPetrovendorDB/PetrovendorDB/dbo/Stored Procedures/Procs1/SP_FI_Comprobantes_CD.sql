-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/09/2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_Comprobantes_CD]
	-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here

             SELECT PC.IdPedimentoComprobante AS IdComprobante,
                    PC.FolioComprobante,
                    PC.FechaPago,
                    SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
                    PCD.NumeroSerieMercancia,
                    PCD.ClaseBienServicio,
                    SUBSTRING(MU.Unidad, 0, 30) AS UnidadMedida,
                    TM.TipoMonedaCorto,
                    PCD.PrecioUnitario,
                    PCD.Cantidad,
                    PCD.ImporteTotal,
                    L.Nombre AS FormaDePago,
                    CASE
                        WHEN D.DocumentoByte IS NULL
                             OR D.DocumentoByte LIKE 0x
                        THEN 'NO CARGADO'
                        ELSE 'Cargado'
                    END AS 'Archivo',
                    UC.Nombre AS CreadoPor,
                    PC.CreadoEn,
                    UM.Nombre AS ModificadoPor,
                    PC.ModificadoEn,
                    PC.NumFacturaC,
					CASE 
						WHEN ISNULL(PC.EsnotaCredito,0) = 0 
							THEN  'No'
							ELSE 'Si'
						END
					 AS EsnotaCredito,
					 TE.Nombre AS Estatus
             FROM FI_PedimentoComprobante AS PC
                  LEFT JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                  LEFT JOIN Adinco.dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
                  LEFT JOIN Adinco.dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
                  LEFT JOIN Adinco.dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
                  LEFT JOIN dbo.S_Usuario UC ON PC.CreadoPor = UC.IdUsuario
                  LEFT JOIN dbo.S_Usuario UM ON PC.ModificadoPor = UM.IdUsuario
                  LEFT JOIN Adinco.dbo.AP_Lista L ON PC.IdFormaPago = L.IdClave
                                              AND IdGrupo = 10001
                  LEFT JOIN Adinco.dbo.PV_MM_MaterialUnidad MU ON PCD.IdUnidadMedida = MU.IdUnidad
                  LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
				  JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
					ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
				  JOIN dbo.TA_Operacion AS OP
					ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
					AND OP.IdTipoOperacion = 19
					AND OP.IdProveedor = APC.IdProveedor
				  LEFT JOIN dbo.FI_RelacionAdincoPedimentoComprobante AS RAPC
					ON RAPC.IdPedimentoComprobantePetrovendor = PC.IdPedimentoComprobante
				  JOIN dbo.TA_Estatus AS TE
					ON TE.IdEstatus = OP.IdEstatusOperacion
             WHERE PC.CvTipoDocFacturacion = 3
                   AND APC.IdProveedor = @IdProveedor
             ORDER BY IdComprobante DESC;

END;
