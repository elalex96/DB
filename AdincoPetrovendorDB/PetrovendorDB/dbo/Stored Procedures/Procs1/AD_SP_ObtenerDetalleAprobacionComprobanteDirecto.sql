-- =============================================  
-- Author: Daniel AC
-- Create date: <07/04/2021>  
-- Description: <Consulta a detalle de un Pedimento/Comprobante de Procura>  
-- =============================================  
CREATE PROCEDURE [dbo].[AD_SP_ObtenerDetalleAprobacionComprobanteDirecto]   
 -- Add the parameters for the stored procedure here  
 @IdPedimentoComprobante INT,  
 @IdProveedor INT, 
 @TipoConsulta   VARCHAR(MAX)
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
   IF @TipoConsulta='DETALLE'
   BEGIN 
 SELECT  
  PC.IdPedimentoComprobante,  
  PC.NumeroPedimento,  
  PC.FolioComprobante,  
  CP.Clave + '(' + CP.Descripcion + ')' AS ClavePedimento,  
  PC.Regimen,  
  PC.AduanaES,  
  PC.AcuseElectronico,  
  PCD.DescripcionMercancia,  
  PCD.Cantidad,  
  PC.FechaPago,  
  PC.CuentaBancaria,  
  PC.NumFacturaC,  
  CONCAT(TM.TipoMoneda, ' (',TM.TipoMonedaCorto,')') AS Moneda,  
  PCD.PrecioUnitario AS SubTotal,  
  US.Nombre AS CargadoPor,  
  PC.CreadoEn,  
  UN.Unidad,  
  CONCAT(SC.RazonSocial, ' (',SC.RFC,')') AS Exportador,  
  CONCAT(SI.RazonSocial, ' (',SI.RFC,')') AS Importador,  
  ES.Nombre AS EstatusAprobacion,  
  USM.Nombre AS ModificadoPor,  
  PC.ModificadoEn,  
  PCD.ClaseBienServicio,  
  ISNULL(PC.EsnotaCredito,0) AS EsnotaCredito,  
  PC.TipoOrigen,  
  CC.CentroCosto,  
  CO.Numero + ' - ' + CO.Descripcion AS CuentaContable,  
  ISNULL(PC.DiasCredito,0) AS DiasCredito,  
  ISNULL ( PCC.NombrePeriodo, 'No Disponible' ) AS Periodo, 
  OP.IdDocumento,
  PC.IdContrato,
  AC.NombreAreaContractual AS AreaContractual,
  APC.IdProveedor,
  OP.IdEstatusOperacion AS IdEstatusAprobacion,
  OP.IdOperacion
 FROM dbo.FI_PedimentoComprobante AS PC  
  JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD  
   ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante  
  JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
   ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante  
  JOIN dbo.TA_Operacion AS OP  
   ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante  
   AND OP.IdTipoOperacion = 19  
   AND OP.IdProveedor = APC.IdProveedor  
  JOIN dbo.TA_Estatus AS ES  
   ON ES.IdEstatus = OP.IdEstatusOperacion  
  JOIN dbo.S_Usuario AS US  
   ON US.IdUsuario = PC.CreadoPor  
  LEFT JOIN dbo.S_Usuario AS USM  
   ON USM.IdUsuario = PC.ModificadoPor  
  LEFT JOIN Adinco.dbo.PV_TipoMoneda AS TM  
   ON TM.IdMoneda = PC.IdMoneda  
  LEFT JOIN Adinco.dbo.PV_MM_MaterialUnidad AS UN  
   ON UN.IdUnidad = PCD.IdUnidadMedida  
  LEFT JOIN Adinco.dbo.PV_Subcontratista AS SC  
   ON SC.IdSubcontratista = PC.IdSubcontratistaExportador  
  LEFT JOIN Adinco.dbo.PV_Subcontratista AS SI  
   ON SI.IdSubcontratista = PC.IdSubcontratistaImportador  
  LEFT JOIN Adinco.dbo.FI_ClavesPedimento AS CP   
   ON PC.ClavePedimento = CP.IdPedimento  
  LEFT JOIN dbo.CC_CentroCosto AS CC  
    ON CC.IdCentroCosto = PC.IdCentroCosto  
  LEFT JOIN dbo.DG_CuentaContable AS CO  
    ON CO.Id = PC.IdCuentaContable  
  LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes linea  
    ON linea.IdLineaPresupuestoMes = PC.IdLineaPresupuesto  
  LEFT JOIN Adinco.dbo.CO_Presupuesto P   
    ON P.idPresupuesto = PC.IdPresupuesto  
  LEFT JOIN Adinco.dbo.CO_ProgramaActividad PA   
    ON PA.IdProgramaActividad = P.idProgramaActividad   
  LEFT JOIN Adinco.dbo.CO_PeriodoContrato PCC   
	ON PCC.IdPeriodo = PA.idPeriodoContrato 
  LEFT JOIN Adinco.dbo.CO_Contrato AS C  
					ON PC.IdContrato = C.IdContrato 
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  
		ON C.IdAreaContractual = AC.IdAreaContractual  
 WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante  
 AND APC.IdProveedor=@IdProveedor
  END 


  IF @TipoConsulta='APROBADORES'
  BEGIN 
	 SELECT  
	  TT.IdTarea,  
	  TT.NoSecuencia,  
	  US.Nombre AS Aprobador,  
	  TT.FechaCambioEstatus,  
	  TT.IdEstatus,  
	  TT.Comentario,
	  E.Nombre AS NombreEstatus
	 FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
	  JOIN dbo.FI_PedimentoComprobante AS PC   
	   ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante  
	  JOIN dbo.TA_Operacion AS OP  
	   ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante  
	   AND OP.IdTipoOperacion = 19  
	   AND OP.IdProveedor = APC.IdProveedor  
	  JOIN dbo.TA_Tarea AS TT  
	   ON TT.IdOperacion = OP.IdOperacion  
		AND TT.Activo = 1  
	  JOIN dbo.S_Usuario AS US  
	   ON US.IdUsuario = TT.IdAprobador  
	   LEFT JOIN TA_Estatus E
	   ON TT.IdEstatus=E.IdEstatus
	 WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante  
	 ORDER BY  TT.NoSecuencia ASC
  END 

END  