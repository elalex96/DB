-- p_OT_RechazarConvenio 1,''
Create Proc p_OT_RechazarConvenio
@pIdSubcontrato int,
@pNombreUsuario varchar(250),
@pError varchar(250) out
as

	declare @IdUsuarioAdinco int,
		@IdOTConvenio int

	select @IdUsuarioAdinco = UsuarioID
	from AP_Usuario
	where Usuario = @pNombreUsuario



	/******Obtener el convenio a rechazar**************/
	SELECT @IdOTConvenio = IdOTConvenio
	FROM OT_Convenio ot
	inner join OT_Solicitud otSol on otSol.IdOTSolicitud = ot.IdOTSolicitud
	inner join SC_Subcontrato sc on sc.IdSubcontrato = otSol.IdSubcontrato
	where sc.IdSubcontrato = @pIdSubcontrato	
	and ot.AprobadaPor is null
	and ot.RechazadaPor is null


	if (
		select 1
		from OT_Convenio
		where IdOTConvenio = @IdOTConvenio and
		Aprobada = 1
		)
		>0
	begin
		set @pError = 'El convenio ya está áprobado'; 
		return
	end

	if (
		isnull(@IdOTConvenio ,0) = 0
		)
		
	begin
		set @pError = 'No fue posible rechazar el convenio'; 
		return
	end

	update OT_Convenio
	set RechazadaPor = @IdUsuarioAdinco,
		FechaRechazo = getdate()
	where IdOTConvenio = @IdOTConvenio
