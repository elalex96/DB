CREATE Proc sp_OT_ActualizarSolicitudPrograma
@pIdOTSolicitudPrograma	int out,
@pIdOTSolicitudMaterial	int,
@pAnio	smallint,
@pMes	tinyint,
@pCantidad	decimal(14,5),
@pCreadoPor	int
As

	
	IF(ISNULL(@pIdOTSolicitudPrograma,0) = 0 )
	BEGIN

		SELECT @pIdOTSolicitudPrograma = ISNULL(MAX(IdOTSolicitudPrograma),0) + 1
		FROM OT_SolicitudPrograma

		INSERT INTO OT_SolicitudPrograma(IdOTSolicitudPrograma,IdOTSolicitudMaterial,Anio,
		Mes,Cantidad,CreadoPor,CreadoEl)
		SELECT @pIdOTSolicitudPrograma,@pIdOTSolicitudMaterial,@pAnio,
		@pMes,@pCantidad,@pCreadoPor,GETDATE()

	END
	Else
	Begin

		update OT_SolicitudPrograma
		set Cantidad = @pCantidad,
			ModificadoPor = @pCreadoPor,
			ModificadoEl = getdate()
		where IdOTSolicitudPrograma = @pIdOTSolicitudPrograma

	End

