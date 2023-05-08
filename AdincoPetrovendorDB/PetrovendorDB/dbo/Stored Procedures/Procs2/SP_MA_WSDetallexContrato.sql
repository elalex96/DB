-- =============================================
-- Author: Pedro Acu�a
-- Create date: 30/04/2018
-- Description: mostrar el detalle de la aprobacion filtrado por el contrato
-- =============================================

CREATE PROCEDURE SP_MA_WSDetallexContrato @IdContrato INT, @IdApp INT
AS
	BEGIN
		SET DATEFORMAT DMY
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

		DECLARE @tablaAuxContrato TABLE
			( Id INT IDENTITY ,
			  IdOperacion INT )

		--ya que se elimino el contrato del historial se puede relacionar por el Idoperacion de
		INSERT INTO @tablaAuxContrato
			( IdOperacion )
		SELECT	operacion.IdOperacion
		FROM	Adinco.dbo.MA_Operacion operacion
		WHERE	operacion.IdContrato = @IdContrato

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
					histoOpera.IdApp = @IdApp
					AND histoOpera.IdOperacion IN
							( SELECT IdOperacion FROM	   @tablaAuxContrato )

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
					operacion.IdContrato = @IdContrato
					AND operacion.IdApp = @IdApp

		SELECT		tabla.Id, tabla.IdDocumento, tabla.IdLineaTiempo, tabla.IdOperacion, tabla.Aprobador ,
					tabla.IdEstatusTarea, tabla.NoSecuencia, tabla.IdEstatusGral, tabla.TipoOperacion, tabla.Fecha ,
					linea.ComentarioRechazo
		FROM		@tablaHistoria tabla
		INNER JOIN	Adinco.dbo.MA_LineaTiempo linea
			ON linea.IdDocumento = tabla.IdDocumento
			   AND	linea.IdLineaTiempo = tabla.IdLineaTiempo
		ORDER BY	tabla.IdOperacion, tabla.IdLineaTiempo, tabla.Fecha
	END
--------------------------------------------------------------------------------------------------------------
