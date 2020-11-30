
-- p_OT_ObtenerProgramaBitacoraSemana 1,'20180108-20180114'
Create Proc p_OT_ObtenerProgramaBitacoraSemana
@pIdOTSolicitud int,
@pSemanaID varchar(21)
as

	select pb.IdOTProgramaBitacoraSemana,
		pb.IdOTSolicitud,
		pb.SemanaID,
		pb.FechaRegistro,
		pb.Comentarios,
		pb.CreadoPor,
		pb.UsuarioPetrovendorID,
		SemanaCerrada = cast(case when dc.IdOTSolicitud is not null then 1 else 0 end as bit),
		TipoUsuarioID = pb.TipoUsuario,
		TipoUsuario = case when pb.TipoUsuario = 1  then 'Operador' else 'Subcontratista' end,
		NombreUsuario = case when pb.TipoUsuario = 1  then usuAd.Nombre COLLATE Modern_Spanish_CI_AS else usuPet.Nombre  COLLATE Modern_Spanish_CI_AS end
	from [dbo].[OT_ProgramaBitacoraSemana] pb
	left join [dbo].[OT_ProgramaSemanaCerrada] dc on dc.IdOTSolicitud = pb.IdOTSolicitud and
												dc.SemanaId = pb.SemanaId and
												dc.isActivo = 1
	left join Petrovendor.dbo.S_Usuario usuPet on  usuPet.IdUsuario = pb.UsuarioPetrovendorID
	left join AP_Usuario usuAd on usuAd.UsuarioId = pb.UsuarioAdincoID
	where pb.IdOTSolicitud = @pIdOTSolicitud and
	pb.SemanaID = @pSemanaID
	order by pb.FechaRegistro desc

