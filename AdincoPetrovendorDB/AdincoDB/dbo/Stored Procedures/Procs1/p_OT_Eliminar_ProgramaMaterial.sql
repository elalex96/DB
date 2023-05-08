Create Proc p_OT_Eliminar_ProgramaMaterial
@pIdOTSolicitudMaterial int
as

	delete OT_SolicitudPrograma
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
