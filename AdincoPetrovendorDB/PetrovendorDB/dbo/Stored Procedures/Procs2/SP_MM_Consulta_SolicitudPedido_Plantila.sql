USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_Consulta_SolicitudPedido_Plantila
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/11/2019
-- Description:	consultar datos de una plantilla de solicitud de pedido  
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: <05/09/2023>
-- Description:	<Consultar de plantilla de la solped con columna IdLocalidad>
-- =============================================
-- Author:		Luis David
-- Create date: 05/10/2023
-- Description:	Petrovendor/2522 - Se obtiene la localidad de solped reciclada
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Consulta_SolicitudPedido_Plantila] --1012
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @IDCENTROCOSTO INT,
			@IDINSTALACION INT,
			@IDDOMICILIOENTREGA INT,
			@IDLINEAPRESUPUESTO INT;

	--VALIDAR UNICO CENTRO DE COSTO
	CREATE TABLE #tempCentroCosto(IdCentroCosto INT);

	INSERT INTO #tempCentroCosto
	SELECT 
		IdCentroCosto
	FROM dbo.MM_Plantilla_SolicitudPedidoDetalle  (NOLOCK)
	WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
		AND Activo = 1
	GROUP BY IdCentroCosto;

	SET @IDCENTROCOSTO = (SELECT COUNT(IdCentroCosto) FROM #tempCentroCosto);

	IF @IDCENTROCOSTO = 1
	BEGIN
		
		SET @IDCENTROCOSTO = (SELECT 
								IdCentroCosto 
							FROM dbo.MM_Plantilla_SolicitudPedidoDetalle   (NOLOCK)
							WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
								AND Activo = 1
							GROUP BY IdCentroCosto)

	END
	ELSE
	BEGIN
		SET @IDCENTROCOSTO = 0;
	END;

	--VALIDAR UNICO DOMICILIO DE ENTREGA
	CREATE TABLE #tempDomicilioEntrega(IdDomicilioEntrega INT);

	INSERT INTO #tempDomicilioEntrega
	SELECT 
		IdDomicilioEntrega 
	FROM dbo.MM_Plantilla_SolicitudPedidoDetalle   (NOLOCK)
	WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
		AND Activo = 1
	GROUP BY IdDomicilioEntrega;

	SET @IDDOMICILIOENTREGA = (SELECT COUNT(IdDomicilioEntrega) FROM #tempDomicilioEntrega);

	IF @IDDOMICILIOENTREGA = 1
	BEGIN
		
		SET @IDDOMICILIOENTREGA = (SELECT 
										IdDomicilioEntrega 
									FROM dbo.MM_Plantilla_SolicitudPedidoDetalle   (NOLOCK)
									WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
										AND Activo = 1
									GROUP BY IdDomicilioEntrega)

	END
	ELSE
	BEGIN
	    SET @IDDOMICILIOENTREGA = 0;
	END;

	--VALIDAR UNICA LINEA DE PRESUPUESTO
	CREATE TABLE #tempLineaPresupuesto(IdLineaPresupuesto INT);

	INSERT INTO #tempLineaPresupuesto
	SELECT 
		IdLineaPresupuesto 
	FROM dbo.MM_Plantilla_SolicitudPedidoDetalle   (NOLOCK)
	WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
		AND Activo = 1
	GROUP BY IdLineaPresupuesto

	SET @IDLINEAPRESUPUESTO = (SELECT COUNT(IdLineaPresupuesto) FROM #tempLineaPresupuesto);

	IF @IDLINEAPRESUPUESTO = 1
	BEGIN
		
		SET @IDLINEAPRESUPUESTO = (SELECT 
										IdLineaPresupuesto 
									FROM dbo.MM_Plantilla_SolicitudPedidoDetalle 
									WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
										AND Activo = 1
									GROUP BY IdLineaPresupuesto);

	END
	ELSE
	BEGIN
	    SET @IDLINEAPRESUPUESTO = 0;
	END

	--VALIDAR UNICA INSTALACION
	CREATE TABLE #tempInstalacion(IdIntalacion INT);

	INSERT INTO #tempInstalacion
	SELECT 
		IdInstalacion 
	FROM dbo.MM_Plantilla_SolicitudPedidoDetalle   (NOLOCK)
	WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
		AND Activo = 1
	GROUP BY IdInstalacion

	SET @IDINSTALACION = (SELECT COUNT(IdIntalacion) FROM #tempInstalacion);

	IF @IDINSTALACION = 1
	BEGIN
		
		SET @IDINSTALACION = (SELECT 
								IdInstalacion 
							FROM dbo.MM_Plantilla_SolicitudPedidoDetalle   (NOLOCK)
							WHERE IdPlantillaSolicitudPedido = @IdSolicitudPedido
								AND Activo = 1
							GROUP BY IdInstalacion)

	END
	ELSE
	BEGIN
		SET @IDINSTALACION = 0;
	END;
		
	SELECT 
	SP.IdPeriodo,--0
	SP.IdPresupuesto,--1
	SP.MotivoUrgencia,--2
	SP.IdPrioridadSolicitante,--3
	SP.IdTipoSolicitudPedido,--4
	SP.FechaEntregaRequerida,--5
	SP.FechaEntregaFinRequerida,--6
	SP.IdContrato,--7
	SP.AdjudicableParcialmente,--8
	SP.UnaSolaEntregaRequerida,--9
	SP.EntregasParciales,--10
	ISNULL(SP.FechaEntregaFinRequerida, GETDATE()) AS FechaEntregaFinRequerida,--11
	SP.IdPlantillaSolicitudPedido,--12,
	ISNULL(@IDCENTROCOSTO,0) AS IdCentroCosto,--13
	ISNULL(@IDINSTALACION,0) AS IdInstalacion,--14
	ISNULL(@IDDOMICILIOENTREGA,0) AS IdDomicilioEntrega,--15
	ISNULL(@IDLINEAPRESUPUESTO,0) AS IdLineaPresupuesto,--16
	SP.IdMatrizEvaluacion,
	SP.IdPorcentajeETEC,
	ISNULL(SP.IdLocalidad,0) AS IdLocalidad,
	L.Nombre AS 'Localidad'
	FROM dbo.MM_Plantillas_SolicitudPedido AS SP   (NOLOCK)
	LEFT JOIN MM_Localidades L (NOLOCK) ON
	SP.IdLocalidad = L.Id
	WHERE SP.IdPlantillaSolicitudPedido = @IdSolicitudPedido;

END
