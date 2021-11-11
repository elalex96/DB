--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		DANIEL MORENO
-- Create date: 03-11-21
-- Description:	
-- =============================================
CREATEPROCEDURE [dbo].[SP_FI_Pedimentos_Subcontratista]-- 10007,10002,11571
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT,
@IdSubcontratista INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here

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
					ISNULL(pc.CuentaBancaria,'') CuentaBancaria
             FROM FI_PedimentoComprobante AS PC
                  INNER JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                  INNER JOIN dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
													AND	SE.IdSubcontratista = @IdSubcontratista
                  INNER JOIN dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
				  LEFT JOIN dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista 
                  LEFT JOIN dbo.AP_Usuario UC ON PC.CreadoPor = UC.UsuarioID
                  LEFT JOIN dbo.AP_Usuario UM ON PC.ModificadoPor = UM.UsuarioID
                  LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
                  LEFT JOIN dbo.FI_ClavesPedimento CP ON PC.ClavePedimento = CP.IdPedimento
             WHERE PC.CvTipoDocFacturacion IN (2,3)
                   AND PC.IdContrato = @IdContrato
             ORDER BY IdPedimento DESC;
         END;




