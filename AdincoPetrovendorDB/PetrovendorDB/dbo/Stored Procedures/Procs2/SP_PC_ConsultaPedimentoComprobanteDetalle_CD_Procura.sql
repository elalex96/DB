USE Petrovendor
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PC_ConsultaPedimentoComprobanteDetalle_CD_Procura'
)
    DROP PROCEDURE SP_PC_ConsultaPedimentoComprobanteDetalle_CD_Procura;
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/09/2020>
-- Description:	<Consulta a detalle de un Pedimento/Comprobante de Procura>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <24/11/2025>
-- Description:	<Se agrega el lenguaje para que retorne el mes en español, se agrega isnulls a campos y se retorna id adjunto cn>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaPedimentoComprobanteDetalle_CD_Procura] 

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
	DECLARE @ID_DOCUMENTO_CN INT = 0;  
	SET @ID_DOCUMENTO_CN = (SELECT IdAchivoCNCD
						FROM dbo.CN_ArchivoCartaCompraDirecta
						WHERE IdPedimentoComprobante = @IdPedimentoComprobante)
    -- Insert statements for procedure here
	
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
		PC.TipoOrigen,
		DOP.DocumentoByte,
		DOP.NombreExtensionArchivo,
		CC.CentroCosto,
		CO.Numero + ' - ' + CO.Descripcion AS CuentaContable,
		ISNULL(PC.DiasCredito,0) AS DiasCredito,
		ISNULL ( PCC.NombrePeriodo, 'No Disponible' ) AS Periodo ,
						ISNULL (( ISNULL(presupuesto.Nombre,'') + ' [' + ISNULL(presupuesto.IdPresupuestoCNH,'') + ']' ), 'No Disponible' ) AS Presupuesto ,
						ISNULL (
							( RIGHT('00' + CAST(MONTH ( linea.AC_PRESUP_MES ) AS VARCHAR (2)), 2) + ' '
							  + DATENAME ( MONTH, linea.AC_PRESUP_MES ) + ' '
							  + CAST(YEAR ( linea.AC_PRESUP_MES ) AS VARCHAR (50)) + ' - '
							  + CASE
									WHEN P.CIEP = 1
									THEN ISNULL(TSC.NombreTipoServicio,'')
									ELSE ISNULL(ACTP.DescripcionActividadPetrolera,'')
								END + '('
							  + CASE
									WHEN P.CIEP = 1
									THEN ISNULL(SACI.NombreSubactividad,'')
									ELSE ISNULL(SACP.SubactividadPetrolera,'')
								END + ')' + ' (#LP: ' + CAST(ISNULL(linea.IdLineaPresupuestoMes,0) AS NVARCHAR(MAX))+')' ), 'No Disponible' ) AS Mes_Presupuestado,
		ISNULL(INS.NombreInstalacion, 'No Disponible' )  AS NombreInstalacion,
		ISNULL( (CSH.Nivel3+' - '+  CSH.Descripcion),'No Disponible') as NombreCuentaSectorHidrocarburos,
		ISNULL(@ID_DOCUMENTO_CN,0) AS ArchivoCNId 
	FROM dbo.FI_PedimentoComprobante AS PC
		JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD
			ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante 
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
			ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante 
		JOIN dbo.TA_Operacion AS OP
			ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento 
			AND OP.IdTipoOperacion = 19 --> CTE PEDIMENTOS
			AND  APC.IdProveedor = OP.IdProveedor
		JOIN dbo.TA_Estatus AS ES
			ON OP.IdEstatusOperacion = ES.IdEstatus 
		JOIN dbo.S_Usuario AS US
			ON PC.CreadoPor = US.IdUsuario  
		LEFT JOIN dbo.S_Usuario AS USM
			ON PC.ModificadoPor = USM.IdUsuario 
		LEFT JOIN Adinco.dbo.PV_TipoMoneda AS TM
			ON PC.IdMoneda = TM.IdMoneda 
		LEFT JOIN Adinco.dbo.PV_MM_MaterialUnidad AS UN
			ON PCD.IdUnidadMedida = UN.IdUnidad 
		LEFT JOIN Adinco.dbo.PV_Subcontratista AS SC
			ON PC.IdSubcontratistaExportador = SC.IdSubcontratista 
		LEFT JOIN Adinco.dbo.PV_Subcontratista AS SI
			ON PC.IdSubcontratistaImportador = SI.IdSubcontratista 
		LEFT JOIN Adinco.dbo.FI_ClavesPedimento AS CP 
			ON PC.ClavePedimento = CP.IdPedimento
		LEFT JOIN dbo.FI_Documento AS DOP
			ON PC.IdPedimentoComprobante = DOP.IdPedimentoComprobante 
		LEFT JOIN dbo.CC_CentroCosto AS CC
				ON PC.IdCentroCosto = CC.IdCentroCosto 
		LEFT JOIN dbo.DG_CuentaContable AS CO
				ON  PC.IdCuentaContable = CO.Id 
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes linea
				ON  PC.IdLineaPresupuesto = linea.IdLineaPresupuestoMes 
		LEFT JOIN Adinco.dbo.CO_Presupuesto P 
				ON PC.IdPresupuesto = P.idPresupuesto 
		LEFT JOIN Adinco.dbo.CO_ProgramaActividad PA 
				ON  P.idProgramaActividad  = PA.IdProgramaActividad
		LEFT JOIN Adinco.dbo.CO_PeriodoContrato PCC 
				ON PA.idPeriodoContrato  = PCC.IdPeriodo 		
		LEFT JOIN Adinco.dbo.CO_Presupuesto presupuesto
				ON  PC.IdPresupuesto = presupuesto.IdPresupuesto
		LEFT JOIN Adinco..CO_Instalacion INS
				ON PC.IdInstalacion = INS.IdInstalacion
		LEFT JOIN  Adinco..CO_CatalogoCuentaSH CSH
				ON PC.IdCuentaSectorHidrocarburos = CSH.IdCatalogoCuentasSH
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


END
