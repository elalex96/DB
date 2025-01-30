IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ObtenerProgramaBitacoraSemana'
    )
    DROP PROCEDURE p_OT_ObtenerProgramaBitacoraSemana;
GO
CREATE PROCEDURE [dbo].[p_OT_ObtenerProgramaBitacoraSemana]
    @pIdOTSolicitud int,
    @pSemanaID      varchar(21)
AS
BEGIN
    SELECT
        OT_ProgramaBitacoraSemana.IdOTProgramaBitacoraSemana,
        OT_ProgramaBitacoraSemana.IdOTSolicitud,
        OT_ProgramaBitacoraSemana.SemanaID,
        OT_ProgramaBitacoraSemana.FechaRegistro,
        OT_ProgramaBitacoraSemana.Comentarios,
        OT_ProgramaBitacoraSemana.CreadoPor,
        OT_ProgramaBitacoraSemana.UsuarioPetrovendorID,
        SemanaCerrada = cast(case
                                 when OT_ProgramaSemanaCerrada.IdOTSolicitud is not null
                                     then 1
                                 else
                                     0
                             end as bit),
        TipoUsuarioID = OT_ProgramaBitacoraSemana.TipoUsuario,
        TipoUsuario   = case
                            when OT_ProgramaBitacoraSemana.TipoUsuario = 1
                                then 'Operador'
                            else
                                'Subcontratista'
                        end,
        NombreUsuario = case
                            when OT_ProgramaBitacoraSemana.TipoUsuario = 1
                                then AP_Usuario.Nombre COLLATE Modern_Spanish_CI_AS
                            else
                                S_Usuario.Nombre COLLATE Modern_Spanish_CI_AS
                        end
    FROM
        OT_ProgramaBitacoraSemana (NOLOCK)
        LEFT JOIN
            OT_ProgramaSemanaCerrada (NOLOCK)
                on  OT_ProgramaBitacoraSemana.IdOTSolicitud	= OT_ProgramaSemanaCerrada.IdOTSolicitud
				AND OT_ProgramaBitacoraSemana.IdOTSolicitud = @pIdOTSolicitud
				AND OT_ProgramaBitacoraSemana.SemanaID = @pSemanaID
                AND OT_ProgramaSemanaCerrada.SemanaId = OT_ProgramaBitacoraSemana.SemanaId
                AND OT_ProgramaSemanaCerrada.isActivo = 1
        LEFT JOIN
            Petrovendor.dbo.S_Usuario	AS S_Usuario (NOLOCK)
                on	OT_ProgramaBitacoraSemana.UsuarioPetrovendorID	=	S_Usuario.IdUsuario
        LEFT JOIN
            AP_Usuario (NOLOCK)
                on OT_ProgramaBitacoraSemana.UsuarioAdincoID	=	AP_Usuario.UsuarioId 
    where
        OT_ProgramaBitacoraSemana.IdOTSolicitud = @pIdOTSolicitud
        and OT_ProgramaBitacoraSemana.SemanaID = @pSemanaID
    order by
        OT_ProgramaBitacoraSemana.FechaRegistro desc
END