-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <04/09/2020>  
-- Description: <Consulta a detalle de un Pedimento/Comprobante de Procura>  
-- =============================================  
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <18/11/2020>  
-- Description: <Se agrego columna de contrato >  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_PC_ConsultaPedimentoComprobanteDetalle_CD]-- 1152,420,0  
  
 -- Add the parameters for the stored procedure here  
 @IdPedimentoComprobante INT,  
 @IdProveedor INT,  
 @IdUsuario INT  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 DECLARE @APROBADOR BIT = 0;  
 DECLARE @SIGAPROBADOR INT;  
 DECLARE @NOSECUENCIA INT;  

 --CONSULTA DE LA OPERACION  
 DECLARE @IDOPERACION INT = (SELECT  
         OP.IdOperacion  
        FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
         JOIN dbo.TA_Operacion AS OP  
          ON  APC.IdAceptacionPedidoPedimentoComprobante =OP.IdDocumento 
          AND APC.IdProveedor =OP.IdProveedor
		  AND OP.IdTipoOperacion = 19            
        WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante);  
   
 --CONSULTA DEL TIPO DE FLUJO DE TAREAS  
 DECLARE @TIPOFLUJO INT = (SELECT  
         FT.IdTipoFlujo  
        FROM dbo.TA_Operacion AS OP  
        JOIN dbo.TA_FlujoTarea AS FT   
         ON OP.IdFlujoTarea  =FT.IdFlujoTarea 
        WHERE OP.IdOperacion = @IDOPERACION);  
  
 IF @TIPOFLUJO = 1--SERIAL  
 BEGIN  
    
  --CONSULTA DEL SIGUIENTE APROBADOR  
  SET @SIGAPROBADOR = (SELECT TOP 1  
          TA.IdAprobador  
         FROM dbo.TA_Tarea AS TA  
         WHERE TA.IdOperacion = @IDOPERACION  
          AND TA.IdEstatus <> 7  
          AND TA.Activo = 1  
          AND TA.FechaCambioEstatus IS NULL  
         ORDER BY TA.NoSecuencia ASC);  
  
  SET @NOSECUENCIA = (SELECT TOP 1  
          TA.NoSecuencia  
         FROM dbo.TA_Tarea AS TA  
         WHERE TA.IdOperacion = @IDOPERACION  
          AND TA.IdEstatus <> 7  
          AND TA.Activo = 1  
          AND TA.FechaCambioEstatus IS NULL  
         ORDER BY TA.NoSecuencia ASC);  
  
  --VERIFICACION DEL USUARIO APROBADOR  
  IF @IdUsuario = @SIGAPROBADOR  
  BEGIN  
   SET @APROBADOR = 1;  
  END;  
  
 END  
  
 IF @TIPOFLUJO = 2--PARALELO  
 BEGIN  
  
  --CONSULTA SI EL USUARIO SE ENCUENTRA EN EL FLUJO DE APROBACION  
  SET @SIGAPROBADOR = (SELECT TOP 1  
          TA.IdAprobador  
         FROM dbo.TA_Tarea AS TA  
         WHERE TA.IdOperacion = @IDOPERACION  
          AND TA.IdEstatus <> 7  
          AND TA.Activo = 1  
          AND TA.FechaCambioEstatus IS NULL  
          AND TA.IdAprobador = @IdUsuario);  
  
  --SE VERIFICA  
  IF @IdUsuario = @SIGAPROBADOR  
  BEGIN  
   SET @APROBADOR = 1;  
  END;  
       
 END;  
   
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
  ES.Nombre AS Estatus,  
  USM.Nombre AS ModificadoPor,  
  PC.ModificadoEn,  
  PCD.ClaseBienServicio,  
  ISNULL(PC.EsnotaCredito,0) AS EsnotaCredito,  
  ISNULL(@APROBADOR,0) AS EsAprobador,  
  ISNULL(@NOSECUENCIA,0) AS NoSecuencia,  
  ISNULL(@IDOPERACION,0) AS IdOperacion,  
  PC.TipoOrigen,  
  CC.CentroCosto,  
  CO.Numero + ' - ' + CO.Descripcion AS CuentaContable,
  CONCAT(C.NumeroContrato,' - ', AC.NombreAreaContractual) AS Contrato
 FROM dbo.FI_PedimentoComprobante AS PC  
  JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD  
   ON  PC.IdPedimentoComprobante  =PCD.IdPedimentoComprobante
  JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
   ON  PC.IdPedimentoComprobante  =APC.IdPedimentoComprobante 
  JOIN dbo.TA_Operacion AS OP  
   ON APC.IdAceptacionPedidoPedimentoComprobante=OP.IdDocumento   
   AND OP.IdProveedor = APC.IdProveedor  
   AND OP.IdTipoOperacion = 19    
  JOIN dbo.TA_Estatus AS ES  
   ON OP.IdEstatusOperacion=ES.IdEstatus   
  JOIN dbo.S_Usuario AS US  
   ON PC.CreadoPor  = US.IdUsuario 
  JOIN Adinco..CO_Contrato C 
	ON PC.IdContrato=C.IdContrato
  JOIN Adinco.dbo.CO_AreaContractual AS AC 
	ON C.IdAreaContractual = AC.IdAreaContractual
  LEFT JOIN dbo.S_Usuario AS USM  
   ON PC.ModificadoPor =USM.IdUsuario  
  LEFT JOIN Adinco.dbo.PV_TipoMoneda AS TM  
   ON PC.IdMoneda=TM.IdMoneda  
  LEFT JOIN Adinco.dbo.PV_MM_MaterialUnidad AS UN  
   ON PCD.IdUnidadMedida=UN.IdUnidad   
  LEFT JOIN Adinco.dbo.PV_Subcontratista AS SC  
   ON PC.IdSubcontratistaExportador=SC.IdSubcontratista  
  LEFT JOIN Adinco.dbo.PV_Subcontratista AS SI  
   ON PC.IdSubcontratistaImportador=SI.IdSubcontratista   
  LEFT JOIN Adinco.dbo.FI_ClavesPedimento AS CP   
   ON PC.ClavePedimento = CP.IdPedimento  
  LEFT JOIN dbo.CC_CentroCosto AS CC  
    ON PC.IdCentroCosto=CC.IdCentroCosto 
  LEFT JOIN dbo.DG_CuentaContable AS CO  
    ON PC.IdCuentaContable  =CO.Id 
 WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante  
 GROUP BY TM.TipoMoneda,  
			 TM.TipoMonedaCorto,  
             SC.RazonSocial,   
			 SC.RFC,  
             PC.EsnotaCredito,  
             PC.IdPedimentoComprobante,  
             PC.FolioComprobante,  
             PC.ClavePedimento,  
             PC.Regimen,  
             PC.AduanaES,  
             PC.AcuseElectronico,  
             PCD.DescripcionMercancia,  
             PCD.Cantidad,  
             PC.FechaPago,  
             PCD.PrecioUnitario,  
             US.Nombre,  
             PC.CreadoEn,  
             UN.Unidad,  
             ES.Nombre,  
             USM.Nombre,  
             PC.ModificadoEn,  
             PCD.ClaseBienServicio,  
             PC.TipoOrigen,  
			SI.RazonSocial,  
			SI.RFC,  
			PC.CuentaBancaria,  
			CP.Clave,  
			CP.Descripcion,  
			PC.NumFacturaC,  
			PC.NumeroPedimento,  
			CC.CentroCosto,  
			CO.Numero,  
			C.NumeroContrato,
			AC.NombreAreaContractual,
			CO.Descripcion;  
  
  
END  