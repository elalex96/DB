
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/01/2020>
-- Description:	<Consulta de todos los detalles de la solped>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/02/2021>
-- Description:	<eliminado de los campos de prioridad y tipo de gasto>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidoDetallePeticionOferta_V2]-- 20135 
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@IdContrato    INT = NULL,
	@IdUsuario     INT = NULL,
	@FechaRegistro DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ExistenBases BIT = 0;
	DECLARE @CONTRATO NVARCHAR(max);
	DECLARE @PRESUPUESTO NVARCHAR(max);
	DECLARE @PERIODO NVARCHAR(max);
	DECLARE @LINEAPRESUPUESTO NVARCHAR(max);
	DECLARE @IDPRESUPUESTO NVARCHAR(max);
	DECLARE @IDPERIODO NVARCHAR(max);
	DECLARE @IDLINEAPRESUPUESTO NVARCHAR(max);
	DECLARE @IDPROVEEDORACTUAL INT;
	DECLARE @MOSTRARJUSTIFICIONPCM BIT = 0;
	DECLARE @RFCPROVEEDORACTUAL NVARCHAR(100);
	DECLARE @IDDOCPCM INT;
	DECLARE @RFCPCM NVARCHAR(100)= (SELECT TOP 1 RFC FROM dbo.PCM_RFC);

	SET LANGUAGE spanish; 

	SET @IDPROVEEDORACTUAL = (SELECT IdProveedor FROM dbo.MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido);
	SET @RFCPROVEEDORACTUAL = (SELECT TOP 1 RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IDPROVEEDORACTUAL);
	
	IF @RFCPCM = @RFCPROVEEDORACTUAL
	BEGIN
		
		SET @IDDOCPCM = (SELECT TOP 1 IdDocumento
						FROM dbo.PCMDocumentoAdjunto
						WHERE IdProveedor = @IDPROVEEDORACTUAL
							  AND IdSolicitucPedido = @IdSolicitudPedido
							  AND Activo = 1
							  AND IdTipoDocumento = 28);
		
		IF @IDDOCPCM IS NOT NULL
		BEGIN
		    
			SET @MOSTRARJUSTIFICIONPCM = 1;

		END
	END;

	SELECT @ExistenBases = CASE 
								WHEN F.IdDocBases IS NULL THEN 0 
								ELSE 1 
							END
							FROM TA_DocBasesOperacion F WITH (NOLOCK)
								LEFT JOIN	TA_Operacion O WITH (NOLOCK)
									ON F.IdOperacion = O.IdOperacion
								LEFT JOIN	MM_SolicitudPedido SP WITH (NOLOCK)
									ON O.IdDocumento = SP.IdSolicitudPedido
							WHERE
								O.IdTipoOperacion = 6
								AND SP.IdSolicitudPedido = @IdSolicitudPedido
								AND F.Activo = 1;

	SELECT
		@IDPERIODO = SP.IdPeriodo, 
		@IDPRESUPUESTO = SP.IdPresupuesto ,
		@IDLINEAPRESUPUESTO = SP.IdLineaPresupuesto,
		@IdContrato = SP.IdContrato
	FROM MM_SolicitudPedido AS SP WITH (NOLOCK)
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;

	SET @PERIODO = (SELECT Top 1 
						NombrePeriodo  as NombreParaMostrar
					FROM Adinco.dbo.CO_PeriodoContrato 
					WHERE (IdContrato = @IdContrato 
							AND IdPeriodo=@IdPeriodo));

	SET @PRESUPUESTO  = (SELECT ISNULL((SELECT Top 1 CONCAT(P.Nombre, ' [', P.IdPresupuestoCNH, ']')AS Nombre
							FROM Adinco.dbo.CO_ProgramaActividad AS PA
								INNER JOIN Adinco.dbo.CO_PeriodoContrato AS PC 
									ON PA.IdPeriodoContrato = PC.IdPeriodo
								INNER JOIN Adinco.dbo.CO_Presupuesto AS P 
									ON PA.IdProgramaActividad = P.IdProgramaActividad
							WHERE(PC.IdPeriodo = @IdPeriodo AND P.IdPresupuesto =@IdPresupuesto )
								AND (P.Activo = 1)),'No disponible') AS Presupuesto)

	SET @LINEAPRESUPUESTO =  (SELECT ISNULL(( SELECT Top 1
                CONCAT(RIGHT('00'+CAST(MONTH(LPM.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', 
				DATENAME(month, LPM.AC_PRESUP_MES), ' ', 
				YEAR(LPM.AC_PRESUP_MES), ' - ', 
				APCNH.DescripcionActividadPetrolera, '(',
				SBP.SubactividadPetrolera,')') AS Mes_Presupuestado
		FROM Adinco.dbo.CO_LineaPresupuestoMes AS LPM
              LEFT OUTER JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS APCNH 
				ON APCNH.IdActividadPetrolera = LPM.IdActividadPetrolera
              LEFT OUTER JOIN Adinco.dbo.CO_SubactividadPetrolera AS SBP 
				ON LPM.IdSubactividadPetrolera = SBP.IdSubactividadPetrolera
              LEFT OUTER JOIN Adinco.dbo.CO_TareaPetrolera AS TP 
				ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
              LEFT OUTER JOIN Adinco.dbo.CO_ActividadCIEP AS ACIEP 
				ON LPM.IdActividad = ACIEP.IdActividad
              LEFT OUTER JOIN Adinco.dbo.CO_TipoServicio AS TS 
				ON LPM.IdTipoServicio = TS.ID_TIPOSER
              LEFT OUTER JOIN Adinco.dbo.CO_SubactividadCIEP AS SACIEP 
				ON LPM.IdSubactividad = SACIEP.IdSubactividad
              LEFT OUTER JOIN Adinco.dbo.CO_Servicio AS S 
				ON LPM.IdServicio = S.IdServicio
              LEFT OUTER JOIN Adinco.dbo.CO_Area AS A 
				ON LPM.IdArea = A.IdArea
              LEFT OUTER JOIN Adinco.dbo.CO_Instalacion AS I 
				ON LPM.IdInstalacion = I.IdInstalacion
              LEFT OUTER JOIN Adinco.dbo.CO_Registro AS R 
				ON LPM.IdLineaPresupuestoMes = R.IdPrograma
              LEFT OUTER JOIN Adinco.dbo.CO_ClasificacionAnexo4 AS CA4 
				ON LPM.IdAnexo4 = CA4.IdAnexo4
              LEFT OUTER JOIN Adinco.dbo.FI_Factura AS F 
				ON F.IdFactura = R.IdFactura
              LEFT OUTER JOIN Adinco.dbo.CO_TipoCambioMensual AS TCM 
				ON TCM.IdMoneda = F.IdMoneda
					AND TCM.IdMes = MONTH(R.MesPresentacion)
                    AND TCM.Anio = YEAR(R.MesPresentacion)
              LEFT OUTER JOIN Adinco.dbo.CO_RubroInterno AS RI 
			  ON LPM.IdRubroInterno = RI.IdRubroInterno
         WHERE(LPM.IdPresupuesto =@IdPresupuesto ) 
			AND  LPM.IdLineaPresupuestoMes=@IdLineaPresupuesto ),'No Disponible') AS LINEA_PRESUPUESTO);

	SELECT
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia, 
			--TSP.TipoSolicitudPedido, 
			FORMAT(SP.FechaAlta ,'dd/MM/yyyy HH:mm:ss tt') AS FechaAlta,
			SP.AdjudicableParcialmente, 
			--SP.VisitaRequerida, 
			--SP.JuntaAclaracionesRequerida ,
			SP.UnaSolaEntregaRequerida, 
			FORMAT(SP.FechaEntregaRequerida,'dd/MM/yyyy HH:mm:ss tt') AS FechaEntregaRequerida,
			FORMAT(SP.FechaEntregaFinRequerida,'dd/MM/yyyy HH:mm:ss tt') AS FechaEntregaFinRequerida,
			TE.Nombre ,
			PSP.Prioridad, 
			TAO.IdEstatusOperacion, 
			U.Nombre AS Solicitante, 
			TAO.IdOperacion ,
			ISNULL ( SP.PeticionEnviada, 'false' ) AS PeticionEnviada, 
			TiOp.NombreOperacion, 
			CC.CentroCosto ,
			ISNULL ( TC.Termino, 'No aplica' ) AS Termino, 
			SP.IdContrato, 
			SP.IdPeriodo, 
			SP.IdPresupuesto ,
			SP.IdLineaPresupuesto, 
			ISNULL(TG.TipoGasto,'Sin Definir') AS TipoGasto, 
			ISNULL ( SP.Fianza, 'false' ) AS Fianza, 
			--ISNULL ( SP.Controlados, 'false' ) AS Controlados,
			SP.UnicoDomicilioEntrega, 
			SP.EntregasParciales, 
			ISNULL ( SP.IdTipoProceso, 0 ) ,
			ISNULL ( @ExistenBases, 0 ),
			ISNULL(PR.CotizacionesRestringidas,0), 
			ISNULL(SP.IdTipoGasto, 0),
			OPR.RazonSocial,
			@PERIODO AS NombrePeriodo,
			@PRESUPUESTO AS NombrePresupuesto,
			@LINEAPRESUPUESTO AS NombreLineaPresupuesto,
			@MOSTRARJUSTIFICIONPCM AS MostrarJustificacionPCM,
			ISNULL(SP.IdTipoProceso,2) AS IdTipoMetodoCompra
		FROM		MM_SolicitudPedido AS SP WITH (NOLOCK)
		INNER JOIN	MM_TipoSolicitudPedido AS TSP WITH (NOLOCK)
			ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		INNER JOIN	TA_Operacion AS TAO WITH (NOLOCK)
			ON TAO.IdDocumento = SP.IdSolicitudPedido
		INNER JOIN	TA_Estatus AS TE WITH (NOLOCK)
			ON TE.IdEstatus = TAO.IdEstatusOperacion
		INNER JOIN	MM_PrioridadSolicitudPedido AS PSP WITH (NOLOCK)
			ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
		INNER JOIN	S_Usuario AS U WITH (NOLOCK)
			ON U.IdUsuario = TAO.IdAsignador
		INNER JOIN	TA_TipoOperacion AS TiOp WITH (NOLOCK)
			ON TiOp.IdTipoOperacion = TAO.IdTipoOperacion
		LEFT JOIN	CC_CentroCosto AS CC WITH (NOLOCK)
			ON CC.IdCentroCosto = SP.IdCentroCosto
		LEFT JOIN	MM_TerminoComercio AS TC WITH (NOLOCK)
			ON TC.IdTerminoComercio = SP.IdTerminoInternacionales
		LEFT JOIN	MM_TipoGastos AS TG WITH (NOLOCK)
			ON TG.IdTipoGasto = SP.IdTipoGasto
		LEFT JOIN dbo.S_Proveedor AS PR WITH (NOLOCK)
			ON PR.IdProveedor = SP.IdProveedor
		LEFT JOIN dbo.S_Proveedor AS OPR WITH (NOLOCK)
			ON SP.IdProveedor = OPR.IdProveedor
		WHERE
					TAO.IdTipoOperacion = 2
					AND SP.IdSolicitudPedido = @IdSolicitudPedido;

	SELECT 
			SPD.IdSolicitudPedidoDetalle,
			CONCAT(' Descripción: ', MM.DescripcionCorta,
					' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
					' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
					' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END)	
			AS DescripcionCorta, 
			MM.IdMaterial AS IdMaterial,
			SPD.Cantidad, 
			SPD.Observaciones, 
			U.Unidad AS NombreUnidad,
			CONCAT(D.Calle, ' ',
			D.NoExterior , ' ', 
			D.NoInterior, ' ',D.Colonia , 
			' ',D.Municipio, ' ', D.Estado,
			' ',D.CodigoPostal , 
			' (', CAST(TD.TipoDomicilio AS NVARCHAR(MAX)),')') AS IdDomicilioEntrega ,
			MM.DescripcionLarga AS TextoLargo,
			ISNULL(SPD.IdUnidad,0) AS IdUnidad,
		 ---------
			S.IdSolicitudPedidoDetalleLineaPresupuesto,
			CC.CentroCosto,
			I.NombreInstalacion,
			dbo.Fn_RetornarMesProgramadoActividadConcat(LP.IdLineaPresupuestoMes) AS SubActividad,
			ADMS.IdSolPedMaterialDocumentoAdj,
			ADMS.NombreArchivoAdjunto
		FROM MM_SolicitudPedidoDetalle AS SPD WITH (NOLOCK)
			INNER JOIN dbo.MM_Material AS MM WITH (NOLOCK)
				ON MM.IdMaterial = SPD.IdMaterial		
			LEFT JOIN PV_MM_MaterialUnidad AS U WITH (NOLOCK)
				ON U.IdUnidad = SPD.IdUnidad
			LEFT JOIN DG_Domicilio AS D WITH (NOLOCK)
				ON D.IdDomicilio=SPD.IdDomicilioEntrega
			LEFT JOIN dbo.DG_TipoDomicilio TD WITH (NOLOCK)
				ON TD.IdTipoDomicilio = D.IdTipoDomicilio
			LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS S WITH (NOLOCK)
				ON S.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
			LEFT JOIN dbo.CC_CentroCosto AS CC WITH (NOLOCK)
				ON CC.IdCentroCosto = S.IdCentroCosto
			LEFT JOIN Adinco.dbo.CO_Instalacion AS I WITH (NOLOCK)
				ON I.IdInstalacion = S.IdInstalacion
			LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LP WITH (NOLOCK)
				ON LP.IdLineaPresupuestoMes = S.IdLineaPresupuesto
			LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS T WITH (NOLOCK)
				ON T.IdTareaPetrolera = LP.IdTareaPetrolera
			LEFT JOIN dbo.MM_SolPedArchivoAdjuntoMaterial AS ADMS WITH (NOLOCK)
				ON ADMS.IdSolPedDetalle = SPD.IdSolicitudPedidoDetalle
		WHERE IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY CONCAT(
                 ' Descripción: ',
                 MM.DescripcionCorta,
                 ' Marca: ',
                 CASE
                 WHEN ISNULL(LEN(MM.Marca), 0) > 0 THEN
                 MM.Marca
                 ELSE
                 ' S/M'
                 END,
                 ' Modelo: ',
                 CASE
                 WHEN ISNULL(LEN(MM.Modelo), 0) > 0 THEN
                 MM.Modelo
                 ELSE
                 ' S/M'
                 END,
                 ' No. Parte: ',
                 CASE
                 WHEN ISNULL(LEN(MM.NumeroParte), 0) > 0 THEN
                 MM.NumeroParte
                 ELSE
                 ' S/NP'
                 END
                 ),
                 CONCAT(
                 D.Calle,
                 ' ',
                 D.NoExterior,
                 ' ',
                 D.NoInterior,
                 ' ',
                 D.Colonia,
                 ' ',
                 D.Municipio,
                 ' ',
                 D.Estado,
                 ' ',
                 D.CodigoPostal,
                 ' (',
                 CAST(TD.TipoDomicilio AS NVARCHAR(MAX)),
                 ')'
                 ),
                 ISNULL(SPD.IdUnidad, 0),
                 dbo.Fn_RetornarMesProgramadoActividadConcat(LP.IdLineaPresupuestoMes),
                 SPD.IdSolicitudPedidoDetalle,
                 MM.IdMaterial,
                 SPD.Cantidad,
                 SPD.observaciones,
                 U.Unidad,
                 MM.DescripcionLarga,
                 S.IdSolicitudPedidoDetalleLineaPresupuesto,
                 CC.CentroCosto,
                 I.NombreInstalacion,
				 ADMS.IdSolPedMaterialDocumentoAdj,
				ADMS.NombreArchivoAdjunto;

		

		SELECT	
			SP.IdDocumento AS IdDocumento, 
			1 AS TipoDoc,
			SP.NombreDoc AS NombreDoc
		FROM dbo.MM_DocumentosSolPed AS SP WITH (NOLOCK)
		WHERE
			SP.IdSolPed = @IdSolicitudPedido
				AND Activo = 1;

		--CREATE TABLE #Gasto (IdTipoGasto int,TipoGasto nvarchar(300))

		 --INSERT INTO #Gasto (IdTipoGasto,TipoGasto) values(0, '-- Seleccione un opción ---')

		-- INSERT INTO #Gasto 
  --       SELECT IdTipoGasto,
  --              TipoGasto
		--FROM MM_TipoGastos
		-- ORDER BY IdTipoGasto ASC 

		-- SELECT
		--	IdTipoGasto AS id,
		--	TipoGasto AS text
		--FROM #Gasto;

		SELECT 
			IdTerminosYCondiciones AS id, 
			Nombre AS text
		FROM dbo.TC_TerminosYCondicionesDocV2
		WHERE IdProveedor = @IDPROVEEDORACTUAL AND IsActivo = 1

		--SELECT 
		--	IdPrioridad AS id,
		--	Nombre AS text
		--FROM dbo.TA_Prioridad 
		--ORDER BY Nombre


END
