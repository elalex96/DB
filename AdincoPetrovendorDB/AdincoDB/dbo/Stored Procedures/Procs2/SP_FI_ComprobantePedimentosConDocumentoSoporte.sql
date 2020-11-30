-- =============================================
-- Author:		Reyna Olvera
-- Create date:07/06/2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobantePedimentosConDocumentoSoporte] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT,
@idTipoArchivo INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
		if @idTipoArchivo=2
	BEGIN
			SELECT PC.IdPedimentoComprobante AS IdPedimento,
				PC.NumeroPedimento,
				CP.Clave AS ClavePedimento,
				PC.FolioComprobante,
				PC.FechaPago,
				PC.Regimen,
				SI.RazonSocial AS Importador,
				PC.AduanaES,
				SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
				PC.AcuseElectronico,
				PCD.DescripcionMercancia,
				TM.TipoMonedaCorto,
				PCD.PrecioUnitario,
				PCD.Cantidad,
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
				TieneSoporte = CAST(CASE
						WHEN FS.DocumentoSoporteId IS NULL
						THEN 0
						ELSE 1
					END AS BIT)
			FROM FI_PedimentoComprobante AS PC
				INNER JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
				INNER JOIN dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
				INNER JOIN dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
				INNER JOIN dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
				LEFT JOIN dbo.AP_Usuario UC ON PC.CreadoPor = UC.UsuarioID
				LEFT JOIN dbo.AP_Usuario UM ON PC.ModificadoPor = UM.UsuarioID
				LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
				LEFT JOIN dbo.FI_ClavesPedimento CP ON PC.ClavePedimento = CP.IdPedimento
				LEFT JOIN FI_RelacionSoporteFactura FS ON PC.IdPedimentoComprobante = FS.IdPedimentoComprobante
			WHERE PC.CvTipoDocFacturacion = 2
				AND PC.IdContrato = @IdContrato
			ORDER BY IdPedimento DESC;
			End

			ELSE


			If @idTipoArchivo=3
			Begin 
			        SELECT PC.IdPedimentoComprobante AS IdComprobante,
                PC.FolioComprobante,
                PC.FechaPago,
                SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
                PCD.NumeroSerieMercancia,
                PCD.ClaseBienServicio,
                SUBSTRING(MU.UMB, 0, 30) AS UnidadMedida,
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
				TieneSoporte = CAST(CASE
                        WHEN FS.DocumentoSoporteId IS NULL
                        THEN 0
                        ELSE 1
                    END AS BIT)
            FROM FI_PedimentoComprobante AS PC
                LEFT JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                LEFT JOIN dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
                LEFT JOIN dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
                LEFT JOIN dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
                LEFT JOIN dbo.AP_Usuario UC ON PC.CreadoPor = UC.UsuarioID
                LEFT JOIN dbo.AP_Usuario UM ON PC.ModificadoPor = UM.UsuarioID
                LEFT JOIN dbo.AP_Lista L ON PC.IdFormaPago = L.IdClave
                                            AND IdGrupo = 10001
                LEFT JOIN dbo.PV_MM_MaterialUnidad MU ON PCD.IdUnidadMedida = MU.IdUnidad
                LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
				LEFT JOIN FI_RelacionSoporteFactura FS ON PC.IdPedimentoComprobante = FS.IdPedimentoComprobante
            WHERE PC.CvTipoDocFacturacion = 3
                AND PC.IdContrato = @IdContrato
            ORDER BY IdComprobante DESC;
			END



         END;
