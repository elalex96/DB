--select  dbo.fn_OT_ValidarEnviarSubContratista(743,10)
CREATE FUNCTION [dbo].[fn_OT_ValidarEnviarSubContratista](
	@pIdOTSolicitud int	,
	@pCreadoPor int
)
RETURNS VARCHAR(250)
BEGIN

	DECLARE @error VARCHAR(250)='',
			@IdOTEstatus int,
			@capturaProgramaPorContratista bit,
			@emailAprobadores varchar(250),
			@permitirConvenios bit,
			@permitirOTExcedida bit

	select @IdOTEstatus  = IdOTEstatus,
		@permitirConvenios = isnull(PermitirConvenios,0),
		@permitirOTExcedida = isnull(PermitirOTExcedida,0)
	from OT_Solicitud ot
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato
	inner join OT_Configurador conf on conf.IdContrato = sc.IdContrato
	where IdOTSolicitud = @pIdOTSolicitud

	select @capturaProgramaPorContratista = isnull(case when ProgIniPorProveedor = 1 then 0 else 1 end,0)
	from OT_Solicitud ot
	inner join SC_Subcontrato sc on sc.idSubcontrato = ot.IdSubcontrato
	inner join OT_Configurador conf on conf.IdContratista = sc.IdCOntratista and
									conf.IdContrato = sc.IdContrato
	where ot.idOTSolicitud = @pIdOTSolicitud

	select @emailAprobadores=dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,0,2,0)--usuarios responsables


	if(isnull(@emailAprobadores,'') = '')
	begin
		set @error = 'Es necesario configurar los aprobadores internos antes de continuar'
		RETURN @error
	end

	if not exists(
		select 1
		from OT_SolicitudMaterial
		where IdOTSolicitud = @pIdOTSolicitud and
		isnull(Cantidad,0) > 0		
	)
	begin
		if(@capturaProgramaPorContratista = 1)
		begin
			set @error = 'No se han capturado cantidades'
			RETURN @error
		end
	end

	--Enviada a Subcontratista
	--if(@IdOTEstatus = 2)
	--begin
	--	if not exists(
	--		select 1
	--		from [OT_SolicitudTareas]
	--		where UsuarioAdinRequeridoId = @pCreadoPor and
	--		IdOTSolicitud = @pIdOTSolicitud and
	--		isnull(Completada,0) = 0 and
	--		FlujoAprobacionTareaId = 2 --Aprobar OT
	--	)
	--	begin
	--		set @error = 'No tiene tarea pendiente de aprobar para esta OT'
	--		RETURN @error
	--	end
	--end

	if (@IdOTEstatus in(1,2,11))
	begin

		if(dbo.fn_SC_ExcedidoSiNo(@pIdOTSolicitud) = 1 and @permitirConvenios = 0)
		begin
				set @error = 'No es posible continuar, el contrato ha excedido la capacidad'
				RETURN @error
		end
		
	end

	--Propuesta por subcontratista
	if(@IdOTEstatus = 3)
	begin
		--
		if not exists (
			select 1
			from OT_SolicitudMaterial sm
			inner join OT_SolicitudMaterialBitacora smb on smb.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial and
												smb.IdTipoUsuario = 1-- Contratista
			where IdOTSolicitud = @pIdOTSolicitud 			
		)
		begin
			set @error = 'No se han registrado cambios por el contratista, no es posible enviar la solicitud'
			RETURN @error			
		end
	end	

	if(@capturaProgramaPorContratista = 1)
	Begin		

		DECLARE @tmpMaterialCantidades TABLE  
		( IdOTSolicitudMaterial   INT   NOT NULL ,  
		  Cantidad  DECIMAL (14,2),
		  CantidadProgramada DECIMAL(14,2)

		  );  

		INSERT INTO @tmpMaterialCantidades
		(
			IdOTSolicitudMaterial,
			Cantidad,
			CantidadProgramada
		)
		SELECT IdOTSolicitudMaterial,
			Cantidad,
			0.0
		FROM dbo.OT_SolicitudMaterial 
		WHERE IdOTSolicitud = @pIdOTSolicitud

		UPDATE @tmpMaterialCantidades	
		SET CantidadProgramada = (
									SELECT SUM(p.Cantidad) 
									FROM dbo.OT_SolicitudPrograma P 
									WHERE P.IdOTSolicitudMaterial = t1.IdOTSolicitudMaterial
								)
		FROM @tmpMaterialCantidades t1
			
		IF (
			SELECT ISNULL(SUM(cantidad),0)
			FROM @tmpMaterialCantidades
			---WHERE Cantidad <> CantidadProgramada 
			) 
			<>
			(
			SELECT ISNULL(SUM(CantidadProgramada),0)
			FROM @tmpMaterialCantidades
			--WHERE Cantidad <> CantidadProgramada 
			) 
		BEGIN	
			SET @error = 'Es necesario terminar la captura de la programación de materiales'
			RETURN @error
		END

		if not exists (
			select 1
			from [dbo].OT_SolicitudPrograma SMB
			INNER JOIN OT_SolicitudMaterial SM on SM.IdOTSolicitudMaterial = SMB.IdOTSolicitudMaterial
			inner join OT_Solicitud s on s.IdOTSolicitud = SM.IdOTSolicitud
			where s.IdOTSolicitud = @pIdOTSolicitud		
		)
		begin
			SET @error = 'Es necesario capturar las cantidades y programación de los servicios'
			RETURN @error
		end
	End
	RETURN @error
end