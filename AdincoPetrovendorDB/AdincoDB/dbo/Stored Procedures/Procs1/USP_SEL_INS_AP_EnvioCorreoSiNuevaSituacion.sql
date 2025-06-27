IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_SEL_INS_AP_EnvioCorreoSiNuevaSituacion'
		)
	DROP PROCEDURE USP_SEL_INS_AP_EnvioCorreoSiNuevaSituacion;
GO

CREATE PROCEDURE [dbo].[USP_SEL_INS_AP_EnvioCorreoSiNuevaSituacion] 
@Operadora VARCHAR(20)
	,@Destinatarios VARCHAR(5000)
AS
BEGIN
	BEGIN TRAN

	BEGIN TRY
		DECLARE @CantidadNuevaSituacion INT
			,@Tabla VARCHAR(8000) = ''
			,@Html VARCHAR(MAX) = ''

		CREATE TABLE #RFC_Emisores (Emisor VARCHAR(20))

		CREATE TABLE #ExisteEnListaNegra (
			RFC VARCHAR(20)
			,RazonSocial VARCHAR(2000)
			,Situacion VARCHAR(20)
			,PublicacionPaginaSATPresuntos SMALLDATETIME
			)

		CREATE TABLE #NotificarNuevaSituacion (
			RFC VARCHAR(20)
			,RazonSocial VARCHAR(2000)
			,Situacion VARCHAR(20)
			,PublicacionPaginaSATPresuntos SMALLDATETIME
			)

		INSERT INTO #RFC_Emisores
		SELECT Emisor
		FROM FI_Factura
		WHERE Receptor = @Operadora
		GROUP BY Emisor

		INSERT INTO #ExisteEnListaNegra (
			RFC
			,Situacion
			,PublicacionPaginaSATPresuntos
			,RazonSocial
			)
		SELECT ListaNegra.RFC
			,ListaNegra.Situacion
			,ListaNegra.PublicacionPaginaSATPresuntos
			,ListaNegra.Contribuyente
		FROM #RFC_Emisores
		INNER JOIN ListaNegra ON #RFC_Emisores.Emisor = ListaNegra.RFC

		INSERT INTO #NotificarNuevaSituacion (
			RFC
			,RazonSocial
			,Situacion
			,PublicacionPaginaSATPresuntos
			)
		SELECT #ExisteEnListaNegra.RFC
			,#ExisteEnListaNegra.RazonSocial
			,#ExisteEnListaNegra.Situacion
			,#ExisteEnListaNegra.PublicacionPaginaSATPresuntos
		FROM #ExisteEnListaNegra
		LEFT JOIN EMP_NotificadoListaNegra ON #ExisteEnListaNegra.RFC = EMP_NotificadoListaNegra.RFC
			AND #ExisteEnListaNegra.PublicacionPaginaSATPresuntos = EMP_NotificadoListaNegra.PublicacionPaginaSATPresuntos
			AND #ExisteEnListaNegra.Situacion = EMP_NotificadoListaNegra.Situacion
			AND EMP_NotificadoListaNegra.RFC_Operadora = @Operadora
		WHERE EMP_NotificadoListaNegra.RFC IS NULL

		SELECT @CantidadNuevaSituacion = COUNT(1)
		FROM #NotificarNuevaSituacion

		IF (
				ISNULL(@Destinatarios, '') <> ''
				AND ISNULL(@CantidadNuevaSituacion, 0) > 0
				)
		BEGIN
			SELECT @Tabla = '<br><br><table style="font-size: 11px; font-family: OPEN Sans, Arial, Helvetica, sans-serif; color:black;"
                                                width="110%" border="1" cellspacing="0" cellpadding="1" align="center"
                                                class="smallfont"><tr><th>RFC</th><th>Razón Social</th><th>Situación</th><th>SAT presuntos</th></tr>'

			SELECT @Tabla += '<tr><td>' + RFC + '</td>' + '<td>' + RazonSocial + '</td>' + '<td>' + Situacion + '</td>' + '<td>' + CONVERT(VARCHAR, PublicacionPaginaSATPresuntos, 3) + '</td></tr>'
			FROM #NotificarNuevaSituacion

			SELECT @Tabla += '</table>'

			SELECT @Html = REPLACE(replace(HTML, '##ANIO', 2017), '##TABLA_TAREAS##', @Tabla)
			FROM TA_Correo
			WHERE Descripcion = 'Notificacion Situacion Fiscal a cambiado'

			SELECT 'AdincoConsola' AS Modulo
				,@Destinatarios AS Para
				,'Notificación Adinco SAT' AS Asunto
				,@Html AS Mensaje
		END

		INSERT INTO EMP_NotificadoListaNegra (
			RFC_Operadora
			,RFC
			,Situacion
			,PublicacionPaginaSATPresuntos
			)
		SELECT @Operadora
			,#NotificarNuevaSituacion.RFC
			,#NotificarNuevaSituacion.Situacion
			,#NotificarNuevaSituacion.PublicacionPaginaSATPresuntos
		FROM #NotificarNuevaSituacion
	END TRY

	BEGIN CATCH
		ROLLBACK

		SELECT ERROR_PROCEDURE() + ' - ' + ERROR_MESSAGE() + ' - ' + ERROR_LINE()
	END CATCH

	COMMIT
END