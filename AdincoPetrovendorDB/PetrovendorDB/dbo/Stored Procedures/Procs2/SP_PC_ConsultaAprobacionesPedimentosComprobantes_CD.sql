-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <02/09/20202>  
-- Description: <Consulta de las aprobaciones de pedimentos comprobantes de compra directa, se agrego la columna estatus al filtro de búsqueda>  
-- ============================================= 
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <18/11/2020>  
-- Description: <Se agrego columna de contrato>  
-- =============================================   
CREATE PROCEDURE [dbo].[SP_PC_ConsultaAprobacionesPedimentosComprobantes_CD] --420,2199,1,''  
 -- Add the parameters for the stored procedure here  
 @IdProveedor INT,  
 @IdUsuario INT,  
 @Page INT,  
 @Buscar NVARCHAR(MAX)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
	-- Insert statements for procedure here  
 DECLARE @AllRecords INT;  
 DECLARE @RecordsByPage INT = 10;  
  
 SET @AllRecords = (  
	  SELECT  
	   COUNT(1)  
	  FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
	   JOIN dbo.TA_Operacion AS OP  
		ON APC.IdAceptacionPedidoPedimentoComprobante=OP.IdDocumento 
		AND OP.IdTipoOperacion = 19  --> APROBACIÓN DE COMPRA DIRECTA/PEDIMENTO DIRECTA
		AND OP.IdProveedor = APC.IdProveedor  
	   JOIN dbo.FI_PedimentoComprobante AS PC  
		ON APC.IdPedimentoComprobante=PC.IdPedimentoComprobante  
	   JOIN dbo.S_Usuario AS US  
		ON APC.CreadoPor =US.IdUsuario 
	   JOIN Adinco.dbo.PV_Subcontratista AS PVS  
		ON PC.IdSubcontratistaExportador  =PVS.IdSubcontratista
	   JOIN Adinco..CO_Contrato C 
		ON PC.IdContrato=C.IdContrato
	   JOIN Adinco.dbo.CO_AreaContractual AS AC 
		ON C.IdAreaContractual = AC.IdAreaContractual
	   JOIN dbo.TA_Estatus AS ET  
			ON OP.IdEstatusOperacion =ET.IdEstatus 
	  WHERE APC.IdProveedor = @IdProveedor  
	   AND (CAST(APC.IdPedimentoComprobante AS NVARCHAR) LIKE '%' + @Buscar + '%' OR  
		 CONVERT(varchar,PC.FechaPago,103) LIKE '%' + @Buscar + '%' OR  
		 ET.Nombre LIKE '%' + @Buscar + '%' OR 
		 PVS.RazonSocial LIKE '%' + @Buscar + '%')  
	   AND APC.Activo = 1  
	   AND ISNULL(OP.IdEstatusEliminado,0) = 0  
	   AND ISNULL(PC.IdEstatusEliminado,0) = 0);  
  
  SELECT *,  
	 @AllRecords AS Records,  
	 @RecordsByPage AS RecordsByPage  
  FROM  
  (  
  SELECT  
   ROW_NUMBER() OVER(PARTITION BY APC.IdAceptacionPedidoPedimentoComprobante ORDER BY APC.IdAceptacionPedidoPedimentoComprobante DESC) AS R,  
   APC.IdAceptacionPedidoPedimentoComprobante,  
   OP.IdOperacion,  
   PC.IdPedimentoComprobante,  
   PC.FolioComprobante,  
   PC.NumFacturaC,  
   PC.FechaPago,  
   US.Nombre + ' - Aprobadores: ' + LTRIM(dbo.fnGetAprobadores(OP.IdOperacion)) AS CargadoPor,  
	APC.CreadoEl,  
   PVS.RazonSocial AS Exportador,  
   concat( FORMAT(PCD.PrecioUnitario,'C','En-Us') , ' ' , TM.TipoMonedaCorto) AS TipoMonedaCorto,  
   ET.Nombre AS Estatus,  
   (ROW_NUMBER() OVER(ORDER BY APC.CreadoEl DESC) - 1) / @RecordsByPage AS _Page  ,
  CONCAT(C.NumeroContrato,' - ', AC.NombreAreaContractual) AS Contrato
  FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
   JOIN dbo.TA_Operacion AS OP  
	ON APC.IdAceptacionPedidoPedimentoComprobante  =OP.IdDocumento 
	AND OP.IdTipoOperacion = 19  
	AND OP.IdProveedor = APC.IdProveedor  
   JOIN dbo.FI_PedimentoComprobante AS PC  
	ON APC.IdPedimentoComprobante =PC.IdPedimentoComprobante 
   JOIN dbo.S_Usuario AS US  
	ON APC.CreadoPor  =US.IdUsuario 
   JOIN Adinco.dbo.PV_Subcontratista AS PVS  
	ON PC.IdSubcontratistaExportador =PVS.IdSubcontratista 
   JOIN Adinco.dbo.PV_TipoMoneda AS TM  
	ON  PC.IdMoneda  =TM.IdMoneda 
   JOIN dbo.TA_Estatus AS ET  
	ON OP.IdEstatusOperacion =ET.IdEstatus 
   JOIN Adinco..CO_Contrato C 
	ON PC.IdContrato=C.IdContrato
   JOIN Adinco.dbo.CO_AreaContractual AS AC 
	ON C.IdAreaContractual = AC.IdAreaContractual
   LEFT JOIN FI_PedimentoComprobanteDetalle PCD 
    ON APC.IdPedimentoComprobante = PCD.IdPedimentoComprobante 
  WHERE APC.IdProveedor = @IdProveedor  
   AND APC.Activo = 1  
   AND (CAST(APC.IdPedimentoComprobante AS NVARCHAR) LIKE '%' + @Buscar + '%' OR  
	CONVERT(varchar,PC.FechaPago,103) LIKE '%' + @Buscar + '%' OR  
	   ET.Nombre LIKE '%' + @Buscar + '%' OR 
	   PVS.RazonSocial LIKE '%' + @Buscar + '%' OR  
	dbo.fnGetAprobadores(OP.IdOperacion) LIKE '%' + @Buscar + '%')  
   AND ISNULL(OP.IdEstatusEliminado,0) = 0  
   AND ISNULL(PC.IdEstatusEliminado,0) = 0    
  ) AS R  
  WHERE R.R = 1 AND  
   R._Page = (@Page - 1)  
  ORDER BY R.IdAceptacionPedidoPedimentoComprobante DESC;  
END