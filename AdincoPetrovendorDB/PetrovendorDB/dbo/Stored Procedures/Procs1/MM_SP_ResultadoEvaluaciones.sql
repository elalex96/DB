-- =============================================
-- Author:		<Jose Roman>							
-- Updated date: <12/01/2018>									
-- Description: <Calculo final para Evaluaciones tecnico/economico>			
--**************************************************************
-- Author:		<Pedro Acuña>							
-- Updated date: <22/01/2019>									
-- Description: <Se agrega como filtro el contrato>			
--**************************************************************
CREATE PROCEDURE [dbo].[MM_SP_ResultadoEvaluaciones] --12586
	@IdSolicitudPedido INT,
/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = NULL	,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
/*-------------------------------------------------------------*/
AS
BEGIN

	DECLARE @ID_MONEDA_DLS INT = 2 

	CREATE TABLE #ResultadosProveedores(IdRow INT, NombreProveedor NVARCHAR(MAX),IdProveedor INT, RCF NVARCHAR(MAX), IdPeticionOferta INT, MejorOferta BIT, PrecioTotal MONEY, ResultadoEG FLOAT, ResultadoET FLOAT, ResultadoEvaluaciones NVARCHAR(MAX), ResultadoEconomico NVARCHAR(MAX), Total NVARCHAR(MAX), Cotizado NVARCHAR(MAX))
	CREATE TABLE #MATERIALES_COSTO_MENOR(IdProveedor INT, PrecioTotal FLOAT)
	CREATE TABLE #MATERIALES_COSTO_MENOR_DLS(IdProveedor int, PrecioTotal float)
		
	INSERT INTO #ResultadosProveedores
		 SELECT ROW_NUMBER() OVER(ORDER BY P.IdProveedor ASC) AS Row#, P.RazonSocial +' '+ ISNULL(P.RegimenCapital, '') AS Razonsocial, P.IdProveedor,RFC, PO.IdPeticionOferta,0,0,0,0,N'',N'',N'',N''
		 FROM MM_PeticionOferta PO
		 INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
		 INNER JOIN S_Proveedor AS P ON P.IdProveedor= PO.IdSubcontratista
		 WHERE SP.IdSolicitudPedido = @IdSolicitudPedido AND SP.IdContrato = @IdContrato
		 ORDER BY P.Razonsocial

	CREATE TABLE #TIPO_CAMBIO(TipoCambio DECIMAL(12,4),Fecha datetime, IdMoneda int)
	INSERT INTO  #TIPO_CAMBIO  ---
		SELECT  [dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()),GETDATE(), POD.IdMoneda
		FROM dbo.MM_PeticionOfertaDetalle POD 
		INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta=POD.IdPeticionOferta
		WHERE PO.IdSolicitudPedido =@IdSolicitudPedido AND PO.Cotizado IS NOT NULL AND POD.IdMoneda IS NOT NULL
		GROUP BY  [dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()), POD.IdMoneda
		ORDER BY POD.IdMoneda ASC

	INSERT INTO #MATERIALES_COSTO_MENOR
		SELECT PR.IdProveedor, 
			CASE WHEN POD.IdMoneda <> @ID_MONEDA_DLS THEN  
				SUM( ISNULL(((ISNULL(POD.PrecioUnitario,0)/ISNULL(TC.TipoCambio,1))*Disponibilidad),0))					
			ELSE  
					SUM( ISNULL((POD.PrecioUnitario*Disponibilidad),0))  END AS MENOR_PRECIO --,
				--POD.PrecioUnitario	,	POD.IdMoneda ,	Disponibilidad	, TCD.TipoCambio	, PO.FechaFinalizado			
		FROM S_Proveedor AS PR
		--INNER JOIN #PROVEEDORES AS PV ON PV.IdProveedor = PR.IdProveedor
		INNER JOIN MM_PeticionOferta AS PO ON PO.IdSubcontratista = PR.IdProveedor
		INNER JOIN MM_PeticionOfertaDetalle AS POD ON  POD.IdPeticionOferta = PO.[IdPeticionOferta]				
		LEFT JOIN #TIPO_CAMBIO AS TC ON TC.IdMoneda= POD.IdMoneda			
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido AND PO.COTIZADO = 1 AND POD.Cotizado = 1 ---@IdSolicitudPedido
		AND PR.IdProveedor NOT IN  (SELECT  IdProveedor
								FROM S_Proveedor AS PR 
								INNER JOIN MM_PeticionOferta AS PO ON PO.IdSubcontratista = PR.IdProveedor
								INNER JOIN MM_PeticionOfertaDetalle AS POD ON  POD.IdPeticionOferta = PO.[IdPeticionOferta]
								WHERE PO.IdSolicitudPedido =@IdSolicitudPedido   AND PO.COTIZADO =1 AND ISNULL(POD.Cotizado,0) = 0 ----@IdSolicitudPedido
								GROUP BY IdProveedor) 
		GROUP BY PR.IdProveedor , POD.IdMoneda---,POD.PrecioUnitario		,POD.IdMoneda ,Disponibilidad	,TCD.TipoCambio ,PO.FechaFinalizado
		ORDER BY MENOR_PRECIO, PR.IdProveedor  ASC

	INSERT INTO #MATERIALES_COSTO_MENOR_DLS
				SELECT IdProveedor,SUM(PrecioTotal)
				FROM #MATERIALES_COSTO_MENOR
				GROUP BY IdProveedor

	DECLARE @IdEvaluacion INT,
			@PorcentajeET FLOAT,
			@PorcentajeEC FLOAT,
			@PorcEvaluacionG FLOAT,
			@PorcEvaluacionT FLOAT,
			@MenorPrecio FLOAT,
			@MejorResultado FLOAT,
			@IdMatriz float

	SET @IdEvaluacion = (SELECT CAST(NombreDoc AS INT) FROM dbo.TA_DocMatrizOperacion WHERE IdOperacion = @IdSolicitudPedido)
	SET @PorcentajeET = (SELECT PorcentajeET FROM dbo.TA_DocMatrizOperacion WHERE IdOperacion = @IdSolicitudPedido)
	SET @PorcentajeEC = (SELECT PorcentajeEC FROM dbo.TA_DocMatrizOperacion WHERE IdOperacion = @IdSolicitudPedido)
	SET @PorcEvaluacionG = (SELECT Ponderacion FROM dbo.ME_TiposMatriz WHERE IdTipoEvaluacion = 2)
	SET @PorcEvaluacionT = (SELECT Ponderacion FROM dbo.ME_TiposMatriz WHERE IdTipoEvaluacion = 1)
		
	--Se Agrega el resultado de la Evaluacion General
	UPDATE rp
		SET rp.ResultadoEG = reg.Resultado
		FROM #ResultadosProveedores rp
			INNER JOIN dbo.ME_ResultadoEG reg ON reg.IdProveedor = rp.IdProveedor
		WHERE rp.IdProveedor = reg.IdProveedor

	--Se agrega los totales de cotizaciones
	UPDATE rp
		SET rp.PrecioTotal = m.PrecioTotal
		FROM #ResultadosProveedores rp
			INNER JOIN #MATERIALES_COSTO_MENOR_DLS m ON m.IdProveedor = rp.IdProveedor
		WHERE rp.IdProveedor = m.IdProveedor
	
	--Se agrega los resultados de la Evaluacion Tecnica si se solicito
	if(@IdEvaluacion <> 0)
	begin
		UPDATE rp
			SET rp.ResultadoET = rm.Resultado
			FROM #ResultadosProveedores rp
				INNER JOIN dbo.ME_ResultadoMatriz rm ON rm.IdProveedorEvaluado = rp.IdProveedor AND rm.IdMatrizEvaluacion = @IdEvaluacion AND rm.IdPedido = rp.IdPeticionOferta
			WHERE rp.IdProveedor = rm.IdProveedorEvaluado
	END

	--Se obtiene la cotizacion mas baja y se calcula Evaluacion Economica
	SET @MenorPrecio = (SELECT MIN(PrecioTotal) FROM #ResultadosProveedores WHERE PrecioTotal <> 0) * @PorcentajeEC

	UPDATE rp
		SET rp.ResultadoEconomico = CAST((@MenorPrecio / rp.PrecioTotal) AS NVARCHAR(MAX))
		FROM #ResultadosProveedores rp
		WHERE rp.PrecioTotal <> 0

	--Se agrega 'No Aplica' a los proveedores que no cotizaron
	UPDATE rp
		SET rp.ResultadoEconomico = N'No Aplica',
			rp.Total = N'No Aplica'
		FROM #ResultadosProveedores rp
		WHERE rp.PrecioTotal = 0

	--Se calcula la Evaluacion General
	if(@IdEvaluacion <> 0)
	begin
		UPDATE rp
			SET rp.ResultadoEvaluaciones = CAST(((rp.ResultadoEG * @PorcEvaluacionG / 100) + (rp.ResultadoET * @PorcEvaluacionT / 100)) AS NVARCHAR(MAX))
			FROM #ResultadosProveedores rp

		UPDATE rp
			SET rp.ResultadoEvaluaciones = CAST((CAST(rp.ResultadoEvaluaciones AS FLOAT) * @PorcentajeET) / 100 AS NVARCHAR(MAX))
			FROM #ResultadosProveedores rp
	END
    ELSE
    BEGIN
		UPDATE rp
			SET rp.ResultadoEvaluaciones = CAST((CAST(rp.ResultadoEG AS FLOAT) * @PorcentajeET) / 100 AS NVARCHAR(MAX))
			FROM #ResultadosProveedores rp
	END
    

	UPDATE rp
		SET rp.Total = CAST((CAST(rp.ResultadoEvaluaciones AS FLOAT) + CAST(rp.ResultadoEconomico AS FLOAT)) AS NVARCHAR(MAX))
		FROM #ResultadosProveedores rp
		WHERE rp.PrecioTotal <> 0
		
	SET @MejorResultado = (SELECT MAX(CAST(Total AS FLOAT)) FROM #ResultadosProveedores WHERE PrecioTotal <> 0)
	
	UPDATE rp
		SET rp.MejorOferta = 1
		FROM #ResultadosProveedores rp
		WHERE rp.Total = CAST(@MejorResultado AS NVARCHAR(MAX))
			
	UPDATE rp
		SET rp.ResultadoEconomico = CAST(ROUND(CAST(rp.ResultadoEconomico AS FLOAT),2,1) AS NVARCHAR(MAX)) + ' %',
			rp.Total = CAST(ROUND(CAST(rp.Total AS FLOAT),2,1) AS NVARCHAR(MAX)) + ' %'
		FROM #ResultadosProveedores rp
		WHERE rp.PrecioTotal <> 0

	UPDATE rp
		SET rp.ResultadoEvaluaciones = CAST(ROUND(CAST(rp.ResultadoEvaluaciones AS FLOAT),2,1) AS NVARCHAR(max)) + ' %'
		FROM #ResultadosProveedores rp

	UPDATE rp
		SET rp.Cotizado = CASE WHEN rp.PrecioTotal = 0 THEN N'No aplica' ELSE N'$' + CAST(rp.PrecioTotal AS NVARCHAR(max)) END 
		FROM #ResultadosProveedores rp

	SELECT * FROM #ResultadosProveedores

END

--SELECT * FROM dbo.ME_TiposMatriz




