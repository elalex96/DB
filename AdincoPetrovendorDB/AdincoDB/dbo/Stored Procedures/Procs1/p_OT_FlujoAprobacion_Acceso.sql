IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_FlujoAprobacion_Acceso'
    )
    DROP PROCEDURE p_OT_FlujoAprobacion_Acceso;
GO
CREATE PROCEDURE p_OT_FlujoAprobacion_Acceso --1,10038,10,334
    @pTipoFlujoAprobacionId int,
    @pIdContrato            int,
    @pUsuarioId             int,
    @pIdOTSolicitud         int
AS
    BEGIN
        DECLARE @idCC int;

        select
            @idCC =	isnull(IdCentroCosto, 0)
        from
            OT_Solicitud (NOLOCK)
        where
            IdOTSolicitud = @pIdOTSolicitud;



        select
            CreadorOT            = cast(isnull(MAX(   case
                                                          when fe.Orden = 1
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit),
            AprobadorOT          = cast(isnull(MAX(   case
                                                          when fe.Orden = 2
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit),
            ValidadorCantOT      = cast(isnull(MAX(   case
                                                          when fe.Orden = 3
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit),
            GeneradorEstimacion  = cast(isnull(MAX(   case
                                                          when fe.Orden = 4
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit),
            AceptacionServicioOT = cast(isnull(MAX(   case
                                                          when fe.Orden = 5
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit),
            AdminContratos       = cast(isnull(MAX(   case
                                                          when fe.Orden = 6
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit),
            ConsultaContratos    = cast(isnull(MAX(   case
                                                          when fe.Orden = 7
                                                              then 1
                                                          else
                                                              0
                                                      end
                                                  ), 0
                                              ) as bit)
        from
            [AP_FlujoAprobacionContratos]           fc (NOLOCK)
            INNER JOIN
                [AP_FlujoAprobacion]                fa (NOLOCK)
                    on fc.IdContrato = @pIdContrato
                       AND fc.FlujoAprobacionId	=	fa.FlujoAprobacionId
            INNER JOIN
                [AP_FlujoAprobacionEstatus]         fe (NOLOCK)
                    ON fa.TipoFlujoAprobacionId = fe.TipoFlujoAprobacionId
					AND fe.TipoFlujoAprobacionId = @pTipoFlujoAprobacionId
            INNER JOIN
                [AP_FlujoAprobacionEstatusUsuarios] fu (NOLOCK)
                    on fe.FlujoAprobacionEstatusId = fu.FlujoAprobacionEstatusId
                       AND fu.usuarioId = @pUsuarioId
            INNER JOIN
                [dbo].[AP_UsuarioCentroCosto]       ucc (NOLOCK)
                    on fu.usuarioId = ucc.IdUsuario
                       and isnull(@idCC, 0) in (
                                                   0, ucc.IdCentroCosto
                                               )
        where
            fe.TipoFlujoAprobacionId = @pTipoFlujoAprobacionId
            and fc.IdContrato = @pIdContrato
            and fu.usuarioId = @pUsuarioId;

    END