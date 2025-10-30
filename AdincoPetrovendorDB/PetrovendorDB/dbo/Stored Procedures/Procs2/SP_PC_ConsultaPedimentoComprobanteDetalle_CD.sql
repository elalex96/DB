USE Petrovendor
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PC_ConsultaPedimentoComprobanteDetalle_CD'
)
    DROP PROCEDURE SP_PC_ConsultaPedimentoComprobanteDetalle_CD;
GO
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <04/09/2020>  
-- Description: <Consulta a detalle de un Pedimento/Comprobante de Procura>  
-- =============================================  
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <28/10/2025>  
-- Description: <Se agrego columna de contrato y detalle del presupuesto >  
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
 SET LANGUAGE Spanish
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
		  AND OP.IdTipoOperacion = 19  --> CTE APROBACIÓN COMPROBANTE EXTRANJERO           
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
  CONCAT(C.NumeroContrato,' - ', AC.NombreAreaContractual) AS Contrato,
  ISNULL ( PCC.NombrePeriodo, 'No Disponible' ) AS Periodo ,
  ISNULL (( presupuesto.Nombre + ' [' + presupuesto.IdPresupuestoCNH + ']' ), 'No Disponible' ) AS Presupuesto ,
  ISNULL (
		( RIGHT('00' + CAST(MONTH ( linea.AC_PRESUP_MES ) AS VARCHAR (2)), 2) + ' '
			+ DATENAME ( MONTH, linea.AC_PRESUP_MES ) + ' '
			+ CAST(YEAR ( linea.AC_PRESUP_MES ) AS VARCHAR (50)) + ' - '
			+ CASE
				WHEN P.CIEP = 1
				THEN TSC.NombreTipoServicio
				ELSE ACTP.DescripcionActividadPetrolera
			END + '('
			+ CASE
				WHEN P.CIEP = 1
				THEN SACI.NombreSubactividad
				ELSE SACP.SubactividadPetrolera
			END + ')' ), 'No Disponible' ) AS Mes_Presupuestado 
 FROM dbo.FI_PedimentoComprobante AS PC  
  JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD  
   ON  PC.IdPedimentoComprobante  =PCD.IdPedimentoComprobante
  JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC  
   ON  PC.IdPedimentoComprobante  =APC.IdPedimentoComprobante 
  JOIN dbo.TA_Operacion AS OP  
   ON APC.IdAceptacionPedidoPedimentoComprobante=OP.IdDocumento   
   AND OP.IdProveedor = APC.IdProveedor  
   AND OP.IdTipoOperacion = 19   --> CTE APROBACIÓN PEDIMENTOS
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
   LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes linea
		ON PC.IdLineaPresupuesto = linea.IdLineaPresupuestoMes
   LEFT JOIN Adinco.dbo.CO_Presupuesto P 
			ON  PC.IdPresupuesto = P.idPresupuesto
   LEFT JOIN Adinco.dbo.CO_ProgramaActividad PA 
			ON  P.idProgramaActividad  = PA.IdProgramaActividad 
   LEFT JOIN Adinco.dbo.CO_PeriodoContrato PCC 
			ON PC.IdPeriodo  = PCC.IdPeriodo 
   LEFT JOIN Adinco.dbo.CO_ProgramaActividad progActividad
			ON PCC.IdPeriodo = progActividad.IdPeriodoContrato
   LEFT JOIN Adinco.dbo.CO_Presupuesto presupuesto
			ON progActividad.IdProgramaActividad = presupuesto.IdProgramaActividad
				AND	linea.IdPresupuesto = presupuesto.IdPresupuesto
	LEFT OUTER JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS ACTP
			ON linea.IdActividadPetrolera = ACTP.IdActividadPetrolera
	LEFT OUTER JOIN Adinco.dbo.CO_SubactividadPetrolera AS SACP
			ON linea.IdSubactividadPetrolera = SACP.IdSubactividadPetrolera
	LEFT OUTER JOIN Adinco.dbo.CO_ActividadCIEP AS ACI
			ON linea.IdActividad = ACI.IdActividad
	LEFT OUTER JOIN Adinco.dbo.CO_TipoServicio AS TSC
			ON linea.IdTipoServicio = TSC.ID_TIPOSER
	LEFT OUTER JOIN Adinco.dbo.CO_SubactividadCIEP AS SACI
			ON linea.IdSubactividad = SACI.IdSubactividad
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
			CO.Descripcion,
			PCC.NombrePeriodo,
			presupuesto.Nombre,
			presupuesto.IdPresupuestoCNH,
			linea.AC_PRESUP_MES,
			P.CIEP,
			TSC.NombreTipoServicio,
			ACTP.DescripcionActividadPetrolera,
			SACI.NombreSubactividad,
			SACP.SubactividadPetrolera  
  
  
END  