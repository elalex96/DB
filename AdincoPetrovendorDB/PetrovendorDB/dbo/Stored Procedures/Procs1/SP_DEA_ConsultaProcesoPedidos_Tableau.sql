-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/06/2020>
-- Description:	<Procedimiento para llenar la vista de Tableu de reporte de DEA-PEDIDOS>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultaProcesoPedidos_Tableau]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @IDCONTRATO INT = (10038);

DECLARE @ACCION NVARCHAR(100);
DECLARE @FECHAANTERIOR DATETIME;
DECLARE @FECHANUEVA DATETIME;
DECLARE @TOTAL INT = 0;
DECLARE @CONT BIGINT = 1;
DECLARE @IDSOLICITUDPEDIDO INT = 0;
DECLARE @SOLICITUDESDEA TABLE (
								ID INT IDENTITY(1,1),
								IdSolicitudPedido INT, 
								CentroCosto NVARCHAR(100), 
								Requisitor NVARCHAR(100), 
								FechaRegistro DATETIME
								);

DECLARE @APROBACIONES TABLE(
							IdSolicitudPedido INT, 
							FechaAccion DATETIME, 
							Usuario NVARCHAR(100), 
							Accion NVARCHAR(100),
							Estatus NVARCHAR(100),
							Tiempo DECIMAL(5,2)
							);

DECLARE @CONSULTACOMPLETA TABLE( 
								ID INT IDENTITY(1,1),
								IdSolicitudPedido INT, 
								CentroCosto NVARCHAR(100), 
								Requisitor NVARCHAR(100), 
								FechaRegistro DATETIME,
								FechaAccion DATETIME, 
								Usuario NVARCHAR(100), 
								Accion NVARCHAR(100),
								Estatus NVARCHAR(100), 
								Tiempo DECIMAL(5,2)
								);

DECLARE @CENTROSCOSTOS TABLE(
							IdSolicitudPedido INT, 
							CentroCosto NVARCHAR(100), 
							IdCentroCosto INT,
							Aprobadores NVARCHAR(MAX)
							);

DECLARE @ESTATUS TABLE(
	IdEstado INT,
	Nombre NVARCHAR(100)
);

--INSERT INTO @ESTATUS
--(
--    IdEstado,
--    Nombre
--)
--VALUES
--(   1,  -- IdEstado - int
--    '1ra Aprobación Pendiente' -- Nombre - nvarchar(100)
--    )

INSERT INTO @CENTROSCOSTOS
SELECT DISTINCT
    SPC.IdSolicitudPedido,
    CC.CentroCosto,
	CC.IdCentroCosto,
	STUFF(
		(SELECT
			', ' + US.Nombre
		FROM dbo.DEA_UsuariosNotificar AS USND
			LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USND.IdUsuario
		WHERE USND.IdCentroCosto = CC.IdCentroCosto
			AND USND.Activo = 1
			GROUP BY US.Nombre
		FOR XML PATH('')),1,2,''
	)
FROM dbo.MM_SolicitudPedido AS SPC
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD 
        ON SPD.IdSolicitudPedido = SPC.IdSolicitudPedido
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
        ON SPLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
    LEFT JOIN dbo.CC_CentroCosto AS CC
        ON CC.IdCentroCosto = SPLP.IdCentroCosto
WHERE SPC.IdContrato = @IDCONTRATO
    AND (CC.CentroCosto IS NOT NULL OR CC.CentroCosto <> '');

DECLARE @CENTROSCOSTOSOT TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
INSERT INTO @CENTROSCOSTOSOT
SELECT DISTINCT
    SPC.IdSolicitudPedido,
    CC.CentroCosto
FROM dbo.MM_SolicitudPedido AS SPC
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
        ON SPD.IdSolicitudPedido = SPC.IdSolicitudPedido
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
        ON SPLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
    LEFT JOIN dbo.CC_CentroCosto AS CC
        ON CC.IdCentroCosto = SPLP.IdCentroCosto
WHERE SPC.IdContrato = @IDCONTRATO
    AND (CC.CentroCosto IS NOT NULL OR CC.CentroCosto <> '');

INSERT INTO @SOLICITUDESDEA
(
    IdSolicitudPedido,
    CentroCosto,
    Requisitor,
    FechaRegistro
)
SELECT --TOP 54
	SP.IdSolicitudPedido,
	CC.CentroCosto,
	US.Nombre AS Requisitor,
	SP.FechaAlta AS FechaRegistro
FROM dbo.MM_SolicitudPedido AS SP
LEFT JOIN @CENTROSCOSTOS AS CC 
	ON CC.IdSolicitudPedido = SP.IdSolicitudPedido
LEFT JOIN dbo.S_Usuario AS US 
	ON US.IdUsuario = SP.IdUsuarioSolicitante
LEFT JOIN @APROBACIONES AS APR
	ON APR.IdSolicitudPedido = SP.IdSolicitudPedido
WHERE CC.IdSolicitudPedido IS NOT NULL
	--AND SP.FechaAlta > '2020-01-04 00:00:00.00'
ORDER BY SP.FechaAlta DESC;

SET @TOTAL = (SELECT COUNT(ID) FROM @SOLICITUDESDEA);

WHILE @CONT <= @TOTAL
BEGIN
    
	SET @IDSOLICITUDPEDIDO = (SELECT IdSolicitudPedido FROM @SOLICITUDESDEA WHERE ID = @CONT);

	INSERT INTO @APROBACIONES
	(
		IdSolicitudPedido,
		FechaAccion,
		Usuario,
		Accion,
		Estatus
	)
	SELECT TOP 1 
		SP.IdSolicitudPedido,
		CASE 
			WHEN TA.IdEstatus = 7 THEN (SELECT TOP 1 
											TAI.FechaRegistro
										FROM dbo.MM_SolicitudPedido AS SPI
										LEFT JOIN dbo.TA_Operacion AS OPI 
											ON OPI.IdDocumento = SPI.IdSolicitudPedido 
											AND OPI.IdTipoOperacion = 2
										LEFT JOIN dbo.TA_Tarea AS TAI
											ON TAI.IdOperacion = OPI.IdOperacion
										LEFT JOIN dbo.TA_Estatus AS ETI
											ON ETI.IdEstatus = TAI.IdEstatus
										LEFT JOIN dbo.S_Usuario AS USI
											ON USI.IdUsuario = TAI.IdAprobador
										WHERE SPI.IdSolicitudPedido = SP.IdSolicitudPedido  AND 
											TAI.NoSecuencia = 1 AND 
											TAI.IdEstatus in (1,2,3,4,6)
										ORDER BY TAI.FechaRegistro DESC)
			ELSE FechaCambioEstatus
		END,
		US.Nombre,
		'1ra Aprobacion',
		ET.Nombre
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.TA_Operacion AS OP 
		ON OP.IdDocumento = SP.IdSolicitudPedido 
		AND OP.IdTipoOperacion = 2
	LEFT JOIN dbo.TA_Tarea AS TA
		ON TA.IdOperacion = OP.IdOperacion
	LEFT JOIN dbo.TA_Estatus AS ET
		ON ET.IdEstatus = TA.IdEstatus
	LEFT JOIN dbo.S_Usuario AS US
		ON US.IdUsuario = TA.IdAprobador
	WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
		TA.NoSecuencia = 1 AND 
		TA.IdEstatus in (1,2,3,4,6,7)
	ORDER BY TA.FechaRegistro ASC;


	

	IF (SELECT TOP 1
				TA.IdEstatus
		FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.TA_Operacion AS OP 
			ON OP.IdDocumento = SP.IdSolicitudPedido 
			AND OP.IdTipoOperacion = 2
		LEFT JOIN dbo.TA_Tarea AS TA
			ON TA.IdOperacion = OP.IdOperacion
		WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
			TA.NoSecuencia = 1 AND 
			TA.IdEstatus in (1,2,3,4,6,7)
		ORDER BY TA.FechaRegistro ASC) = 7
	BEGIN
	    
		INSERT INTO @APROBACIONES
		(
			IdSolicitudPedido,
			FechaAccion,
			Usuario,
			Accion,
			Estatus
		)
		SELECT TOP 1 
			@IDSOLICITUDPEDIDO,
			FechaCambioEstatus,
			US.Nombre,
			'1ra Reasignacion',
			ET.Nombre
		FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.TA_Operacion AS OP 
			ON OP.IdDocumento = SP.IdSolicitudPedido 
			AND OP.IdTipoOperacion = 2
		LEFT JOIN dbo.TA_Tarea AS TA
			ON TA.IdOperacion = OP.IdOperacion
		LEFT JOIN dbo.TA_Estatus AS ET
			ON ET.IdEstatus = TA.IdEstatus
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = TA.IdAprobador
		WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
			TA.NoSecuencia = 1 AND 
			TA.IdEstatus in (1,2,3,4,6)
			AND TA.Activo = 1
		ORDER BY TA.FechaRegistro ASC;

	END
	ELSE
	BEGIN
	    
		INSERT INTO @APROBACIONES
		(
			IdSolicitudPedido,
			FechaAccion,
			Usuario,
			Accion,
			Estatus
		)
		SELECT TOP 1 
			@IDSOLICITUDPEDIDO,
			NULL,
			'',
			'1ra Reasignacion',
			''

	END

	IF (SELECT TOP 1
				TA.IdEstatus
		FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.TA_Operacion AS OP 
			ON OP.IdDocumento = SP.IdSolicitudPedido 
			AND OP.IdTipoOperacion = 2
		LEFT JOIN dbo.TA_Tarea AS TA
			ON TA.IdOperacion = OP.IdOperacion
		WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
			TA.NoSecuencia = 2 AND 
			TA.IdEstatus in (1,2,3,4,6,7)
		ORDER BY TA.FechaRegistro ASC) IS NULL
	BEGIN
	    
		INSERT INTO @APROBACIONES
		(
			IdSolicitudPedido,
			FechaAccion,
			Usuario,
			Accion,
			Estatus
		)
		SELECT TOP 1 
			@IDSOLICITUDPEDIDO,
			NULL,
			'',
			'2da Aprobacion',
			''

	END
	ELSE
	BEGIN
	    
		INSERT INTO @APROBACIONES
	(
		IdSolicitudPedido,
		FechaAccion,
		Usuario,
		Accion,
		Estatus
	)
	SELECT TOP 1 
		@IDSOLICITUDPEDIDO,
		CASE 
			WHEN TA.IdEstatus = 7 THEN (SELECT TOP 1 
											TAI.FechaRegistro
										FROM dbo.MM_SolicitudPedido AS SPI
										LEFT JOIN dbo.TA_Operacion AS OPI 
											ON OPI.IdDocumento = SPI.IdSolicitudPedido 
											AND OPI.IdTipoOperacion = 2
										LEFT JOIN dbo.TA_Tarea AS TAI
											ON TAI.IdOperacion = OPI.IdOperacion
										LEFT JOIN dbo.TA_Estatus AS ETI
											ON ETI.IdEstatus = TAI.IdEstatus
										LEFT JOIN dbo.S_Usuario AS USI
											ON USI.IdUsuario = TAI.IdAprobador
										WHERE SPI.IdSolicitudPedido = SP.IdSolicitudPedido  AND 
											TAI.NoSecuencia = 2 AND 
											TAI.IdEstatus in (1,2,3,4,6)
										ORDER BY TAI.FechaRegistro DESC)
			ELSE FechaCambioEstatus
		END,
		ISNULL(US.Nombre,''),
		'2da Aprobacion',
		ISNULL(ET.Nombre,'')
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.TA_Operacion AS OP 
		ON OP.IdDocumento = SP.IdSolicitudPedido 
		AND OP.IdTipoOperacion = 2
	LEFT JOIN dbo.TA_Tarea AS TA
		ON TA.IdOperacion = OP.IdOperacion
	LEFT JOIN dbo.TA_Estatus AS ET
		ON ET.IdEstatus = TA.IdEstatus
	LEFT JOIN dbo.S_Usuario AS US
		ON US.IdUsuario = TA.IdAprobador
	WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
		TA.NoSecuencia = 2 AND 
		TA.IdEstatus in (1,2,3,4,6,7)
	ORDER BY TA.FechaRegistro ASC;

	END

	

	IF (SELECT TOP 1
				TA.IdEstatus
		FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.TA_Operacion AS OP 
			ON OP.IdDocumento = SP.IdSolicitudPedido 
			AND OP.IdTipoOperacion = 2
		LEFT JOIN dbo.TA_Tarea AS TA
			ON TA.IdOperacion = OP.IdOperacion
		WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
			TA.NoSecuencia = 2 AND 
			TA.IdEstatus in (1,2,3,4,6,7)
		ORDER BY TA.FechaRegistro ASC) = 7
	BEGIN
	    
		INSERT INTO @APROBACIONES
		(
			IdSolicitudPedido,
			FechaAccion,
			Usuario,
			Accion,
			Estatus
		)
		SELECT TOP 1 
			@IDSOLICITUDPEDIDO,
			FechaCambioEstatus,
			US.Nombre,
			'2da Reasignacion',
			ET.Nombre
		FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.TA_Operacion AS OP 
			ON OP.IdDocumento = SP.IdSolicitudPedido 
			AND OP.IdTipoOperacion = 2
		LEFT JOIN dbo.TA_Tarea AS TA
			ON TA.IdOperacion = OP.IdOperacion
		LEFT JOIN dbo.TA_Estatus AS ET
			ON ET.IdEstatus = TA.IdEstatus
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = TA.IdAprobador
		WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO  AND 
			TA.NoSecuencia = 2 AND 
			TA.IdEstatus in (1,2,3,4,6)
			AND TA.Activo = 1
		ORDER BY TA.FechaRegistro ASC;

	END
	ELSE
	BEGIN
	    
		INSERT INTO @APROBACIONES
		(
			IdSolicitudPedido,
			FechaAccion,
			Usuario,
			Accion,
			Estatus
		)
		SELECT TOP 1 
			@IDSOLICITUDPEDIDO,
			NULL,
			'',
			'2da Reasignacion',
			''

	END

	INSERT INTO @APROBACIONES
	(
	    IdSolicitudPedido,
	    FechaAccion,
	    Usuario,
	    Accion,
	    Estatus
	)
	SELECT
	@IDSOLICITUDPEDIDO,
	NULL,
	null,
	'Carga de PR',
	'';

	UPDATE @APROBACIONES
	SET FechaAccion = (SELECT TOP 1 
							CreadoEl 
						FROM dbo.DEA_AdjuntoPR 
						WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO 
							AND Activo = 1),
		Usuario = (SELECT TOP 1 
						US.Nombre
					FROM dbo.DEA_AdjuntoPR AS PR
					LEFT JOIN dbo.S_Usuario AS US
						ON US.IdUsuario = PR.CreadoPor
					WHERE PR.IdSolicitudPedido = @IDSOLICITUDPEDIDO 
					AND PR.Activo = 1),
		Estatus = ISNULL((SELECT TOP 1
						CASE
							WHEN ID_PR IS NOT NULL THEN 'Realizado'
							ELSE 'No Realizado'
						END
					FROM dbo.DEA_AdjuntoPR
					WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO
					AND Activo = 1),'No Realizado')
	WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO
		AND Accion = 'Carga de PR';

	SET @CONT = @CONT + 1;

END

INSERT INTO @CONSULTACOMPLETA
(
    IdSolicitudPedido,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    FechaAccion,
    Usuario,
    Accion,
    Estatus,
    Tiempo
)
SELECT
	SDEA.IdSolicitudPedido,
	SDEA.CentroCosto,
	SDEA.Requisitor,
	SDEA.FechaRegistro,
	APR.FechaAccion,
	APR.Usuario,
	APR.Accion,
	APR.Estatus,
	APR.Tiempo
FROM @SOLICITUDESDEA AS SDEA
LEFT JOIN @APROBACIONES AS APR
	ON APR.IdSolicitudPedido = SDEA.IdSolicitudPedido
LEFT JOIN @CENTROSCOSTOS AS CC
	ON CC.IdSolicitudPedido = SDEA.IdSolicitudPedido;

UPDATE @CONSULTACOMPLETA
SET Tiempo = dbo.CalcularTipoDEA(FechaRegistro,FechaAccion)
WHERE Accion = '1ra Aprobacion'

SET @CONT = 1;
SET @TOTAL = (SELECT COUNT(ID) FROM @CONSULTACOMPLETA);

WHILE @CONT <= @TOTAL
BEGIN

	SET @ACCION = (SELECT Accion FROM @CONSULTACOMPLETA WHERE ID = @CONT);
	SET @FECHANUEVA = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = @CONT);
	
	IF @ACCION = '1ra Reasignacion'
	BEGIN
	    
		SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 1) AND Accion = '1ra Aprobacion');
		
		IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
		BEGIN
		    
			UPDATE @CONSULTACOMPLETA
			SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
			WHERE ID = @CONT;
		END

	END

	IF @ACCION = '2da Aprobacion'
	BEGIN
	    
		SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 1) AND Accion = '1ra Reasignacion');
		
		IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
		BEGIN
		    
			UPDATE @CONSULTACOMPLETA
			SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
			WHERE ID = @CONT;
		END
		ELSE
		BEGIN
		    
			SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 2) AND Accion = '1ra Aprobacion');

			IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
			BEGIN
		    
				UPDATE @CONSULTACOMPLETA
				SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
				WHERE ID = @CONT;
			END

		END

	END

	IF @ACCION = '2da Reasignacion'
	BEGIN
	    
		SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 1) AND Accion = '2da Aprobacion');
		
		IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
		BEGIN
		    
			UPDATE @CONSULTACOMPLETA
			SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
			WHERE ID = @CONT;
		END

	END

	IF @ACCION = 'Carga de PR'
	BEGIN
	    
		SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 1) AND Accion = '2da Reasignacion');
		
		IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
		BEGIN
		    
			UPDATE @CONSULTACOMPLETA
			SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
			WHERE ID = @CONT;
		END
		ELSE
		BEGIN
		    
			SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 2) AND Accion = '2da Aprobacion');
		
			IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
			BEGIN
		    
				UPDATE @CONSULTACOMPLETA
				SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
				WHERE ID = @CONT;
			END
			ELSE
			BEGIN
			    
				SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 3) AND Accion = '1ra Reasignacion');
		
				IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
				BEGIN
		    
					UPDATE @CONSULTACOMPLETA
					SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
					WHERE ID = @CONT;
				END
				ELSE
				BEGIN
				    
					SET @FECHAANTERIOR = (SELECT FechaAccion FROM @CONSULTACOMPLETA WHERE ID = (@CONT - 4) AND Accion = '1ra Aprobacion');
		
					IF @FECHAANTERIOR IS NOT NULL AND @FECHANUEVA IS NOT NULL
					BEGIN
		    
						UPDATE @CONSULTACOMPLETA
						SET Tiempo = dbo.CalcularTipoDEA(@FECHAANTERIOR,@FECHANUEVA)
						WHERE ID = @CONT;
					END

				END

			END

		END

	END

	SET @CONT = @CONT + 1;
END

DELETE FROM @CONSULTACOMPLETA WHERE IdSolicitudPedido IN (
															SELECT
																IdSolicitudPedido
															FROM @CONSULTACOMPLETA
															WHERE Accion = '1ra Aprobacion'
																AND Usuario <> 'Napoleón Pineiro'
															GROUP BY IdSolicitudPedido
															);

DELETE FROM dbo.ProcesoDEA_Pedidos_Tableau;

INSERT INTO dbo.ProcesoDEA_Pedidos_Tableau
(
    IdSolicitudPedido,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    FechaAccion,
    Usuario,
    Accion,
    Estatus,
    Tiempo
)
SELECT 
	IdSolicitudPedido,
	CentroCosto,
	Requisitor,
	FechaRegistro,
	FechaAccion,
	Usuario,
	Accion,
	CASE
		WHEN Estatus = 'Aprobada' THEN 'Realizado'
		WHEN Estatus = 'Rechazada' THEN 'Realizado'
		WHEN Estatus = 'Cancelado por Rechazo' THEN 'Realizado'
		WHEN Estatus = 'Cancelado por Asignador' THEN 'Realizado'
		WHEN Estatus = 'Cancelado por Reasignacion' THEN 'Realizado'
		WHEN Estatus = 'En Aprobación' THEN 'Pendiente'
		ELSE Estatus
	END AS Estatus,
	Tiempo
FROM @CONSULTACOMPLETA
WHERE IdSolicitudPedido NOT IN (SELECT IdSolicitudPedido FROM Adinco.dbo.OT_Estimacion)
	AND IdSolicitudPedido NOT IN (SELECT IdSolicitudPedido FROM dbo.DEA_Exclusiones_Dashboard)
	AND Requisitor <> 'Tareas automáticas Control de Obra'
ORDER BY IdSolicitudPedido,ID ASC;

END
