IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_Cerrar'
    )
    DROP PROCEDURE p_OT_Cerrar;
GO
CREATE PROCEDURE p_OT_Cerrar
    @pIdOTSolicitud int,
    @pUsuarioId     int,
    @pIdContrato    int,
    @pComentario    varchar(max) = null
as
    begin

        declare
            @descripcion varchar(150),
            @idCC        int,
            @CreadorOT   bit,
            @AprobadorOT bit

        select
            @idCC = isnull(IdCentroCosto, 0)
        from
            OT_Solicitud (NOLOCK)
        where
            IdOTSolicitud = @pIdOTSolicitud

        --Obtener permisos
        select
            @CreadorOT   = cast(isnull(MAX(   case
                                                  when fe.Orden = 1
                                                      then 1
                                                  else
                                                      0
                                              end
                                          ), 0
                                      ) as bit),
            @AprobadorOT = cast(isnull(MAX(   case
                                                  when fe.Orden = 2
                                                      then 1
                                                  else
                                                      0
                                              end
                                          ), 0
                                      ) as bit)
        from
            [AP_FlujoAprobacionEstatus]             fe (NOLOCK)
            inner join
                [AP_FlujoAprobacionEstatusUsuarios] fu (NOLOCK)
                    on fe.FlujoAprobacionEstatusId = fu.FlujoAprobacionEstatusId
                       AND fe.TipoFlujoAprobacionId = 1 /*Control de Obra*/
                       AND fu.usuarioId = @pUsuarioId
            inner join
                [AP_FlujoAprobacionContratos]       fc (NOLOCK)
                    on fc.IdContrato = @pIdContrato
            inner join
                [AP_FlujoAprobacion]                fa (NOLOCK)
                    on fa.FlujoAprobacionId = fc.FlujoAprobacionId
                       and fa.TipoFlujoAprobacionId = fe.TipoFlujoAprobacionId
            inner join
                [dbo].[AP_UsuarioCentroCosto]       ucc (NOLOCK)
                    on ucc.IdUsuario = fu.usuarioId
                       and isnull(@idCC, 0) in (
                                                   0, ucc.IdCentroCosto
                                               )
        where
            fe.TipoFlujoAprobacionId = 1 /*Control de Obra*/
            and fc.IdContrato = @pIdContrato
            and fu.usuarioId = @pUsuarioId

        if @CreadorOT = 1
           OR @AprobadorOT = 1
            begin
                select
                    @descripcion = Descripcion
                from
                    OT_Estatus (NOLOCK)
                where
                    IdOtEstatus = 12

                BEGIN TRY

                    begin tran
                    update
                        OT_Solicitud
                    set
                        IdOTEstatusAnt = IdOTEstatus,
                        IdOTEstatus = 12,
                        ModificadoPor = @pUsuarioId,
                        ModificadoEl = getdate()
                    where
                        IdOTSolicitud = @pIdOTSolicitud


                    if @pComentario is not null
                        begin
                            set @descripcion = isnull(@descripcion, '') + ' Motivo: ' + isnull(@pComentario, '')
                        end

                    exec p_OT_SolicitudBitacora_ins
                        @pIdOTSolicitud,
                        null,
                        @descripcion,
                        @pUsuarioId,
                        null

                    exec p_OT_CorreoProgramacion_Flujo
                        @pIdOTSolicitud,
                        @pUsuarioId,
                        '',
                        12

                    commit tran

                END TRY
                BEGIN CATCH
                    rollback tran
                    select
                        Error = error_message()

                END CATCH
            end
        else
            begin
                select
                    Error = 'No se posible cerrar la OT, no tienes los permisos necesarios'
            end
    end
