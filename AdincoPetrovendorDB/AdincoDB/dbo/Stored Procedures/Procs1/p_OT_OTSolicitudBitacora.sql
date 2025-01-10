IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_OTSolicitudBitacora'
    )
    DROP PROCEDURE p_OT_OTSolicitudBitacora;
GO
create procedure p_OT_OTSolicitudBitacora @pIdOTSolicitud int
as
    begin
        CREATE TABLE #tbtUsuariodAdincoPetro
            (
                Usuario         VARCHAR(300),
                Sistema         Varchar(30),
                IdOTSolicitud   INT,
                IdOTBitacora    INT,
                UsuarioAdincoId INT,
                UsuarioPetroId  INT
            )
        INSERT INTO #tbtUsuariodAdincoPetro
            (
                Usuario,
                Sistema,
                IdOTSolicitud,
                IdOTBitacora,
                UsuarioPetroId
            )
                    SELECT DISTINCT
                        nombre COLLATE SQL_Latin1_General_CP1_CI_AS,
                        'Petrovendor',
                        b.IdOTSolicitud,
                        IdOTBitacora,
                        b.UsuarioPetroId
                    from
                        Petrovendor..S_Usuario   u (NOLOCK)
                        join
                            OT_SolicitudBitacora as b (NOLOCK)
                                on u.IdUsuario = b.UsuarioPetroId
                                   AND b.IdOTSolicitud = @pIdOTSolicitud
                    where
                        b.IdOTSolicitud = @pIdOTSolicitud

        INSERT INTO #tbtUsuariodAdincoPetro
            (
                Usuario,
                Sistema,
                IdOTSolicitud,
                IdOTBitacora,
                UsuarioAdincoId
            )
                    select DISTINCT
                        nombre COLLATE SQL_Latin1_General_CP1_CI_AS,
                        'Adinco',
                        b.IdOTSolicitud,
                        b.IdOTBitacora,
                        b.UsuarioAdincoId
                    from
                        AP_Usuario               u (NOLOCK)
                        join
                            OT_SolicitudBitacora as b (NOLOCK)
                                on u.UsuarioID = b.UsuarioAdincoId
                                   AND b.IdOTSolicitud = @pIdOTSolicitud
                    where
                        b.IdOTSolicitud = @pIdOTSolicitud

        select
            otb.IdOTSolicitud,
            otb.CreadoEl,
            otb.Descripcion as 'Comentarios',
            otb.UsuarioAdincoId,
            otb.UsuarioPetroId,
            TBU.Usuario     as 'Usuario'
        from
            OT_SolicitudBitacora        as otb (NOLOCK)
            JOIN
                #tbtUsuariodAdincoPetro TBU
                    ON otb.IdOTSolicitud = @pIdOTSolicitud
                       AND otb.IdOTBitacora = TBU.IdOTBitacora
                       AND otb.IdOTSolicitud = TBU.IdOTSolicitud
        where
            otb.IdOTSolicitud = @pIdOTSolicitud
        order by
            otb.CreadoEl desc
    end
