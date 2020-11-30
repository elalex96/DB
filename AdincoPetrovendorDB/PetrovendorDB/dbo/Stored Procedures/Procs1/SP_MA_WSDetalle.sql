-- =============================================
-- Author: Pedro Acu�a
-- Create date: 30/04/2018
-- Description: mostrar el detalle de las aprobaciones filtrado por IdDocumento
-- =============================================

CREATE PROCEDURE SP_MA_WSDetalle @IdDocumento INT, @IdApp INT
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @ComentarioRechazo NVARCHAR(MAX)

		DECLARE @tablaLinea TABLE
			( IdLineaTiempo INT ,
			  FechaCreacion DATETIME )

		DECLARE @tablaHistoria TABLE
			( Id INT IDENTITY ,
			  IdDocumento INT ,
			  IdLineaTiempo INT ,
			  IdOperacion INT ,
			  Aprobador NVARCHAR(MAX) ,
			  IdEstatusTarea INT ,
			  NoSecuencia INT ,
			  IdEstatusGral INT ,
			  TipoOperacion INT ,
			  Fecha DATETIME )

		INSERT INTO @tablaLinea
			( IdLineaTiempo, FechaCreacion )
		SELECT		linea.IdLineaTiempo, linea.FechaCreacion
		FROM		Adinco.dbo.MA_LineaTiempo linea
		INNER JOIN	Adinco.dbo.MA_Operacion operacion
			ON operacion.IdDocumento = linea.IdDocumento
			   AND	operacion.IdLineaTiempo = linea.IdLineaTiempo
		WHERE
					linea.IdDocumento = @IdDocumento
					AND operacion.IdApp = @IdApp

		INSERT INTO @tablaHistoria
			( IdDocumento, IdLineaTiempo, IdOperacion, Aprobador, IdEstatusTarea, NoSecuencia, IdEstatusGral ,
			  TipoOperacion , Fecha )
		SELECT		histoOpera.IdDocumento, aprobador.IdLineaTiempo, aprobador.IdOperacion, aprobador.Correo ,
					histoOperaDetalle.IdEstatus, histoOperaDetalle.NoSecuencia, histoOpera.IdEstatusOperacion ,
					aprobador.IdTipoOperacion, histoOpera.FechaRegistro
		FROM		Adinco.dbo.MA_HistorialOperacionDetalle histoOperaDetalle
		INNER JOIN	Adinco.dbo.MA_HistorialOperacion histoOpera
			ON histoOpera.IdLineaTiempo = histoOperaDetalle.IdLineaTiempo
			   AND	histoOpera.IdOperacion = histoOperaDetalle.IdOperacion
		INNER JOIN	Adinco.dbo.MA_Aprobador aprobador
			ON aprobador.IdAprobador = histoOperaDetalle.IdAprobador
			   AND	aprobador.IdOperacion = histoOpera.IdOperacion
			   AND	aprobador.IdLineaTiempo = histoOperaDetalle.IdLineaTiempo
		WHERE
					histoOpera.IdDocumento = @IdDocumento
					AND histoOperaDetalle.IdLineaTiempo IN
							( SELECT IdLineaTiempo	  FROM @tablaLinea )
		ORDER BY	histoOperaDetalle.FechaRegistro DESC

		INSERT INTO @tablaHistoria
			( IdDocumento, IdLineaTiempo, IdOperacion, Aprobador, IdEstatusTarea, NoSecuencia, IdEstatusGral ,
			  TipoOperacion , Fecha )
		SELECT		operacion.IdDocumento, aprobador.IdLineaTiempo, aprobador.IdOperacion, aprobador.Correo ,
					detalle.IdEstatus, detalle.NoSecuencia, operacion.IdEstatusOperacion, aprobador.IdTipoOperacion ,
					detalle.FechaCambioEstatus
		FROM		Adinco.dbo.MA_OperacionDetalle detalle
		INNER JOIN	Adinco.dbo.MA_Operacion operacion
			ON operacion.IdLineaTiempo = detalle.IdLineaTiempo
			   AND	operacion.IdOperacion = detalle.IdOperacion
		INNER JOIN	Adinco.dbo.MA_Aprobador aprobador
			ON aprobador.IdAprobador = detalle.IdAprobador
			   AND	aprobador.IdLineaTiempo = detalle.IdLineaTiempo
		WHERE
					operacion.IdDocumento = @IdDocumento
					AND detalle.IdLineaTiempo IN
							( SELECT IdLineaTiempo	  FROM @tablaLinea )

		SELECT		historia.Id, historia.IdDocumento, historia.IdLineaTiempo, historia.IdOperacion, historia.Aprobador ,
					historia.IdEstatusTarea, historia.NoSecuencia, historia.IdEstatusGral, historia.TipoOperacion ,
					historia.Fecha, linea.ComentarioRechazo
		FROM		@tablaHistoria historia
		INNER JOIN	Adinco.dbo.MA_LineaTiempo linea
			ON linea.IdDocumento = historia.IdDocumento
			   AND	linea.IdLineaTiempo = historia.IdLineaTiempo
		ORDER BY	IdOperacion, IdLineaTiempo, Fecha
	END
