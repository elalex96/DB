-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/04/2020>
-- Description:	<Guardado de la reclasificacion>
-- =============================================
CREATE PROCEDURE [dbo].[SP_APR_GuardadoReclasificacionAceptacionDetalle]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT,
	@IdAceptacionPedidoDetalle INT,
	@IdUsuario INT,
	@IdProveedor INT,
	@Reclasificacion Reclasificacion READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDPEDIDODETALLE INT;
	DECLARE @TOTALROWS INT;
	DECLARE @CONTROWS INT = 1;
	DECLARE @CANTIDADAP FLOAT;
	DECLARE @LINEAPRESUPUESTOAP INT;
	DECLARE @IDINSTALACIONAP INT;
	DECLARE @IDACEPTACIONPEDIDODETALLERECLASIFICADO INT;
	DECLARE @IDMATERIAL INT;
	DECLARE @PCN FLOAT;
	DECLARE @PCN_AGREGADO BIT;
	DECLARE @CLASIFICACION_CN INT;

	--RECLACIFICACION CON ROWNUMBER
	DECLARE @RECLASIFICACIONAP TABLE (
		IdRow INT IDENTITY(1,1),
		Cantidad FLOAT,
		LineaPresupuesto INT,
		IdInstalacion INT
	);

	INSERT INTO @RECLASIFICACIONAP
	SELECT
		Cantidad,
		LineaPresupuesto,
		IdInstalacion
	FROM @Reclasificacion

	SET @TOTALROWS = (SELECT COUNT(IdRow) FROM @RECLASIFICACIONAP);

	SET @IDPEDIDODETALLE = (SELECT
								IdPedidoDetalle
							FROM dbo.MM_AceptacionPedidoDetalle
							WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle);

	SET @IDMATERIAL = (SELECT
							PD.IdMaterialVendedor
						FROM dbo.MM_PedidoDetalle AS PD
						WHERE PD.IdPedidoDetalle = @IDPEDIDODETALLE);

	--SE OBTIENE EL CONTENIDO NACIONAL CALCULADO
	SET @PCN = (SELECT PCN FROM dbo.MM_AceptacionPedidoDetalle WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle);

	SET @PCN_AGREGADO = (SELECT PCN_Agregado FROM dbo.MM_AceptacionPedidoDetalle WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle);

	SET @CLASIFICACION_CN = (SELECT ClasificacionCN FROM dbo.MM_AceptacionPedidoDetalle WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle);

	--RECORRIDO DE LAS NUEVAS ACEPTACIONES
	WHILE @CONTROWS <= @TOTALROWS
	BEGIN
	    
		SET @CANTIDADAP = (SELECT Cantidad FROM @RECLASIFICACIONAP WHERE IdRow = @CONTROWS);
		SET @LINEAPRESUPUESTOAP = (SELECT LineaPresupuesto FROM @RECLASIFICACIONAP WHERE IdRow = @CONTROWS);
		SET @IDINSTALACIONAP = (SELECT IdInstalacion FROM @RECLASIFICACIONAP WHERE IdRow = @CONTROWS);

		--GUARDADO DE LAS ACEPTACIONES
		INSERT INTO dbo.MM_AceptacionPedidoDetalle
		(
			IdAceptacionPedido,
			IdPedidoDetalle,
			Cantidad,
			CreadoPor,
			Creado,
			Excedente,
			IdAnterior,
			PCN,
			PCN_Agregado,
			ClasificacionCN,
			IsReclasificada
		)
		VALUES
		(
			@IdAceptacionPedido,
			@IDPEDIDODETALLE,
			@CANTIDADAP,
			@IdUsuario,
			GETDATE(),
			0,
			@IdAceptacionPedidoDetalle,
			@PCN,
			@PCN_AGREGADO,
			@CLASIFICACION_CN,
			1
		);

		SET @IDACEPTACIONPEDIDODETALLERECLASIFICADO = SCOPE_IDENTITY();

		--GUARDADO DE LA LINEA DE PRESUPUESTO DE LA NUEVA ACEPTACION
		INSERT INTO dbo.MM_AceptacionPedidoDetalleInstalacion
		(
		    IdAceptacionPedido,
		    IdAceptacionPedidoDetalle,
		    IdPedidoDetalle,
		    IdProveedor,
		    IdMaterial,
		    Cantidad,
		    IdInstalacion,
		    IdLineaPresupuesto
		)
		VALUES
		(   
			@IdAceptacionPedido,   -- IdAceptacionPedido - int
		    @IDACEPTACIONPEDIDODETALLERECLASIFICADO,   -- IdAceptacionPedidoDetalle - int
		    @IDPEDIDODETALLE,   -- IdPedidoDetalle - int
		    @IdProveedor,   -- IdProveedor - int
		    @IDMATERIAL,   -- IdMaterial - int
		    @CANTIDADAP, -- Cantidad - float
		    @IDINSTALACIONAP,   -- IdInstalacion - int
		    @LINEAPRESUPUESTOAP    -- IdLineaPresupuesto - int
		 );

		 INSERT INTO dbo.MM_PCN_ValoresPesos
		 (
		     IdAceptacionPedidoDetalle,
		     VNMO_SueldoNacional,
		     VMO_Sueldo,
		     CreadoPor,
		     CreadoEl,
		     EditadoPor,
		     EditadoEl,
		     IdTipoNacionalidad,
		     IdTipoCriterio,
		     IdCatalogoHidrocarburos,
		     IdTipoMaterialServicio,
		     FraccionArancelaria,
		     IdModificadoPorSP,
		     ValorFactura,
		     IdClasificacionCN,
		     EditadorProveedorPor
		 )
		 SELECT
			@IDACEPTACIONPEDIDODETALLERECLASIFICADO,
			VNMO_SueldoNacional,
		    VMO_Sueldo,
		    CreadoPor,
		    CreadoEl,
		    EditadoPor,
		    EditadoEl,
		    IdTipoNacionalidad,
		    IdTipoCriterio,
		    IdCatalogoHidrocarburos,
		    IdTipoMaterialServicio,
		    FraccionArancelaria,
		    IdModificadoPorSP,
		    ValorFactura,
		    IdClasificacionCN,
		    EditadorProveedorPor
		 FROM dbo.MM_PCN_ValoresPesos
		 WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle

		SET @CONTROWS = @CONTROWS + 1;

	END;

	--RESPALDO DE LA ACEPTACION RECLASIFICADA
	INSERT INTO dbo.MM_AceptacionPedidoDetalleEliminada
	(
	    IdAceptacionPedido,
	    IdAceptacionPedidoDetalle,
	    IdPedidoDetalle,
	    IdProveedor,
	    CreadoPor,
	    IdMaterial,
	    Cantidad,
	    IdInstalacion,
	    IdLineaPresupuesto,
	    CreadoEl,
	    EliminadoEl,
	    EliminadoPor
	)
	SELECT
		APD.IdAceptacionPedido,
		APD.IdAceptacionPedidoDetalle,
		APD.IdPedidoDetalle,
		APDI.IdProveedor,
		APD.CreadoPor,
		APDI.IdMaterial,
		APD.Cantidad,
		APDI.IdInstalacion,
		APDI.IdLineaPresupuesto,
		APD.Creado,
		GETDATE(),
		@IdUsuario
	FROM dbo.MM_AceptacionPedidoDetalle AS APD
	LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI
		ON APDI.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
	WHERE APD.IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle;

	--ELIMINADO DE LA ACEPTACION RECLASIFICADA
	DELETE dbo.MM_AceptacionPedidoDetalleInstalacion WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle;
	DELETE dbo.MM_PCN_ValoresPesos WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle;
	DELETE dbo.MM_AceptacionPedidoDetalle WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle;
	
	SELECT 'success'
END
