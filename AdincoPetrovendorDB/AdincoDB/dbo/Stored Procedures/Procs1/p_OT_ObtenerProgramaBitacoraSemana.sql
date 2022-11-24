
-- p_OT_ObtenerProgramaBitacoraSemana 1,'20180108-20180114'
Create Proc [dbo].[p_OT_ObtenerProgramaBitacoraSemana]
    @pIdOTSolicitud int,
    @pSemanaID varchar(21)
as
select OT_ProgramaBitacoraSemana.IdOTProgramaBitacoraSemana,
       OT_ProgramaBitacoraSemana.IdOTSolicitud,
       OT_ProgramaBitacoraSemana.SemanaID,
       OT_ProgramaBitacoraSemana.FechaRegistro,
       OT_ProgramaBitacoraSemana.Comentarios,
       OT_ProgramaBitacoraSemana.CreadoPor,
       OT_ProgramaBitacoraSemana.UsuarioPetrovendorID,
       SemanaCerrada = cast(case
                                when OT_ProgramaSemanaCerrada.IdOTSolicitud is not null then
                                    1
                                else
                                    0
                            end as bit),
       TipoUsuarioID = OT_ProgramaBitacoraSemana.TipoUsuario,
       TipoUsuario = case
                         when OT_ProgramaBitacoraSemana.TipoUsuario = 1 then
                             'Operador'
                         else
                             'Subcontratista'
                     end,
       NombreUsuario = case
                           when OT_ProgramaBitacoraSemana.TipoUsuario = 1 then
                               AP_Usuario.Nombre COLLATE Modern_Spanish_CI_AS
                           else
                               S_Usuario.Nombre COLLATE Modern_Spanish_CI_AS
                       end
from OT_ProgramaBitacoraSemana
    left join OT_ProgramaSemanaCerrada (NOLOCK)
        on OT_ProgramaSemanaCerrada.IdOTSolicitud = OT_ProgramaBitacoraSemana.IdOTSolicitud
           and OT_ProgramaSemanaCerrada.SemanaId = OT_ProgramaBitacoraSemana.SemanaId
           and OT_ProgramaSemanaCerrada.isActivo = 1
    left join Petrovendor.dbo.S_Usuario (NOLOCK)
        on S_Usuario.IdUsuario = OT_ProgramaBitacoraSemana.UsuarioPetrovendorID
    left join AP_Usuario (NOLOCK)
        on AP_Usuario.UsuarioId = OT_ProgramaBitacoraSemana.UsuarioAdincoID
where OT_ProgramaBitacoraSemana.IdOTSolicitud = @pIdOTSolicitud
      and OT_ProgramaBitacoraSemana.SemanaID = @pSemanaID
order by OT_ProgramaBitacoraSemana.FechaRegistro desc

