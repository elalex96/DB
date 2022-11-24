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
	DECLARE @WDEA_MecContratacion NVARCHAR(100);

	SET LANGUAGE spanish; 

	SET @IDPROVEEDORACTUAL = (SELECT IdProveedor FROM dbo.MM_SolicitudPedido 
							WHERE IdSolicitudPedido = @IdSolicitudPedido);
	SET @RFCPROVEEDORACTUAL = (SELECT TOP 1 RFC FROM dbo.S_Proveedor
								WHERE IdProveedor = @IDPROVEEDORACTUAL);
	
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

	SELECT @WDEA_MecContratacion= RTRIM(LTRIM(UPPER(WPDI.MECANISMO_CONTRATACION)))
	FROM MM_SolicitudPedido SP (NOLOCK)
	JOIN MM_Pedido P  (NOLOCK)
		ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	JOIN WDEA_PurchasingDocumentsImportados WPDI (NOLOCK)
		ON P.IdPedido = WPDI.IdPedidoADINCO 
	WHERE SP.IdSolicitudPedido=@IdSolicitudPedido 
	GROUP BY WPDI.MECANISMO_CONTRATACION 

	SELECT
		@IDPERIODO = SP.IdPeriodo, 
		@IDPRESUPUESTO = SP.IdPresupuesto ,
		@IDLINEAPRESUPUESTO = SP.IdLineaPresupuesto,
		@IdContrato = SP.IdContrato
	FROM MM_SolicitudPedido AS SP WITH (NOLOCK)
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;

	SET @PERIODO = (SELECT Top 1 
						NombrePeriodo  as NombreParaMostrar
					FROM Adinco.dbo.CO_PeriodoContrato  (NOLOCK)
					WHERE (IdContrato = @IdContrato 
							AND IdPeriodo=@IdPeriodo));

	SET @PRESUPUESTO  = (SELECT ISNULL((SELECT Top 1 CONCAT(P.Nombre, ' [', P.IdPresupuestoCNH, ']')AS Nombre
							FROM Adinco.dbo.CO_ProgramaActividad AS PA  (NOLOCK)
								JOIN Adinco.dbo.CO_PeriodoContrato AS PC   (NOLOCK)
									ON PA.IdPeriodoContrato = PC.IdPeriodo
								JOIN Adinco.dbo.CO_Presupuesto AS P  (NOLOCK)
									ON PA.IdProgramaActividad = P.IdProgramaActividad
							WHERE(PC.IdPeriodo = @IdPeriodo 
							    AND P.IdPresupuesto =@IdPresupuesto )
								AND (P.Activo = 1)),'No disponible') AS Presupuesto)

	SET @LINEAPRESUPUESTO =  (SELECT ISNULL(( SELECT Top 1
                CONCAT(RIGHT('00'+CAST(MONTH(LPM.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', 
				DATENAME(month, LPM.AC_PRESUP_MES), ' ', 
				YEAR(LPM.AC_PRESUP_MES), ' - ', 
				APCNH.DescripcionActividadPetrolera, '(',
				SBP.SubactividadPetrolera,')') AS Mes_Presupuestado
		FROM Adinco.dbo.CO_LineaPresupuestoMes AS LPM  (NOLOCK)
              LEFT OUTER JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS APCNH  (NOLOCK) 
				ON  LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
              LEFT OUTER JOIN Adinco.dbo.CO_SubactividadPetrolera AS SBP   (NOLOCK)
				ON LPM.IdSubactividadPetrolera = SBP.IdSubactividadPetrolera  
              LEFT OUTER JOIN Adinco.dbo.CO_TareaPetrolera AS TP   (NOLOCK)
				ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
              LEFT OUTER JOIN Adinco.dbo.CO_ActividadCIEP AS ACIEP  (NOLOCK)
				ON LPM.IdActividad = ACIEP.IdActividad
              LEFT OUTER JOIN Adinco.dbo.CO_TipoServicio AS TS  (NOLOCK)
				ON LPM.IdTipoServicio = TS.ID_TIPOSER
              LEFT OUTER JOIN Adinco.dbo.CO_SubactividadCIEP AS SACIEP  (NOLOCK)
				ON LPM.IdSubactividad = SACIEP.IdSubactividad
              LEFT OUTER JOIN Adinco.dbo.CO_Servicio AS S  (NOLOCK)
				ON LPM.IdServicio = S.IdServicio
              LEFT OUTER JOIN Adinco.dbo.CO_Area AS A  (NOLOCK)
				ON LPM.IdArea = A.IdArea
              LEFT OUTER JOIN Adinco.dbo.CO_Instalacion AS I  (NOLOCK)
				ON LPM.IdInstalacion = I.IdInstalacion
              LEFT OUTER JOIN Adinco.dbo.CO_Registro AS R  (NOLOCK)
				ON LPM.IdLineaPresupuestoMes = R.IdPrograma
              LEFT OUTER JOIN Adinco.dbo.CO_ClasificacionAnexo4 AS CA4  (NOLOCK)
				ON LPM.IdAnexo4 = CA4.IdAnexo4
              LEFT OUTER JOIN Adinco.dbo.FI_Factura AS F  (NOLOCK)
				ON F.IdFactura = R.IdFactura
              LEFT OUTER JOIN Adinco.dbo.CO_TipoCambioMensual AS TCM  (NOLOCK)
				ON F.IdMoneda = TCM.IdMoneda 
					AND  MONTH(R.MesPresentacion) = TCM.IdMes 
                    AND YEAR(R.MesPresentacion) = TCM.Anio 
              LEFT OUTER JOIN Adinco.dbo.CO_RubroInterno AS RI 
				ON LPM.IdRubroInterno = RI.IdRubroInterno
         WHERE(LPM.IdPresupuesto =@IdPresupuesto ) 
			AND  LPM.IdLineaPresupuestoMes=@IdLineaPresupuesto ),'No Disponible') AS LINEA_PRESUPUESTO);

	SELECT
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia, 			
			FORMAT(SP.FechaAlta ,'dd/MM/yyyy HH:mm:ss tt') AS FechaAlta,
			SP.AdjudicableParcialmente, 			
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
			ISNULL(SP.IdTipoProceso,2) AS IdTipoMetodoCompra,
			CASE WHEN ISNULL(@WDEA_MecContratacion,'')='L' THEN 
				'Licitación'
			ELSE 
				'Mercadeo'
			END AS MecanismoContratacion
		FROM		MM_SolicitudPedido AS SP WITH (NOLOCK)
		JOIN	MM_TipoSolicitudPedido AS TSP WITH (NOLOCK)
			ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
		JOIN	TA_Operacion AS TAO WITH (NOLOCK)
			ON  SP.IdSolicitudPedido = TAO.IdDocumento 
			AND TAO.IdTipoOperacion = 2 --> CTE APROBACION DE PEDIDO
		JOIN	TA_Estatus AS TE WITH (NOLOCK)
			ON TAO.IdEstatusOperacion = TE.IdEstatus 
		JOIN	MM_PrioridadSolicitudPedido AS PSP WITH (NOLOCK)
			ON  SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido 
		JOIN	S_Usuario AS U WITH (NOLOCK)
			ON TAO.IdAsignador = U.IdUsuario 
		JOIN	TA_TipoOperacion AS TiOp WITH (NOLOCK)
			ON  TAO.IdTipoOperacion = TiOp.IdTipoOperacion
		LEFT JOIN	CC_CentroCosto AS CC WITH (NOLOCK)
			ON  SP.IdCentroCosto = CC.IdCentroCosto 
		LEFT JOIN	MM_TerminoComercio AS TC WITH (NOLOCK)
			ON  SP.IdTerminoInternacionales = TC.IdTerminoComercio
		LEFT JOIN	MM_TipoGastos AS TG WITH (NOLOCK)
			ON  SP.IdTipoGasto = TG.IdTipoGasto 
		LEFT JOIN dbo.S_Proveedor AS PR WITH (NOLOCK)
			ON SP.IdProveedor = PR.IdProveedor 
		LEFT JOIN dbo.S_Proveedor AS OPR WITH (NOLOCK)
			ON  OPR.IdProveedor = SP.IdProveedor 
		WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;

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
			S.IdSolicitudPedidoDetalleLineaPresupuesto,
			CC.CentroCosto,
			I.NombreInstalacion,
			dbo.Fn_RetornarMesProgramadoActividadConcat(LP.IdLineaPresupuestoMes) AS SubActividad,
			ADMS.IdSolPedMaterialDocumentoAdj,
			ADMS.NombreArchivoAdjunto
		FROM MM_SolicitudPedidoDetalle AS SPD WITH (NOLOCK)
			JOIN dbo.MM_Material AS MM WITH (NOLOCK)
				ON  SPD.IdMaterial = MM.IdMaterial 	
			LEFT JOIN PV_MM_MaterialUnidad AS U WITH (NOLOCK)
				ON  SPD.IdUnidad = U.IdUnidad
			LEFT JOIN DG_Domicilio AS D WITH (NOLOCK)
				ON SPD.IdDomicilioEntrega = D.IdDomicilio
			LEFT JOIN dbo.DG_TipoDomicilio TD WITH (NOLOCK)
				ON  D.IdTipoDomicilio = TD.IdTipoDomicilio 
			LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS S WITH (NOLOCK)
				ON  SPD.IdSolicitudPedidoDetalle = S.IdSolicitudPedidoDetalle 
			LEFT JOIN dbo.CC_CentroCosto AS CC WITH (NOLOCK)
				ON  S.IdCentroCosto = CC.IdCentroCosto 
			LEFT JOIN Adinco.dbo.CO_Instalacion AS I WITH (NOLOCK)
				ON S.IdInstalacion = I.IdInstalacion 
			LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LP WITH (NOLOCK)
				ON S.IdLineaPresupuesto = LP.IdLineaPresupuestoMes 
			LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS T WITH (NOLOCK)
				ON  LP.IdTareaPetrolera = T.IdTareaPetrolera 
			LEFT JOIN dbo.MM_SolPedArchivoAdjuntoMaterial AS ADMS WITH (NOLOCK)
				ON  SPD.IdSolicitudPedidoDetalle = ADMS.IdSolPedDetalle 
		WHERE IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY 
                 MM.DescripcionCorta,              
                 MM.Marca,
                 MM.Modelo,            
                 MM.NumeroParte,               
                 D.Calle,              
                 D.NoExterior,               
                 D.NoInterior,              
                 D.Colonia,              
                 D.Municipio,               
                 D.Estado,                 
                 D.CodigoPostal,                
                 TD.TipoDomicilio,             
                 SPD.IdUnidad, 
                 LP.IdLineaPresupuestoMes,
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


		SELECT 
			IdTerminosYCondiciones AS id, 
			Nombre AS text
		FROM dbo.TC_TerminosYCondicionesDocV2  (NOLOCK)
		WHERE IdProveedor = @IDPROVEEDORACTUAL AND IsActivo = 1

	
END