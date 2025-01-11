IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_Solicitud_Upd'
    )
    DROP PROCEDURE p_OT_Solicitud_Upd;
GO
CREATE proc p_OT_Solicitud_Upd 
    @pIdOTSolicitud int,
    @pObjeto        varchar(600),
    @pSAPPR         varchar(15),
    @pError         varchar(250) out
as
    set @pError = ''

    BEGIN TRY

        update
            OT_Solicitud
        set
            SAPPR = @pSAPPR,
            Objeto = case
                         when isnull(@pObjeto, '') = ''
                             then Objeto
                         else
                             @pobjeto
                     end,
            FechaAprobacionSAPPR = case
                                       when FechaAprobacionSAPPR is null
                                           then case
                                                    when @pSAPPR <> SAPPR
                                                        then getdate()
                                                    else
                                                        FechaAprobacionSAPPR
                                                end
                                       else
                                           FechaAprobacionSAPPR
                                   end,
            ModificadoEl = getdate()
        where
            IdOTSolicitud = @pIdOTSolicitud

        if isnull(@pSAPPR, '') <> ''
            begin

                Update
                    petrovendor..DEA_AdjuntoPR
                set
                    ID_PR = @pSAPPR
                FROM
					OT_Estimacion          e (NOLOCK)
				INNER JOIN
                    petrovendor..MM_Pedido p (NOLOCK)
                    ON  
						e.IdOTSolicitud = @pIdOTSolicitud
                    AND
						p.IdPedido = e.IdPedido
				INNER JOIN
                    petrovendor..DEA_AdjuntoPR a (NOLOCK)
                 ON	 p.IdSolicitudPedido	=	a.IdSolicitudPedido


                INSERT INTO petrovendor..DEA_AdjuntoPR
                    (
                        IdSolicitudPedido,
                        IdDocumento,
                        IdProveedor,
                        Comentario,
                        CreadoPor,
                        CreadoEl,
                        EditadoEl,
                        EditadoPor,
                        EliminadoEl,
                        EliminadoPor,
                        Activo,
                        IsEliminado,
                        ID_PR
                    )
                            select
                                p.IdSolicitudPedido,
                                null,
                                p.IdProveedorCompras,
                                e.FolioEstimacion,
                                null,
                                getdate(),
                                null,
                                null,
                                null,
                                null,
                                1,
                                0,
                                @pSAPPR
                            from
                                OT_Estimacion              e (NOLOCK)
                            INNER JOIN
                                    petrovendor..MM_Pedido p (NOLOCK)
                                ON  e.IdPedido	=	p.IdPedido
								AND	e.IdOTSolicitud = @pIdOTSolicitud
								AND isnull(e.cancelada, 0) = 0
							LEFT JOIN
								 petrovendor..DEA_AdjuntoPR APP (NOLOCK)
                                ON	p.IdSolicitudPedido	=	APP.IdSolicitudPedido
                            WHERE
                                e.IdOTSolicitud =	@pIdOTSolicitud
								AND isnull(e.cancelada, 0) = 0
								AND APP.IdAjuntoPR IS NULL;
                          
            end

    END TRY
    BEGIN CATCH
        set @pError = error_message()
    END CATCH
